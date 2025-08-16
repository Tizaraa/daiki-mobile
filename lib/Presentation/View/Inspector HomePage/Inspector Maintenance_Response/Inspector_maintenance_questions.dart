import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';
import 'Inspector_quiz_screen.dart';

class InspectorMaintenanceQuestionpage extends StatefulWidget {
  final int maintenanceScheduleId;
  final int projectId;
  final int johkasouId;
  final String project_name;
  final String next_maintenance_date;

  const InspectorMaintenanceQuestionpage({
    Key? key,
    required this.maintenanceScheduleId,
    required this.projectId,
    required this.project_name,
    required this.next_maintenance_date,
    required this.johkasouId,
  }) : super(key: key);

  @override
  State createState() => _InspectorMaintenanceQuestionpageState();
}

class _InspectorMaintenanceQuestionpageState extends State<InspectorMaintenanceQuestionpage>
    with TickerProviderStateMixin {
  List<dynamic> inspectionItems = [];
  bool isAgreed = false;
  bool _isLoading = false;
  bool _hasSeenQuestions = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Future<void> checkIfQuestionsViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final viewedQuestions = prefs.getStringList('viewed_maintenance_questions') ?? [];

    if (viewedQuestions.contains(widget.maintenanceScheduleId.toString())) {
      setState(() {
        _hasSeenQuestions = true;
      });
      // Directly navigate to quiz screen if questions were already viewed
      _navigateToQuiz();
    } else {
      // Load questions if not viewed before
      await Downloadjson();
    }
  }

  Future<void> markQuestionsAsViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final viewedQuestions = prefs.getStringList('viewed_maintenance_questions') ?? [];

    if (!viewedQuestions.contains(widget.maintenanceScheduleId.toString())) {
      viewedQuestions.add(widget.maintenanceScheduleId.toString());
      await prefs.setStringList('viewed_maintenance_questions', viewedQuestions);
    }
  }

  Future<void> Downloadjson() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse("${DaikiAPI.api_key}/api/v1/stp-data/perform-for-johkasou-model/${widget.maintenanceScheduleId}?johkasou_model_id=${widget.johkasouId}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('date') &&
            responseData['date'].containsKey('inspection') &&
            responseData['date']['inspection'] is List) {

          setState(() {
            inspectionItems = responseData['date']['inspection']
                .where((item) =>
            item['inspection_question'] != null &&
                item['inspection_question']['required'] == 1)
                .toList();
          });
        } else {
          throw Exception("Invalid response format: Required data structure not found");
        }
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      print("Error loading data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load inspection questions. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InspectorQuizScreen(
          maintenanceScheduleId: widget.maintenanceScheduleId,
          johkasouId: widget.johkasouId ?? 210,
          project_name: widget.project_name,
          next_maintenance_date: widget.next_maintenance_date,
          projectId: widget.projectId,
        ),
      ),
    );
  }


  void _checkAndNavigate() async {
    if (isAgreed) {
      await markQuestionsAsViewed();
      _navigateToQuiz();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept all terms to continue.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfQuestionsViewed();

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
    // If questions have been seen before, return empty container (will be replaced by navigation)
    if (_hasSeenQuestions) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Terms & Conditions',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold,fontSize: 19),
        ),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [TizaraaColors.Tizara, Colors.white],
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...inspectionItems.map((item) => Padding(
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
                                item['inspection_question']['text'] ?? 'No text',
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: 24),
                      const Text(
                        'Note: You must agree to all of the above conditions to proceed to the next page.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: isAgreed,
                      onChanged: (value) {
                        setState(() {
                          isAgreed = value ?? false;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    const Expanded(
                      child: Text(
                        'I have read and agree to all the above conditions',
                        style: TextStyle(
                          fontSize: 12,
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
                    onPressed: _checkAndNavigate,
                    child: const Text('Next'),
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