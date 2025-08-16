import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';
import '../../../Core/Utils/colors.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/quiz_screen.dart';

class InspectorQuestionpage extends StatefulWidget {
  final int maintenanceScheduleId;
  final int projectId;
  final int johkasouId;
  final String project_name;
  final String next_maintenance_date;

  const InspectorQuestionpage({
    Key? key,
    required this.maintenanceScheduleId,
    required this.projectId,
    required this.johkasouId,
    required this.project_name,
    required this.next_maintenance_date,
  }) : super(key: key);

  @override
  State<InspectorQuestionpage> createState() => _InspectorQuestionpageState();
}

class _InspectorQuestionpageState extends State<InspectorQuestionpage>
    with TickerProviderStateMixin {
  List<dynamic> posts = [];
  int? apiStatus;
  bool isAgreed = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse(
            "${DaikiAPI.api_key}/api/v1/stp-data/perform-for-johkasou-model/${widget.maintenanceScheduleId}?johkasou_model_id=${widget.johkasouId}"),

        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Decoded Response: $responseData');

        setState(() {
          // Handle status - ensure we properly capture the status
          if (responseData.containsKey('status')) {
            apiStatus = responseData['status'] == true ? 1 : 0;
          } else {
            apiStatus = 0; // Default to 0 if status not provided
          }

          // Handle data - more robust checking
          if (responseData.containsKey('data')) {
            if (responseData['data'] is List) {
              posts = responseData['data'];
              print('Posts loaded: ${posts.length} items');
            } else if (responseData['data'] is Map) {
              // If data is a Map, convert to List
              posts = [responseData['data']];
            }
          } else {
            posts = [];
          }
        });
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (error) {
      print('Error fetching questions: $error');
      setState(() {
        _errorMessage = "Error loading data: $error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? 'Failed to load questions. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _submitResponses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenManager.getToken();
      final responses = posts.map((post) => {
        "id": post['id'] ?? 0,
        "response": 1,
      }).toList();

      final body = json.encode({
        "schedule_id": widget.maintenanceScheduleId,
        "johkasou_model_id": widget.johkasouId,
        "response": responses,
      });

      final response = await http.post(
        Uri.parse("${DaikiAPI.api_key}/api/v1/inspection-questions-response-with-model"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Failed to submit responses: ${response.statusCode}");
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Error submitting responses: $error";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? 'Failed to submit responses. Please try again.')),
      );
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAndNavigate() async {
    if (apiStatus == 1) {
      _navigateToQuizScreen();
    } else if (isAgreed && posts.isNotEmpty) {
      bool success = await _submitResponses();
      if (success) {
        _navigateToQuizScreen();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            posts.isEmpty
                ? 'No questions available to proceed.'
                : 'Please accept all terms to continue.',
          ),
        ),
      );
    }
  }

  void _navigateToQuizScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuizScreen(
          maintenanceScheduleId: widget.maintenanceScheduleId,
          projectId: widget.projectId,
          project_name: widget.project_name,
          next_maintenance_date: widget.next_maintenance_date,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              FadeTransition(
                opacity: animation,
                child: child,
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchQuestions();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Technician Terms & Conditions',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [TizaraaColors.Tizara.withOpacity(0.7), Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please read and agree to the following terms:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'By agreeing to these terms, you confirm that:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (posts.isEmpty)
                        const Text(
                          'No terms available at this time.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      else
                        ...posts.map((post) {
                          print('Post item: $post');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    post['text']?.toString() ??
                                        post['question']?.toString() ??
                                        post['description']?.toString() ??
                                        'No text available',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      const SizedBox(height: 24),
                      const Text(
                        'Note: You must agree to all conditions to proceed.',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (posts.isNotEmpty)
                  Row(
                    children: [
                      Checkbox(
                        value: isAgreed,
                        onChanged: (value) {
                          setState(() {
                            isAgreed = value ?? false;
                          });
                        },
                        activeColor: TizaraaColors.Tizara,
                      ),
                      const Expanded(
                        child: Text(
                          'I have read and agree to all the above conditions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TizaraaColors.Tizara,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: _isLoading ? null : _checkAndNavigate,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Next'),
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