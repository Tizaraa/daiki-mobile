// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:daiki_axis_stp/HomePage/Inspector%20HomePage/Inspector%20Maintenance_Response/Inspector_quiz_model.dart';
// import 'package:daiki_axis_stp/Token-Manager/token_manager_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:redis/redis.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MultiJohkasouPreviewScreen extends StatefulWidget {
//   final int maintenanceScheduleId;
//   final List<int> johkasouIds;
//   final int projectId;
//   final String projectName;
//   final DateTime? nextMaintenanceDate;
//   final Future<void> Function(int maintenanceScheduleId, int johkasouId) submitFinalTask;
//
//   const MultiJohkasouPreviewScreen({
//     Key? key,
//     required this.maintenanceScheduleId,
//     required this.johkasouIds,
//     required this.projectId,
//     required this.projectName,
//     required this.nextMaintenanceDate,
//     required this.submitFinalTask,
//   }) : super(key: key);
//
//   @override
//   _MultiJohkasouPreviewScreenState createState() => _MultiJohkasouPreviewScreenState();
// }
//
// class _MultiJohkasouPreviewScreenState extends State<MultiJohkasouPreviewScreen> {
//   bool _isSubmitting = false;
//   Map<int, Map<int, String?>> _allSelectedOptions = {};
//   Map<int, Map<int, File?>> _allQuestionImages = {};
//   Map<int, Map<int, String?>> _allQuestionComments = {};
//   Map<int, List<Category>> _allCategories = {};
//   Map<int, Map<int, bool>> _allMainQuestionVisibility = {};
//   Map<int, Map<int, TextEditingController>> _allControllers = {};
//   bool _isConnected = true;
//   Command? _redisCommand;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }
//
//   Future<void> _initializeData() async {
//     print('Initializing MultiJohkasouPreviewScreen for Johkasou IDs: ${widget.johkasouIds}');
//     for (var johkasouId in widget.johkasouIds) {
//       _allSelectedOptions[johkasouId] = {};
//       _allQuestionImages[johkasouId] = {};
//       _allQuestionComments[johkasouId] = {};
//       _allCategories[johkasouId] = [];
//       _allMainQuestionVisibility[johkasouId] = {};
//       _allControllers[johkasouId] = {};
//       await _loadDataForJohkasou(johkasouId);
//     }
//     try {
//       final redisConn = RedisConnection();
//       _redisCommand = await redisConn.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
//       print('Redis connection established.');
//     } catch (e) {
//       print('Failed to connect to Redis: $e');
//       _isConnected = false;
//     }
//     setState(() {});
//   }
//
//   Future<void> _loadDataForJohkasou(int johkasouId) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Load categories
//     _allCategories[johkasouId] = await _fetchCategories(johkasouId);
//     print('Loaded ${_allCategories[johkasouId]!.length} categories for Johkasou $johkasouId');
//
//     // Initialize controllers and visibility
//     for (var category in _allCategories[johkasouId]!) {
//       for (var question in category.questions) {
//         if (question.type == 'number' || question.type == 'text') {
//           _allControllers[johkasouId]![question.id] = TextEditingController();
//         }
//         _allMainQuestionVisibility[johkasouId]![question.id] = true;
//       }
//     }
//
//     // Load selected options
//     for (var category in _allCategories[johkasouId]!) {
//       for (var question in category.questions) {
//         if (question.type == 'radio') {
//           final key = 'option_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//           final value = prefs.getString(key);
//           if (value != null && value.isNotEmpty) {
//             _allSelectedOptions[johkasouId]![question.id] = value;
//             print('Loaded radio option for Johkasou $johkasouId - Key: $key, Value: $value');
//           }
//         }
//       }
//     }
//
//     // Load comments
//     for (var category in _allCategories[johkasouId]!) {
//       for (var question in category.questions) {
//         final key = 'comment_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//         final value = prefs.getString(key);
//         if (value != null && value.isNotEmpty) {
//           _allQuestionComments[johkasouId]![question.id] = value;
//           print('Loaded comment for Johkasou $johkasouId - Key: $key, Value: $value');
//         }
//       }
//     }
//
//     // Load text/number inputs
//     for (var category in _allCategories[johkasouId]!) {
//       for (var question in category.questions) {
//         if (question.type == 'number' || question.type == 'text') {
//           final keyPrefix = question.type == 'number' ? 'number' : 'text';
//           final key = '${keyPrefix}_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//           final value = prefs.getString(key);
//           if (value != null) {
//             try {
//               if (question.type == 'number') {
//                 int.parse(value); // Validate integer
//               }
//               _allControllers[johkasouId]![question.id]!.text = value;
//               print('Loaded ${question.type} field for Johkasou $johkasouId - Key: $key, Value: $value');
//             } catch (e) {
//               print('Invalid value for Johkasou $johkasouId - Key: $key, Value: $value, Error: $e');
//             }
//           }
//         }
//       }
//     }
//
//     // Load images
//     for (var category in _allCategories[johkasouId]!) {
//       for (var question in category.questions) {
//         final key = 'image_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//         final path = prefs.getString(key);
//         if (path != null && path.isNotEmpty && await File(path).exists()) {
//           _allQuestionImages[johkasouId]![question.id] = File(path);
//           print('Loaded image for Johkasou $johkasouId - Key: $key, Path: $path');
//         }
//       }
//     }
//
//     // Debug: Print loaded data
//     print('Loaded data for Johkasou $johkasouId:');
//     print('  Selected options: ${_allSelectedOptions[johkasouId]}');
//     print('  Comments: ${_allQuestionComments[johkasouId]}');
//     print('  Text/Number inputs: ${_allControllers[johkasouId]!.map((k, v) => MapEntry(k, v.text))}');
//     print('  Images: ${_allQuestionImages[johkasouId]}');
//   }
//
//   Future<List<Category>> _fetchCategories(int johkasouId) async {
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null) throw Exception('No token found');
//
//       final response = await http.get(
//         Uri.parse('https://uat-backend.tizaraa.shop/api/v1/inspector/categories?johkasou_model_id=$johkasouId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       ).timeout(Duration(seconds: 10));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final categoriesJson = data['categories'] as List<dynamic>? ?? [];
//         final categories = categoriesJson
//             .map((json) => Category.fromJson(json))
//             .toList();
//         print('Fetched ${categories.length} categories for Johkasou $johkasouId from API');
//
//         // Save to SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(
//           'categories_${widget.maintenanceScheduleId}_$johkasouId',
//           json.encode(categoriesJson),
//         );
//         return categories;
//       } else {
//         throw Exception('Failed to fetch categories: HTTP ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching categories for Johkasou $johkasouId: $e');
//       final prefs = await SharedPreferences.getInstance();
//       final cached = prefs.getString('categories_${widget.maintenanceScheduleId}_$johkasouId');
//       if (cached != null) {
//         final categoriesJson = json.decode(cached) as List<dynamic>;
//         final categories = categoriesJson
//             .map((json) => Category.fromJson(json))
//             .toList();
//         print('Loaded ${categories.length} cached categories for Johkasou $johkasouId');
//         return categories;
//       }
//       print('No cached categories found for Johkasou $johkasouId');
//       return [];
//     }
//   }
//
//   Future<bool> _isAllQuestionsAnswered(int johkasouId) async {
//     for (var category in _allCategories[johkasouId]!) {
//       for (var question in category.questions) {
//         bool isVisible = _allMainQuestionVisibility[johkasouId]![question.id] == true;
//         if (isVisible && question.required == 1) {
//           if (question.type == 'radio' && _allSelectedOptions[johkasouId]![question.id] == null) {
//             return false;
//           }
//           if ((question.type == 'number' || question.type == 'text') &&
//               (_allControllers[johkasouId]![question.id]?.text.isEmpty ?? true)) {
//             return false;
//           }
//         }
//       }
//     }
//     return true;
//   }
//
//   Future<void> _saveAllData(int johkasouId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<Future> saveFutures = [];
//
//     for (var entry in _allSelectedOptions[johkasouId]!.entries) {
//       final key = 'option_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
//       final value = entry.value ?? '';
//       saveFutures.add(prefs.setString(key, value));
//       print('Saving radio option for Johkasou $johkasouId - Key: $key, Value: $value');
//     }
//
//     for (var entry in _allQuestionComments[johkasouId]!.entries) {
//       final key = 'comment_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
//       final value = entry.value ?? '';
//       saveFutures.add(prefs.setString(key, value));
//       print('Saving comment for Johkasou $johkasouId - Key: $key, Value: $value');
//     }
//
//     for (var entry in _allControllers[johkasouId]!.entries) {
//       final question = _allCategories[johkasouId]!
//           .expand((c) => c.questions)
//           .firstWhere(
//             (q) => q.id == entry.key,
//         orElse: () => Question(
//           id: entry.key,
//           categoryId: _allCategories[johkasouId]!.isNotEmpty ? _allCategories[johkasouId]!.first.id : 0,
//           text: '',
//           type: 'text',
//           options: [],
//         ),
//       );
//       final keyPrefix = question.type == 'number' ? 'number' : 'text';
//       final key = '${keyPrefix}_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
//       final value = entry.value.text;
//       if (question.type == 'number' && value.isNotEmpty) {
//         try {
//           int.parse(value);
//           saveFutures.add(prefs.setString(key, value));
//           print('Saving number field for Johkasou $johkasouId - Key: $key, Value: $value');
//         } catch (e) {
//           print('Invalid integer for Johkasou $johkasouId - Key: $key, Value: $value, Error: $e');
//         }
//       } else {
//         saveFutures.add(prefs.setString(key, value)); // Fixed typo: saveFutures
//         print('Saving text field for Johkasou $johkasouId - Key: $key, Value: $value');
//       }
//     }
//
//     for (var entry in _allQuestionImages[johkasouId]!.entries) {
//       if (entry.value != null) {
//         final key = 'image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
//         final value = entry.value!.path;
//         saveFutures.add(prefs.setString(key, value));
//         print('Saving image for Johkasou $johkasouId - Key: $key, Value: $value');
//       }
//     }
//
//     await Future.wait(saveFutures);
//     print('All data saved to SharedPreferences for Johkasou $johkasouId.');
//
//     if (_redisCommand != null && _isConnected) {
//       for (var entry in _allControllers[johkasouId]!.entries) {
//         final question = _allCategories[johkasouId]!
//             .expand((c) => c.questions)
//             .firstWhere(
//               (q) => q.id == entry.key,
//           orElse: () => Question(
//             id: entry.key,
//             categoryId: _allCategories[johkasouId]!.isNotEmpty ? _allCategories[johkasouId]!.first.id : 0,
//             text: '',
//             type: 'text',
//             options: [],
//           ),
//         );
//         final keyPrefix = question.type == 'number' ? 'number' : 'text';
//         final key = '${keyPrefix}_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
//         final value = entry.value.text;
//         if (question.type == 'number' && value.isNotEmpty) {
//           try {
//             int.parse(value);
//             await _saveToRedis(key, value);
//             print('Saved to Redis for Johkasou $johkasouId - Key: $key, Value: $value');
//           } catch (e) {
//             print('Invalid integer for Redis Johkasou $johkasouId - Key: $key, Value: $value, Error: $e');
//           }
//         } else {
//           await _saveToRedis(key, value);
//           print('Saved to Redis for Johkasou $johkasouId - Key: $key, Value: $value');
//         }
//       }
//     }
//   }
//
//   Future<void> _saveToRedis(String key, String value) async {
//     if (_redisCommand == null) return;
//     try {
//       await _redisCommand!.send_object(['SET', key, value]).timeout(Duration(seconds: 2));
//       await _redisCommand!.send_object(['EXPIRE', key, '86400']).timeout(Duration(seconds: 2));
//       print('Redis save successful - Key: $key, Value: $value');
//     } catch (e) {
//       print('Redis error during save: $e');
//     }
//   }
//
//   Future<bool> _isRedisConnected() async {
//     if (_redisCommand == null) return false;
//     try {
//       await _redisCommand!.send_object(['PING']).timeout(Duration(seconds: 2));
//       return true;
//     } catch (e) {
//       print('Redis connection error: $e');
//       return false;
//     }
//   }
//
//   Future<void> _uploadPendingMedia(int johkasouId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final uploadFutures = <Future<bool>>[];
//
//     for (var entry in _allQuestionImages[johkasouId]!.entries) {
//       if (entry.value != null) {
//         uploadFutures.add(_uploadImage(
//           entry.key,
//           entry.value!,
//           widget.maintenanceScheduleId,
//           johkasouId,
//         ).then((success) async {
//           if (success) {
//             await prefs.remove('image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}');
//             if (_redisCommand != null) {
//               try {
//                 await _redisCommand!.send_object(['DEL', 'image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}']);
//                 print('Removed Redis image key: image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}');
//               } catch (e) {
//                 print('Redis error while deleting image key: $e');
//               }
//             }
//           }
//           return success;
//         }));
//       }
//     }
//
//     await Future.wait(uploadFutures);
//   }
//
//   Future<bool> _uploadImage(int questionId, File imageFile, int maintenanceScheduleId, int johkasouId) async {
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null) throw Exception('No token found');
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://uat-backend.tizaraa.shop/api/v1/image/store'),
//       );
//
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });
//
//       request.fields.addAll({
//         'maintenance_schedule_id': maintenanceScheduleId.toString(),
//         'johkasou_model_id': johkasouId.toString(),
//         'question_id': questionId.toString(),
//         'type': 'inspection',
//         'ip_address': 'Unknown',
//         'location': 'Unknown',
//         'device_model': 'Unknown',
//       });
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'media',
//         imageFile.path,
//         contentType: MediaType('image', 'jpeg'),
//       ));
//
//       final streamedResponse = await request.send().timeout(Duration(seconds: 5));
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         print('Image upload response for Johkasou $johkasouId: $responseData');
//         return (responseData['status'] as bool?) == true || (responseData['success'] as bool?) == true;
//       } else {
//         throw Exception('Failed to upload image for Johkasou $johkasouId: HTTP ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error uploading image for Johkasou $johkasouId: $e');
//       return false;
//     }
//   }
//
//   Future<void> _submitAllAnswers() async {
//     setState(() => _isSubmitting = true);
//
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null) throw Exception('No authentication token found');
//
//       String? userId = await TokenManager.getUserId();
//       if (userId == null) throw Exception('User ID not found');
//
//       // Prepare the request
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://uat-backend.tizaraa.shop/api/v1/maintenance/stp-final-submit'),
//       );
//
//       // Set headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });
//
//       // Add form fields
//       request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
//       request.fields['user_id'] = userId;
//
//       // For debugging
//       print('Submitting final maintenance with ID: ${widget.maintenanceScheduleId}');
//
//       // Send the request
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == true || responseData['success'] == true) {
//           print('Final submission successful for maintenance ${widget.maintenanceScheduleId}');
//
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => MultiSubmissionSuccessScreen(
//                 maintenanceId: widget.maintenanceScheduleId.toString(),
//                 projectId: widget.projectId,
//                 johkasouIds: widget.johkasouIds,
//                 projectName: widget.projectName,
//                 nextMaintenanceDate: widget.nextMaintenanceDate,
//               ),
//             ),
//           );
//         } else {
//           throw Exception('Server returned false status: ${response.body}');
//         }
//       } else {
//         throw Exception('HTTP ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to submit: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       print('Submission error: $e');
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }
//
//   Future<List<Widget>> _buildPreviewSections(int johkasouId) async {
//     List<Widget> sections = [];
//
//     if (_allCategories[johkasouId]!.isEmpty) {
//       return [
//         Center(
//           child: Padding(
//             padding: EdgeInsets.all(32),
//             child: Column(
//               children: [
//                 //Icon(Icons.circle, size: 64, color: Colors.orange),
//                 SizedBox(height: 16),
//                 Text(
//                   'Data Loading: $johkasouId...',
//                   style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         )
//       ];
//     }
//
//     for (var category in _allCategories[johkasouId]!) {
//       List<Widget> categoryQuestions = [];
//
//       for (var question in category.questions) {
//         if (_allMainQuestionVisibility[johkasouId]![question.id] == true) {
//           String answer = '';
//           String comment = _allQuestionComments[johkasouId]![question.id] ?? '';
//           File? image = _allQuestionImages[johkasouId]![question.id];
//
//           if (question.type == 'radio') {
//             final selectedOption = _allSelectedOptions[johkasouId]![question.id];
//             if (selectedOption != null && selectedOption.isNotEmpty) {
//               answer = selectedOption;
//             } else {
//               final key = 'option_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//               final prefs = await SharedPreferences.getInstance();
//               final value = prefs.getString(key);
//               answer = value ?? '(No selection)';
//             }
//           } else if (question.type == 'number') {
//             final controller = _allControllers[johkasouId]![question.id];
//             if (controller != null && controller.text.isNotEmpty) {
//               try {
//                 int intValue = int.parse(controller.text);
//                 answer = intValue.toString();
//               } catch (e) {
//                 answer = '(Invalid integer: ${controller.text})';
//               }
//             } else {
//               final key = 'number_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//               final prefs = await SharedPreferences.getInstance();
//               final value = prefs.getString(key);
//               if (value != null && value.isNotEmpty) {
//                 try {
//                   int intValue = int.parse(value);
//                   answer = intValue.toString();
//                 } catch (e) {
//                   answer = '(Invalid integer in SharedPreferences: $value)';
//                 }
//               } else {
//                 answer = '(No data)';
//               }
//             }
//           } else if (question.type == 'text') {
//             final controller = _allControllers[johkasouId]![question.id];
//             if (controller != null && controller.text.isNotEmpty) {
//               answer = controller.text;
//             } else {
//               final key = 'text_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
//               final prefs = await SharedPreferences.getInstance();
//               final value = prefs.getString(key);
//               answer = value ?? '(No data)';
//             }
//           }
//
//           if (answer.isNotEmpty && answer != '(No data)' || comment.isNotEmpty || image != null) {
//             categoryQuestions.add(
//               Card(
//                 elevation: 3,
//                 margin: EdgeInsets.only(bottom: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: Colors.teal.shade100, width: 1),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         question.text,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.teal.shade800,
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       if (answer.isNotEmpty && !answer.startsWith('(Invalid') && answer != '(No data)')
//                         Container(
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.grey.shade200),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(Icons.check_circle, color: Colors.teal, size: 20),
//                               SizedBox(width: 8),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Answer:',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey.shade700,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       answer,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (comment.isNotEmpty)
//                         Padding(
//                           padding: EdgeInsets.only(top: 12),
//                           child: Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(Icons.comment, color: Colors.blue, size: 20),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Comment:',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.grey.shade700,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         comment,
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       if (image != null)
//                         Padding(
//                           padding: EdgeInsets.only(top: 12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.image, color: Colors.purple, size: 20),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Attached Image:',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.grey.shade700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
//                               Container(
//                                 height: 180,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 5,
//                                       spreadRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.file(
//                                     image,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       print('Error loading image for Johkasou $johkasouId, Question ${question.id}: $error');
//                                       return Text('Failed to load image');
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//         }
//       }
//
//       if (categoryQuestions.isNotEmpty) {
//         sections.add(
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.teal.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.teal.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.category, color: Colors.teal),
//                     SizedBox(width: 8),
//                     Text(
//                       category.name,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 12),
//               ...categoryQuestions,
//               SizedBox(height: 24),
//             ],
//           ),
//         );
//       }
//     }
//
//     if (sections.isEmpty) {
//       return [
//         Center(
//           child: Padding(
//             padding: EdgeInsets.all(32),
//             child: Column(
//               children: [
//                 Icon(Icons.info_outline, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'No answers, comments, or images found for Johkasou ID: $johkasouId.',
//                   style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         )
//       ];
//     }
//
//     return sections;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Multi Johkasou Review',style: TextStyle(color: Colors.white),),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         elevation: 2,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text('Review Information'),
//                   content: Text('Review answers for all Johkasou models before submission.'),
//                   actions: [
//                     TextButton(
//                       child: Text('Understood'),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.teal.shade50, Colors.white],
//             stops: [0.0, 0.3],
//           ),
//         ),
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.assignment_turned_in,
//                             size: 40,
//                             color: Colors.teal,
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             'Multi Johkasou Review',
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal.shade800,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Project: ${widget.projectName}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                           Text(
//                             'Next Maintenance: ${widget.nextMaintenanceDate?.toString().split(' ')[0] ?? 'Not specified'}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   ...widget.johkasouIds.map((johkasouId) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.teal.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             'Johkasou ID: $johkasouId',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal.shade900,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         FutureBuilder<List<Widget>>(
//                           future: _buildPreviewSections(johkasouId),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return Center(child: CircularProgressIndicator());
//                             } else if (snapshot.hasError) {
//                               print('Error building preview for Johkasou $johkasouId: ${snapshot.error}');
//                               return Center(
//                                 child: Text(
//                                   'Error loading data for Johkasou $johkasouId: ${snapshot.error}',
//                                   style: TextStyle(color: Colors.red),
//                                 ),
//                               );
//                             } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                               return Column(children: snapshot.data!);
//                             } else {
//                               return Center(
//                                 child: Text('No data available for Johkasou $johkasouId'),
//                               );
//                             }
//                           },
//                         ),
//                         SizedBox(height: 24),
//                       ],
//                     );
//                   }).toList(),
//                   SizedBox(height: 100),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       spreadRadius: 1,
//                       offset: Offset(0, -3),
//                     ),
//                   ],
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         flex: 4,
//                         child: ElevatedButton.icon(
//                           onPressed: () => Navigator.pop(context),
//                           icon: Icon(Icons.arrow_back),
//                           label: Text('Back to Edit'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey.shade200,
//                             foregroundColor: Colors.black87,
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         flex: 6,
//                         child: ElevatedButton.icon(
//                           onPressed: _isSubmitting ? null : _submitAllAnswers,
//                           icon: _isSubmitting
//                               ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                               : Icon(Icons.check_circle),
//                           label: Text(_isSubmitting ? 'Submitting...' : 'Confirm & Submit All'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MultiSubmissionSuccessScreen extends StatelessWidget {
//   final String maintenanceId;
//   final int projectId;
//   final List<int> johkasouIds;
//   final String projectName;
//   final DateTime? nextMaintenanceDate;
//
//   const MultiSubmissionSuccessScreen({
//     Key? key,
//     required this.maintenanceId,
//     required this.projectId,
//     required this.johkasouIds,
//     required this.projectName,
//     required this.nextMaintenanceDate,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.teal.shade50, Colors.white],
//             stops: [0.0, 0.5],
//           ),
//         ),
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.teal,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.check,
//                     size: 80,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 32),
//                 Text(
//                   'Submission Successful!',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal.shade800,
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'Maintenance reports for all Johkasou models have been submitted.',
//                   style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Maintenance ID: $maintenanceId',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 Text(
//                   'Project: $projectName',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 Text(
//                   'Johkasou IDs: ${johkasouIds.join(', ')}',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 Text(
//                   'Next Maintenance: ${nextMaintenanceDate?.toString().split(' ')[0] ?? 'Not specified'}',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 SizedBox(height: 48),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.of(context).popUntil((route) => route.isFirst);
//                   },
//                   icon: Icon(Icons.home),
//                   label: Text('Return to Home'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import 'Inspector_quiz_model.dart';



class MultiJohkasouPreviewScreen extends StatefulWidget {
  final int maintenanceScheduleId;
  final List<int> johkasouIds;
  final int projectId;
  final String projectName;
  final DateTime? nextMaintenanceDate;
  final Future<void> Function(int maintenanceScheduleId, int johkasouId) submitFinalTask;

  const MultiJohkasouPreviewScreen({
    Key? key,
    required this.maintenanceScheduleId,
    required this.johkasouIds,
    required this.projectId,
    required this.projectName,
    required this.nextMaintenanceDate,
    required this.submitFinalTask,
  }) : super(key: key);

  @override
  _MultiJohkasouPreviewScreenState createState() => _MultiJohkasouPreviewScreenState();
}

class _MultiJohkasouPreviewScreenState extends State<MultiJohkasouPreviewScreen> with SingleTickerProviderStateMixin {
  bool _isSubmitting = false;
  Map<int, Map<int, String?>> _allSelectedOptions = {};
  Map<int, Map<int, File?>> _allQuestionImages = {};
  Map<int, Map<int, String?>> _allQuestionComments = {};
  Map<int, List<Category>> _allCategories = {};
  Map<int, Map<int, bool>> _allMainQuestionVisibility = {};
  Map<int, Map<int, TextEditingController>> _allControllers = {};
  bool _isConnected = true;
  Command? _redisCommand;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.johkasouIds.length, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    print('Initializing MultiJohkasouPreviewScreen for Johkasou IDs: ${widget.johkasouIds}');
    for (var johkasouId in widget.johkasouIds) {
      _allSelectedOptions[johkasouId] = {};
      _allQuestionImages[johkasouId] = {};
      _allQuestionComments[johkasouId] = {};
      _allCategories[johkasouId] = [];
      _allMainQuestionVisibility[johkasouId] = {};
      _allControllers[johkasouId] = {};
      await _loadDataForJohkasou(johkasouId);
    }
    try {
      final redisConn = RedisConnection();
      _redisCommand = await redisConn.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
      print('Redis connection established.');
    } catch (e) {
      print('Failed to connect to Redis: $e');
      _isConnected = false;
    }
    setState(() {});
  }

  Future<void> _loadDataForJohkasou(int johkasouId) async {
    final prefs = await SharedPreferences.getInstance();

    // Load categories
    _allCategories[johkasouId] = await _fetchCategories(johkasouId);
    print('Loaded ${_allCategories[johkasouId]!.length} categories for Johkasou $johkasouId');

    // Initialize controllers and visibility
    for (var category in _allCategories[johkasouId]!) {
      for (var question in category.questions) {
        if (question.type == 'number' || question.type == 'text') {
          _allControllers[johkasouId]![question.id] = TextEditingController();
        }
        _allMainQuestionVisibility[johkasouId]![question.id] = true;
      }
    }

    // Load selected options
    for (var category in _allCategories[johkasouId]!) {
      for (var question in category.questions) {
        if (question.type == 'radio') {
          final key = 'option_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
          final value = prefs.getString(key);
          if (value != null && value.isNotEmpty) {
            _allSelectedOptions[johkasouId]![question.id] = value;
            print('Loaded radio option for Johkasou $johkasouId - Key: $key, Value: $value');
          }
        }
      }
    }

    // Load comments
    for (var category in _allCategories[johkasouId]!) {
      for (var question in category.questions) {
        final key = 'comment_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
        final value = prefs.getString(key);
        if (value != null && value.isNotEmpty) {
          _allQuestionComments[johkasouId]![question.id] = value;
          print('Loaded comment for Johkasou $johkasouId - Key: $key, Value: $value');
        }
      }
    }

    // Load text/number inputs
    for (var category in _allCategories[johkasouId]!) {
      for (var question in category.questions) {
        if (question.type == 'number' || question.type == 'text') {
          final keyPrefix = question.type == 'number' ? 'number' : 'text';
          final key = '${keyPrefix}_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
          final value = prefs.getString(key);
          if (value != null) {
            try {
              if (question.type == 'number') {
                int.parse(value); // Validate integer
              }
              _allControllers[johkasouId]![question.id]!.text = value;
              print('Loaded ${question.type} field for Johkasou $johkasouId - Key: $key, Value: $value');
            } catch (e) {
              print('Invalid value for Johkasou $johkasouId - Key: $key, Value: $value, Error: $e');
            }
          }
        }
      }
    }

    // Load images
    for (var category in _allCategories[johkasouId]!) {
      for (var question in category.questions) {
        final key = 'image_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
        final path = prefs.getString(key);
        if (path != null && path.isNotEmpty && await File(path).exists()) {
          _allQuestionImages[johkasouId]![question.id] = File(path);
          print('Loaded image for Johkasou $johkasouId - Key: $key, Path: $path');
        }
      }
    }

    // Debug: Print loaded data
    print('Loaded data for Johkasou $johkasouId:');
    print('  Selected options: ${_allSelectedOptions[johkasouId]}');
    print('  Comments: ${_allQuestionComments[johkasouId]}');
    print('  Text/Number inputs: ${_allControllers[johkasouId]!.map((k, v) => MapEntry(k, v.text))}');
    print('  Images: ${_allQuestionImages[johkasouId]}');
  }

  Future<List<Category>> _fetchCategories(int johkasouId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/inspector/categories?johkasou_model_id=$johkasouId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categoriesJson = data['categories'] as List<dynamic>? ?? [];
        final categories = categoriesJson
            .map((json) => Category.fromJson(json))
            .toList();
        print('Fetched ${categories.length} categories for Johkasou $johkasouId from API');

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'categories_${widget.maintenanceScheduleId}_$johkasouId',
          json.encode(categoriesJson),
        );
        return categories;
      } else {
        throw Exception('Failed to fetch categories: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories for Johkasou $johkasouId: $e');
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('categories_${widget.maintenanceScheduleId}_$johkasouId');
      if (cached != null) {
        final categoriesJson = json.decode(cached) as List<dynamic>;
        final categories = categoriesJson
            .map((json) => Category.fromJson(json))
            .toList();
        print('Loaded ${categories.length} cached categories for Johkasou $johkasouId');
        return categories;
      }
      print('No cached categories found for Johkasou $johkasouId');
      return [];
    }
  }

  Future<bool> _isAllQuestionsAnswered(int johkasouId) async {
    for (var category in _allCategories[johkasouId]!) {
      for (var question in category.questions) {
        bool isVisible = _allMainQuestionVisibility[johkasouId]![question.id] == true;
        if (isVisible && question.required == 1) {
          if (question.type == 'radio' && _allSelectedOptions[johkasouId]![question.id] == null) {
            return false;
          }
          if ((question.type == 'number' || question.type == 'text') &&
              (_allControllers[johkasouId]![question.id]?.text.isEmpty ?? true)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  Future<void> _saveAllData(int johkasouId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Future> saveFutures = [];

    for (var entry in _allSelectedOptions[johkasouId]!.entries) {
      final key = 'option_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
      final value = entry.value ?? '';
      saveFutures.add(prefs.setString(key, value));
      print('Saving radio option for Johkasou $johkasouId - Key: $key, Value: $value');
    }

    for (var entry in _allQuestionComments[johkasouId]!.entries) {
      final key = 'comment_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
      final value = entry.value ?? '';
      saveFutures.add(prefs.setString(key, value));
      print('Saving comment for Johkasou $johkasouId - Key: $key, Value: $value');
    }

    for (var entry in _allControllers[johkasouId]!.entries) {
      final question = _allCategories[johkasouId]!
          .expand((c) => c.questions)
          .firstWhere(
            (q) => q.id == entry.key,
        orElse: () => Question(
          id: entry.key,
          categoryId: _allCategories[johkasouId]!.isNotEmpty ? _allCategories[johkasouId]!.first.id : 0,
          text: '',
          type: 'text',
          options: [],
        ),
      );
      final keyPrefix = question.type == 'number' ? 'number' : 'text';
      final key = '${keyPrefix}_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
      final value = entry.value.text;
      if (question.type == 'number' && value.isNotEmpty) {
        try {
          int.parse(value);
          saveFutures.add(prefs.setString(key, value));
          print('Saving number field for Johkasou $johkasouId - Key: $key, Value: $value');
        } catch (e) {
          print('Invalid integer for Johkasou $johkasouId - Key: $key, Value: $value, Error: $e');
        }
      } else {
        saveFutures.add(prefs.setString(key, value));
        print('Saving text field for Johkasou $johkasouId - Key: $key, Value: $value');
      }
    }

    for (var entry in _allQuestionImages[johkasouId]!.entries) {
      if (entry.value != null) {
        final key = 'image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
        final value = entry.value!.path;
        saveFutures.add(prefs.setString(key, value));
        print('Saving image for Johkasou $johkasouId - Key: $key, Value: $value');
      }
    }

    await Future.wait(saveFutures);
    print('All data saved to SharedPreferences for Johkasou $johkasouId.');

    if (_redisCommand != null && _isConnected) {
      for (var entry in _allControllers[johkasouId]!.entries) {
        final question = _allCategories[johkasouId]!
            .expand((c) => c.questions)
            .firstWhere(
              (q) => q.id == entry.key,
          orElse: () => Question(
            id: entry.key,
            categoryId: _allCategories[johkasouId]!.isNotEmpty ? _allCategories[johkasouId]!.first.id : 0,
            text: '',
            type: 'text',
            options: [],
          ),
        );
        final keyPrefix = question.type == 'number' ? 'number' : 'text';
        final key = '${keyPrefix}_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}';
        final value = entry.value.text;
        if (question.type == 'number' && value.isNotEmpty) {
          try {
            int.parse(value);
            await _saveToRedis(key, value);
            print('Saved to Redis for Johkasou $johkasouId - Key: $key, Value: $value');
          } catch (e) {
            print('Invalid integer for Redis Johkasou $johkasouId - Key: $key, Value: $value, Error: $e');
          }
        } else {
          await _saveToRedis(key, value);
          print('Saved to Redis for Johkasou $johkasouId - Key: $key, Value: $value');
        }
      }
    }
  }

  Future<void> _saveToRedis(String key, String value) async {
    if (_redisCommand == null) return;
    try {
      await _redisCommand!.send_object(['SET', key, value]).timeout(Duration(seconds: 2));
      await _redisCommand!.send_object(['EXPIRE', key, '86400']).timeout(Duration(seconds: 2));
      print('Redis save successful - Key: $key, Value: $value');
    } catch (e) {
      print('Redis error during save: $e');
    }
  }

  Future<bool> _isRedisConnected() async {
    if (_redisCommand == null) return false;
    try {
      await _redisCommand!.send_object(['PING']).timeout(Duration(seconds: 2));
      return true;
    } catch (e) {
      print('Redis connection error: $e');
      return false;
    }
  }

  Future<void> _uploadPendingMedia(int johkasouId) async {
    final prefs = await SharedPreferences.getInstance();
    final uploadFutures = <Future<bool>>[];

    for (var entry in _allQuestionImages[johkasouId]!.entries) {
      if (entry.value != null) {
        uploadFutures.add(_uploadImage(
          entry.key,
          entry.value!,
          widget.maintenanceScheduleId,
          johkasouId,
        ).then((success) async {
          if (success) {
            await prefs.remove('image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}');
            if (_redisCommand != null) {
              try {
                await _redisCommand!.send_object(['DEL', 'image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}']);
                print('Removed Redis image key: image_${widget.maintenanceScheduleId}_${johkasouId}_${entry.key}');
              } catch (e) {
                print('Redis error while deleting image key: $e');
              }
            }
          }
          return success;
        }));
      }
    }

    await Future.wait(uploadFutures);
  }

  Future<bool> _uploadImage(int questionId, File imageFile, int maintenanceScheduleId, int johkasouId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${DaikiAPI.api_key}/api/v1/image/store'),
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

      request.files.add(await http.MultipartFile.fromPath(
        'media',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send().timeout(Duration(seconds: 5));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Image upload response for Johkasou $johkasouId: $responseData');
        return (responseData['status'] as bool?) == true || (responseData['success'] as bool?) == true;
      } else {
        throw Exception('Failed to upload image for Johkasou $johkasouId: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image for Johkasou $johkasouId: $e');
      return false;
    }
  }

  Future<void> _submitAllAnswers() async {
    setState(() => _isSubmitting = true);

    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No authentication token found');

      String? userId = await TokenManager.getUserId();
      if (userId == null) throw Exception('User ID not found');

      // Prepare the request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance/stp-final-submit'),
      );

      // Set headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
      request.fields['user_id'] = userId;

      // For debugging
      print('Submitting final maintenance with ID: ${widget.maintenanceScheduleId}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true || responseData['success'] == true) {
          print('Final submission successful for maintenance ${widget.maintenanceScheduleId}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MultiSubmissionSuccessScreen(
                maintenanceId: widget.maintenanceScheduleId.toString(),
                projectId: widget.projectId,
                johkasouIds: widget.johkasouIds,
                projectName: widget.projectName,
                nextMaintenanceDate: widget.nextMaintenanceDate,
              ),
            ),
          );
        } else {
          throw Exception('Server returned false status: ${response.body}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Submission error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<List<Widget>> _buildPreviewSections(int johkasouId) async {
    List<Widget> sections = [];

    if (_allCategories[johkasouId]!.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  'Data Loading: $johkasouId...',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      ];
    }

    for (var category in _allCategories[johkasouId]!) {
      List<Widget> categoryQuestions = [];

      for (var question in category.questions) {
        if (_allMainQuestionVisibility[johkasouId]![question.id] == true) {
          String answer = '';
          String comment = _allQuestionComments[johkasouId]![question.id] ?? '';
          File? image = _allQuestionImages[johkasouId]![question.id];

          if (question.type == 'radio') {
            final selectedOption = _allSelectedOptions[johkasouId]![question.id];
            if (selectedOption != null && selectedOption.isNotEmpty) {
              answer = selectedOption;
            } else {
              final key = 'option_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
              final prefs = await SharedPreferences.getInstance();
              final value = prefs.getString(key);
              answer = value ?? '(No selection)';
            }
          } else if (question.type == 'number') {
            final controller = _allControllers[johkasouId]![question.id];
            if (controller != null && controller.text.isNotEmpty) {
              try {
                int.parse(controller.text);
                answer = controller.text;
              } catch (e) {
                answer = '(Invalid integer: ${controller.text})';
              }
            } else {
              final key = 'number_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
              final prefs = await SharedPreferences.getInstance();
              final value = prefs.getString(key);
              if (value != null && value.isNotEmpty) {
                try {
                  int.parse(value);
                  answer = value;
                } catch (e) {
                  answer = '(Invalid integer in SharedPreferences: $value)';
                }
              } else {
                answer = '(No data)';
              }
            }
          } else if (question.type == 'text') {
            final controller = _allControllers[johkasouId]![question.id];
            if (controller != null && controller.text.isNotEmpty) {
              answer = controller.text;
            } else {
              final key = 'text_${widget.maintenanceScheduleId}_${johkasouId}_${question.id}';
              final prefs = await SharedPreferences.getInstance();
              final value = prefs.getString(key);
              answer = value ?? '(No data)';
            }
          }

          if (answer.isNotEmpty && answer != '(No data)' || comment.isNotEmpty || image != null) {
            categoryQuestions.add(
              Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.teal.shade100, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      if (answer.isNotEmpty && !answer.startsWith('(Invalid') && answer != '(No data)')
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: Colors.teal, size: 20),
                              SizedBox(width: 8),
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
                                    SizedBox(height: 4),
                                    Text(
                                      answer,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (comment.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.comment, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
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
                                      SizedBox(height: 4),
                                      Text(
                                        comment,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (image != null)
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.image, color: Colors.purple, size: 20),
                                  SizedBox(width: 8),
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
                              SizedBox(height: 8),
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
                                      print('Error loading image for Johkasou $johkasouId, Question ${question.id}: $error');
                                      return Text('Failed to load image');
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      }

      if (categoryQuestions.isNotEmpty) {
        sections.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              ...categoryQuestions,
              SizedBox(height: 24),
            ],
          ),
        );
      }
    }

    if (sections.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No answers, comments, or images found for Johkasou ID: $johkasouId.',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      ];
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multi Johkasou Review',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Review Information'),
                  content: Text('Review answers for all Johkasou models before submission.'),
                  actions: [
                    TextButton(
                      child: Text('Understood'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.teal.shade100,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: widget.johkasouIds.map((johkasouId) {
            return Tab(
              child: Text(
                'Johkasou ID: $johkasouId',
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      size: 40,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Multi Johkasou Review',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Project: ${widget.projectName}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'Next Maintenance: ${widget.nextMaintenanceDate?.toString().split(' ')[0] ?? 'Not specified'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.johkasouIds.map((johkasouId) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 80),
                    child: FutureBuilder<List<Widget>>(
                      future: _buildPreviewSections(johkasouId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          print('Error building preview for Johkasou $johkasouId: ${snapshot.error}');
                          return Center(
                            child: Text(
                              'Error loading data for Johkasou $johkasouId: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Column(children: snapshot.data!);
                        } else {
                          return Center(
                            child: Text('No data available for Johkasou $johkasouId'),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _isSubmitting
                ? null
                : () {
              _submitAllAnswers();
            },
            backgroundColor: Colors.teal,
            label: Row(
              children: [
                _isSubmitting
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  _isSubmitting ? 'Submitting...' : 'Submit All',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(width: 16), // Spacing between buttons
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: Colors.grey,
            label: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Adjust position

    );
  }
}

class MultiSubmissionSuccessScreen extends StatelessWidget {
  final String maintenanceId;
  final int projectId;
  final List<int> johkasouIds;
  final String projectName;
  final DateTime? nextMaintenanceDate;

  const MultiSubmissionSuccessScreen({
    Key? key,
    required this.maintenanceId,
    required this.projectId,
    required this.johkasouIds,
    required this.projectName,
    required this.nextMaintenanceDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
            stops: [0.0, 0.5],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Submission Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Maintenance reports for all Johkasou models have been submitted.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Maintenance ID: $maintenanceId',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  'Project: $projectName',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  'Johkasou IDs: ${johkasouIds.join(', ')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  'Next Maintenance: ${nextMaintenanceDate?.toString().split(' ')[0] ?? 'Not specified'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: Icon(Icons.home),
                  label: Text('Return to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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