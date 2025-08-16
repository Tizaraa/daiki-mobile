import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector%20Pending%20task.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import 'Inspector_maintenance_schedule.dart';
import 'Inspector_quiz_model.dart';



class AnswersPreviewScreen extends StatefulWidget {
  final int maintenanceScheduleId;
  final int johkasouId;
  final int projectId;
  final Map<int, String?> selectedOptions;
  final Map<int, File?> questionImages;
  final Map<int, String?> questionComments;
  final List<Category> categories;
  final Map<int, bool> mainQuestionVisibility;
  final Map<int, TextEditingController> controllers;
  final bool isConnected;
  final Command? redisCommand;

  const AnswersPreviewScreen({
    Key? key,
    required this.maintenanceScheduleId,
    required this.johkasouId,
    required this.projectId,
    required this.selectedOptions,
    required this.questionImages,
    required this.questionComments,
    required this.categories,
    required this.mainQuestionVisibility,
    required this.controllers,
    required this.isConnected,
    required this.redisCommand,
  }) : super(key: key);

  @override
  _AnswersPreviewScreenState createState() => _AnswersPreviewScreenState();
}

class _AnswersPreviewScreenState extends State<AnswersPreviewScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    print('=== Initializing AnswersPreviewScreen ===');
    _initializeControllers();
    _debugCollectedData();
    _testApiEndpoint();
  }

  void _initializeControllers() {
    print('Initializing controllers for number, text, and String questions...');
    for (var category in widget.categories) {
      for (var question in category.questions) {
        if (question.type == 'number' || question.type == 'text' || question.type == 'String') {
          if (!widget.controllers.containsKey(question.id)) {
            widget.controllers[question.id] = TextEditingController();
            print('Created controller for Question ID: ${question.id}, Type: ${question.type}');
          }
        }
      }
    }
    print('Controller initialization complete. Total controllers: ${widget.controllers.length}');
  }

  Future<bool> _isAllQuestionsAnswered() async {
    for (var category in widget.categories) {
      for (var question in category.questions) {
        bool isVisible = widget.mainQuestionVisibility[question.id] == true;
        if (isVisible && question.required == 1) {
          if (question.type == 'number') {
            final text = widget.controllers[question.id]?.text ?? '';
            if (text.isEmpty) {
              _showMissingAnswerAlert(question);
              return false;
            }
            try {
              double.parse(text); // Allow decimals for number fields
            } catch (e) {
              _showInvalidNumberAlert(question);
              return false;
            }
          } else if (question.type == 'text' &&
              (widget.controllers[question.id]?.text.isEmpty ?? true)) {
            _showMissingAnswerAlert(question);
            return false;
          } else if (question.options.isNotEmpty &&
              widget.selectedOptions[question.id] == null) {
            _showMissingAnswerAlert(question);
            return false;
          }
        }
      }
    }
    return true;
  }

  void _showMissingAnswerAlert(Question question) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please answer the required question: ${question.text}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInvalidNumberAlert(Question question) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid number for: ${question.text}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _debugCollectedData() {
    print('=== Collected Data ===');
    print('Maintenance Schedule ID: ${widget.maintenanceScheduleId}');
    print('Johkasou ID: ${widget.johkasouId}');
    print('Project ID: ${widget.projectId}');
    print('Selected Options (${widget.selectedOptions.length}):');
    widget.selectedOptions.forEach((id, value) => print('  Question ID $id: $value'));
    print('Controllers (${widget.controllers.length}):');
    widget.controllers.forEach((id, controller) => print('  Question ID $id: ${controller.text}'));
    print('Comments (${widget.questionComments.length}):');
    widget.questionComments.forEach((id, comment) => print('  Question ID $id: $comment'));
    print('Images (${widget.questionImages.length}):');
    widget.questionImages.forEach((id, image) => print('  Question ID $id: ${image?.path}'));
    print('Categories (${widget.categories.length}):');
    for (var category in widget.categories) {
      print('  Category: ${category.name} (ID: ${category.id})');
      for (var question in category.questions) {
        print('    Question ID: ${question.id}, Text: ${question.text}, Type: ${question.type}, Required: ${question.required}');
      }
    }
    print('Visibility (${widget.mainQuestionVisibility.length}):');
    widget.mainQuestionVisibility.forEach((id, visible) => print('  Question ID $id: $visible'));
  }

  Future<void> _submitAnswers() async {
    setState(() => _isSubmitting = true);

    try {
      final allAnswered = await _isAllQuestionsAnswered();
      if (!allAnswered) {
        setState(() => _isSubmitting = false);
        return;
      }

      if (!widget.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No internet connection. Please try again when connected.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found. Please log in.');

      String? userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found. Please log in again.');
      }

      List<Map<String, dynamic>> responsesArray = [];
      for (var category in widget.categories) {
        for (var question in category.questions) {
          bool hasInput = widget.selectedOptions.containsKey(question.id) ||
              (widget.controllers.containsKey(question.id) && widget.controllers[question.id]!.text.isNotEmpty) ||
              widget.questionComments.containsKey(question.id) ||
              widget.questionImages.containsKey(question.id);

          if (!hasInput) {
            print('Skipping Question ID ${question.id} (Text: ${question.text}) - no input');
            continue;
          }

          String response = '';
          if (question.type == 'number' || question.type == 'text' || question.type == 'String') {
            response = widget.controllers[question.id]?.text ?? '';
          } else if (question.options.isNotEmpty) {
            response = widget.selectedOptions[question.id] ?? '';
          }

          String? comment = widget.questionComments[question.id];
          File? image = widget.questionImages[question.id];

          responsesArray.add({
            'question_id': question.id,
            'category_id': category.id,
            'response': response,
            'remarks': comment ?? '',
            'question_text': question.text,
            'category_name': category.name,
            'unique_key': '${category.id}_${question.id}',
          });
          print(
              'Added response for Question ID ${question.id} (Text: ${question.text}, Category: ${category.name}, Unique Key: ${category.id}_${question.id}): Response=$response, Remarks=$comment, Has Image=${image != null}');
        }
      }

      if (responsesArray.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No responses to submit. Please answer at least one question.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final Map<String, dynamic> payload = {
        'maintenance_schedule_id': widget.maintenanceScheduleId,
        'johkasou_model_id': widget.johkasouId,
        'project_id': widget.projectId,
        'user_id': userId,
        'responses': responsesArray,
      };
      print('Full payload: ${json.encode(payload)}');
      print('Total responses: ${responsesArray.length}');

      // Show AlertDialog with payload
      if (!mounted) return;
      bool? shouldSubmit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildPayloadDialog(payload, responsesArray),
      );

      if (shouldSubmit != true) {
        print('Submission cancelled by user');
        setState(() => _isSubmitting = false);
        return;
      }

      // Proceed with submission
      bool success = await _tryMultipartSubmission(token, userId, responsesArray);
      if (!success) {
        throw Exception('Multipart submission failed');
      }

      print('Submission successful for johkasouId: ${widget.johkasouId}');
      await _uploadPendingMedia(widget.maintenanceScheduleId, widget.johkasouId);

      // Mark task as completed for this johkasouId
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('completed_${widget.maintenanceScheduleId}_${widget.johkasouId}', true);
      try {
        final redisConnection = RedisConnection();
        final redisCommand = await redisConnection.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
        await redisCommand.send_object(['AUTH', 'password']).timeout(Duration(seconds: 2));
        await redisCommand.send_object(['SET', 'completed_${widget.maintenanceScheduleId}_${widget.johkasouId}', 'true']).timeout(Duration(seconds: 2));
        await redisCommand.send_object(['QUIT']);
        await redisConnection.close();
        print('Task marked as completed in Redis for maintenanceScheduleId: ${widget.maintenanceScheduleId}, johkasouId: ${widget.johkasouId}');
      } catch (e) {
        print('Error updating Redis completion status: $e');
      }

      // Do NOT remove the maintenance schedule or trigger a refresh of the schedule list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answers submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to SubmissionSuccessScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SubmissionSuccessScreen(
            maintenanceId: widget.maintenanceScheduleId.toString(),
            projectId: widget.projectId,
            johkasouId: widget.johkasouId,
            successUrl:
            '${DaikiAPI.api_key}/mushak/stpData/${widget.maintenanceScheduleId}?johkasou_model_id=${widget.johkasouId}',
          ),
        ),
      );
    } catch (e) {
      print('Submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildPayloadDialog(Map<String, dynamic> payload, List<Map<String, dynamic>> responsesArray) {
    return AlertDialog(
      title: const Text('Confirm Submission'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review the data to be submitted:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'Maintenance Schedule ID: ${payload['maintenance_schedule_id']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Johkasou Model ID: ${payload['johkasou_model_id']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Project ID: ${payload['project_id']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'User ID: ${payload['user_id']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Responses (${responsesArray.length}):',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (responsesArray.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No responses provided.',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              )
            else
              ...responsesArray.map((response) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category: ${response['category_name']}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Question: ${response['question_text']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Answer: ${response['response'].isEmpty ? '-' : response['response']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Remarks: ${response['remarks'].isEmpty ? '-' : response['remarks']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 16),
            Text(
              'Images (${widget.questionImages.length}):',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.questionImages.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No images provided.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            else
              ...widget.questionImages.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Question ID ${entry.key}: ${entry.value?.path.split('/').last ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<bool> _tryMultipartSubmission(String token, String userId, List<Map<String, dynamic>> responsesArray) async {
    try {
      print('Attempting multipart format submission...');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance/stp-store'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
      request.fields['johkasou_model_id'] = widget.johkasouId.toString();
      request.fields['project_id'] = widget.projectId.toString();
      request.fields['user_id'] = userId;

      for (int i = 0; i < responsesArray.length; i++) {
        var response = responsesArray[i];
        request.fields['responses[$i][question_id]'] = response['question_id'].toString();
        request.fields['responses[$i][category_id]'] = response['category_id'].toString();
        request.fields['responses[$i][response]'] = response['response'].toString();
        request.fields['responses[$i][remarks]'] = response['remarks'].toString();
        request.fields['responses[$i][unique_key]'] = response['unique_key'].toString();
        print(
            'Multipart field responses[$i]: Question ID=${response['question_id']}, Response=${response['response']}, Text=${response['question_text']}, Unique Key=${response['unique_key']}');
      }

      print('Multipart fields: ${request.fields}');

      final streamedResponse = await _sendWithRetry(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Multipart Response status: ${response.statusCode}');
      print('Multipart Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true || responseData['success'] == true) {
          if (responseData['data'] != null && responseData['data']['saved_question_ids'] != null) {
            List<int> savedIds = List<int>.from(responseData['data']['saved_question_ids']);
            print('Saved question IDs: $savedIds');
            List<int> sentIds = responsesArray.map((r) => r['question_id'] as int).toList();
            if (!sentIds.every((id) => savedIds.contains(id))) {
              print('Warning: Not all question IDs were saved by server');
              return false;
            }
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Multipart submission failed: $e');
      return false;
    }
  }

  Future<bool> _uploadImage(int questionId, File imageFile, int maintenanceScheduleId, int johkasouId) async {
    try {
      if (!await imageFile.exists()) {
        print('Image file does not exist: ${imageFile.path}');
        return false;
      }

      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://minio.johkasou-erp.com/api/v1/image/store'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'maintenance_schedule_id': maintenanceScheduleId.toString(),
        'johkasou_model_id': johkasouId.toString(),
        'question_id': questionId.toString(),
        'type': 'inspection',
        'ip_address': 'Unknown',
        'location': 'Unknown',
        'device_model': 'Unknown',
      });

      print('Uploading image for Question ID $questionId: ${imageFile.path}');
      print('File size: ${await imageFile.length()} bytes');

      final mimeType = _getImageMimeType(imageFile.path);
      request.files.add(await http.MultipartFile.fromPath(
        'media',
        imageFile.path,
        contentType: mimeType,
      ));

      print('Sending image upload request...');
      final streamedResponse = await _sendWithRetry(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Image upload response status: ${response.statusCode}');
      print('Image upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return (responseData['status'] as bool?) == true || (responseData['success'] as bool?) == true;
      } else {
        print('Image upload failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error uploading image for Question ID $questionId: $e');
      return false;
    }
  }

  MediaType _getImageMimeType(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<http.StreamedResponse> _sendWithRetry(http.MultipartRequest request, {int maxRetries = 3}) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('Sending request attempt $attempt of $maxRetries');
        final response = await request.send().timeout(Duration(seconds: 20 * attempt));
        print('Request sent successfully on attempt $attempt');
        return response;
      } catch (e) {
        lastException = Exception('Failed on attempt $attempt: $e');
        print('Request attempt $attempt failed: $e');
        if (attempt < maxRetries) {
          final delay = Duration(seconds: attempt * 2);
          print('Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      }
    }

    throw lastException ?? Exception('Failed to send request after $maxRetries attempts');
  }

  Future<void> _uploadPendingMedia(int maintenanceScheduleId, int johkasouId) async {
    final uploadFutures = <Future<bool>>[];
    for (var entry in widget.questionImages.entries) {
      if (entry.value != null) {
        uploadFutures.add(_uploadImage(
          entry.key,
          entry.value!,
          maintenanceScheduleId,
          johkasouId,
        ));
      }
    }
    final results = await Future.wait(uploadFutures);
    print('Image upload results: $results');
  }

  Future<void> _testApiEndpoint() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        print('No token available for API test');
        return;
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance/stp-check'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('API test response: ${response.statusCode}');
      print('API test body: ${response.body}');
    } catch (e) {
      print('API test failed: $e');
    }
  }

  Widget _buildQuestionReview(Question question) {
    print('Building review for question: ${question.text} (ID: ${question.id})');

    String? answer;
    String? selectedOptionValue = widget.selectedOptions[question.id];
    bool hasOptions = question.options.isNotEmpty;

    if (hasOptions && selectedOptionValue != null && selectedOptionValue.isNotEmpty) {
      try {
        final selectedOption = question.options.firstWhere(
              (option) => option.id.toString() == selectedOptionValue || option.value == selectedOptionValue,
          orElse: () => Option(
            id: -1,
            text: selectedOptionValue,
            questionId: question.id,
            value: selectedOptionValue,
            options: [],
          ),
        );
        answer = selectedOption.text;
        print('  Found selected option text: $answer for value: $selectedOptionValue');
      } catch (e) {
        print('  Error finding selected option: $e');
        answer = selectedOptionValue;
      }
    } else if (!hasOptions && widget.controllers.containsKey(question.id)) {
      answer = widget.controllers[question.id]!.text;
      if (answer.isNotEmpty) {
        print('  Using controller text: $answer');
      }
    }

    String? comment = widget.questionComments[question.id];
    File? image = widget.questionImages[question.id];

    print('  Final Answer: $answer');
    print('  Final Comment: $comment');
    print('  Final Has Image: ${image != null}');

    // Skip questions with no input
    if ((answer == null || answer.isEmpty) &&
        (comment == null || comment.isEmpty) &&
        image == null) {
      print('  Skipping question display: No answer, comment, or image');
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xffe8f3f4),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (question.unit != null && question.unit!.isNotEmpty)
              Text(
                'Unit: ${question.unit}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            if (answer != null && answer.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Answer:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answer,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (answer == null || answer.isEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Answer:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No answer provided',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (comment != null && comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.comment, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comment:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (image != null) ...[
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Attached Image:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image for Question ID ${question.id}: $error');
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Text(
                                'Image not available',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          widget.categories.isEmpty
              ? const Center(
            child: Text(
              'No questions available to review.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.categories.length,
            itemBuilder: (context, categoryIndex) {
              final category = widget.categories[categoryIndex];
              final answeredQuestions = category.questions.where((question) {
                bool hasAnswer = widget.selectedOptions.containsKey(question.id) &&
                    widget.selectedOptions[question.id] != null &&
                    widget.selectedOptions[question.id]!.isNotEmpty;
                bool hasText = widget.controllers.containsKey(question.id) &&
                    widget.controllers[question.id]!.text.isNotEmpty;
                bool hasComment = widget.questionComments.containsKey(question.id) &&
                    widget.questionComments[question.id] != null &&
                    widget.questionComments[question.id]!.isNotEmpty;
                bool hasImage = widget.questionImages.containsKey(question.id) &&
                    widget.questionImages[question.id] != null;
                return hasAnswer || hasText || hasComment || hasImage;
              }).toList();

              print('Category ${category.name}: Found ${answeredQuestions.length} questions with input');

              if (answeredQuestions.isEmpty) {
                print('Skipping Category ${category.name}: No answered questions');
                return const SizedBox.shrink();
              }

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: answeredQuestions.map((question) {
                          return _buildQuestionReview(question);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//=========== Submission Success Screen  =============//0

class SubmissionSuccessScreen extends StatelessWidget {
  final String maintenanceId;
  final int projectId;
  final int johkasouId;
  final String? successUrl;

  const SubmissionSuccessScreen({
    Key? key,
    required this.maintenanceId,
    required this.projectId,
    required this.johkasouId,
    this.successUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Colors.white],
            stops: [0.0, 0.5],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Submission Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your maintenance report has been successfully submitted.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 8),
                // Text(
                //   'Maintenance ID: $maintenanceId',
                //   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                // ),
                // Text(
                //   'Project ID: $projectId',
                //   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                // ),
                const SizedBox(height: 48),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },

                  icon: const Icon(Icons.home),
                  label: const Text('Return to Homes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}