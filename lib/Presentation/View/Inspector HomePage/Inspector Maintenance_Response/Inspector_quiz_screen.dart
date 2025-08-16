import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redis/redis.dart';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../Authentication/login_screen.dart';
import 'Inspector_preview_page.dart';
import 'dart:io';
import '../Inspector Maintenance_Response/Inspector_quiz_Api_service.dart';
import '../Inspector Maintenance_Response/Inspector_data_validator.dart';
import '../Inspector Maintenance_Response/Inspector_quiz_model.dart';

class InspectorQuizScreen extends StatefulWidget {
  final int maintenanceScheduleId;
  final int johkasouId;
  final int projectId;
  final String project_name;
  final String next_maintenance_date;

  const InspectorQuizScreen({
    Key? key,
    required this.maintenanceScheduleId,
    required this.johkasouId,
    required this.project_name,
    required this.next_maintenance_date,
    required this.projectId,
  }) : super(key: key);

  @override
  _InspectorQuizScreenState createState() => _InspectorQuizScreenState();
}

class _InspectorQuizScreenState extends State<InspectorQuizScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  List<Category> categories = [];
  bool isLoading = true;
  String? error;
  bool isSubmitting = false;
  String locationInfo = '';
  String ipInfo = '';
  String deviceInfo = '';
  Map<int, String?> selectedOptions = {};
  Map<int, File?> questionImages = {};
  Map<int, File?> questionVideos = {};
  Map<int, String?> questionComments = {};
  Set<int> touchedQuestions = {};
  int currentCategoryIndex = 0;
  Map<int, List<Question>> relatedQuestions = {};
  Map<int, bool> relatedQuestionsVisibility = {};
  List<Question> visibleQuestions = [];
  Map<int, bool> mainQuestionVisibility = {};
  final Map<int, TextEditingController> controllers = {};

  // Dynamic dependency tracking
  Map<int, List<int>> questionDependencies = {};
  Map<int, int> dependentToParent = {};
  List<Question> parentQuestions = [];

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  Command? redisCommand;
  bool _isProcessingPendingUploads = false;
  late Box _quizBox;

  @override
  void initState() {
    super.initState();
    print('InspectorQuizScreen initialized with johkasouId: ${widget.johkasouId}');
    _initializeHive();
    _initializeRedis();
    _loadQuizData();
    _checkSessionValidity();
    _checkInitialConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initializeHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    _quizBox = await Hive.openBox('inspector_quiz');
    // Load last category index from Hive
    final savedIndex = _quizBox.get('last_category_index_${widget.maintenanceScheduleId}_${widget.johkasouId}');
    if (savedIndex != null && savedIndex is int && savedIndex >= 0 && savedIndex < categories.length) {
      currentCategoryIndex = savedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && error == null) {
      print('Rendering questions for category: ${categories[currentCategoryIndex].name}');
      print('Visible questions count: ${visibleQuestions.length}');
      for (var question in visibleQuestions) {
        print('  Visible Question: ${question.text} (ID: ${question.id}, Visible: ${mainQuestionVisibility[question.id]})');
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.project_name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: _loadQuizData,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                children: [
                  // Category selection row
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              '${index + 1}. ${categories[index].name}',
                              style: TextStyle(
                                color: currentCategoryIndex == index ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: currentCategoryIndex == index,
                            selectedColor: Colors.teal,
                            onSelected: (selected) {
                              if (selected && _formKey.currentState!.validate()) {
                                setState(() {
                                  currentCategoryIndex = index;
                                });
                                _saveCategoryIndex();
                                _updateVisibleQuestions();
                              }
                            },
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadQuizData,
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 150),
                        children: [
                          Card(
                            color: Colors.white,
                            margin: const EdgeInsets.all(16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    categories[currentCategoryIndex].name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildQuestionsForCategory(categories[currentCategoryIndex]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                      SizedBox(
                        width: 90,
                        child: currentCategoryIndex > 0
                            ? MaterialButton(
                          color: Colors.blue,
                          onPressed: _previousCategory,
                          child: const Text(
                            'Previous',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                            : const SizedBox(),
                      ),
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: (currentCategoryIndex + 1) / categories.length,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                                  strokeWidth: 5,
                                ),
                              ),
                              Text(
                                '${(((currentCategoryIndex + 1) / categories.length) * 100).round()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currentCategoryIndex + 1}/${categories.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 85,
                        child: _isAllQuestionsAnswered() && currentCategoryIndex == categories.length - 1
                            ? MaterialButton(
                          color: Colors.deepOrange,
                          onPressed: isSubmitting ? null : _navigateToAnswersPreview,
                          child: isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Review',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                            : MaterialButton(
                          color: Colors.teal,
                          onPressed: _nextCategory,
                          child: const Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadQuizData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await _initializeHive();
      final data = await _apiService.fetchCategories(
        widget.maintenanceScheduleId,
        widget.johkasouId,
        widget.projectId,
      );

      print('Fetched categories for johkasouId ${widget.johkasouId}:');
      for (var category in data) {
        print('  Category: ${category.name}, Questions: ${category.questions.map((q) => q.text).toList()}');
      }

      DataValidator.validateAndLogQuestions(
        data,
        'API',
        maintenanceScheduleId: widget.maintenanceScheduleId,
        johkasouId: widget.johkasouId,
      );

      if (!mounted) return;
      setState(() {
        categories = data;
        isLoading = false;
      });

      await _loadLocalData();
      DataValidator.validateAndLogQuestions(
        categories,
        'Local Storage',
        maintenanceScheduleId: widget.maintenanceScheduleId,
        johkasouId: widget.johkasouId,
      );

      _analyzeDependencies();
      _processDependentQuestions();
      _initializeMainQuestionVisibility();
      _updateVisibleQuestions();

      DataValidator.validateAndLogQuestions(
        categories,
        'After Visibility Update',
        maintenanceScheduleId: widget.maintenanceScheduleId,
        johkasouId: widget.johkasouId,
      );

      await _loadFromRedis();
      DataValidator.validateAndLogQuestions(
        categories,
        'Redis',
        maintenanceScheduleId: widget.maintenanceScheduleId,
        johkasouId: widget.johkasouId,
      );
    } catch (e) {
      print('Error in _loadQuizData for johkasouId ${widget.johkasouId}: $e');
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _analyzeDependencies() {
    questionDependencies.clear();
    dependentToParent.clear();
    parentQuestions.clear();

    print('=== Analyzing Question Dependencies ===');
    for (var category in categories) {
      print('Analyzing category: ${category.name}');
      List<Question> potentialParents = category.questions
          .where((q) => q.options.isNotEmpty && q.options.length > 1 && _isLikelyParentQuestion(q))
          .toList();

      for (var parentQuestion in potentialParents) {
        print('Found potential parent question: ${parentQuestion.text} (ID: ${parentQuestion.id})');
        parentQuestions.add(parentQuestion);

        for (var option in parentQuestion.options) {
          List<Question> relatedQuestions = _findQuestionsRelatedToOption(category, parentQuestion, option);
          if (relatedQuestions.isNotEmpty) {
            questionDependencies[option.id] = relatedQuestions.map((q) => q.id).toList();
            for (var relatedQuestion in relatedQuestions) {
              dependentToParent[relatedQuestion.id] = parentQuestion.id;
            }
            print('Option "${option.text}" (ID: ${option.id}) controls ${relatedQuestions.length} questions:');
            for (var related in relatedQuestions) {
              print('  - ${related.text} (ID: ${related.id})');
            }
          }
        }
      }
    }
    print('=== Dependency Analysis Complete ===');
    print('Parent questions: ${parentQuestions.length}');
    print('Dependencies: ${questionDependencies.length}');
  }

  bool _isLikelyParentQuestion(Question question) {
    String questionText = question.text.toLowerCase();
    List<String> parentIndicators = [
      'type',
      'kind',
      'category',
      'select',
      'choose',
      'which',
      'what type',
      'pump',
      'system',
      'method',
      'mode',
      'option',
      'variant'
    ];

    for (String indicator in parentIndicators) {
      if (questionText.contains(indicator)) {
        return true;
      }
    }

    if (question.options.length > 2) {
      return true;
    }

    return false;
  }

  List<Question> _findQuestionsRelatedToOption(Category category, Question parentQuestion, Option option) {
    List<Question> relatedQuestions = [];
    String optionText = option.text.toLowerCase();

    if (_isGenericOption(optionText)) {
      return relatedQuestions;
    }

    for (var question in category.questions) {
      if (question.id == parentQuestion.id) continue;

      String questionText = question.text.toLowerCase();
      if (questionText.contains(optionText)) {
        relatedQuestions.add(question);
        continue;
      }

      List<String> optionKeywords = _extractKeywords(optionText);
      for (String keyword in optionKeywords) {
        if (keyword.length > 3 && questionText.contains(keyword)) {
          relatedQuestions.add(question);
          break;
        }
      }
    }

    return relatedQuestions;
  }

  bool _isGenericOption(String optionText) {
    List<String> genericOptions = [
      'yes',
      'no',
      'n/a',
      'none',
      'other',
      'all',
      'any',
      'both',
      'either'
    ];
    return genericOptions.contains(optionText);
  }

  List<String> _extractKeywords(String text) {
    return text
        .split(RegExp(r'[\s\-_/]+'))
        .where((word) => word.length > 2)
        .map((word) => word.toLowerCase())
        .toList();
  }

  Future<void> _initializeRedis() async {
    const int maxRetries = 1;
    int retries = 0;
    const String redisPassword = 'password';

    while (retries < maxRetries) {
      try {
        final redisConnection = RedisConnection();
        redisCommand = await redisConnection
            .connect('145.223.88.141', 6379)
            .timeout(const Duration(seconds: 5), onTimeout: () => throw Exception('Connection timeout'));

        await redisCommand!.send_object(['AUTH', redisPassword]).timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw Exception('Authentication timeout'),
        );

        try {
          await redisCommand!.send_object(['SET', 'test_key', 'test_value']).timeout(const Duration(seconds: 2));
          print('Redis connected, authenticated, and writable in InspectorQuizScreen');
        } catch (e) {
          print('Redis is read-only in InspectorQuizScreen: $e');
          redisCommand = null;
        }
        return;
      } catch (e) {
        retries++;
        print('Redis connection failed (attempt $retries/$maxRetries): $e');
        if (retries == maxRetries) {
          redisCommand = null;
          print('Redis initialization failed after max retries');
          return;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _saveToRedis(String key, String value) async {
    if (redisCommand == null || !await _isRedisConnected()) {
      await _initializeRedis();
      if (redisCommand == null) {
        print('Redis command is null, skipping save for $key (johkasouId: ${widget.johkasouId})');
        return;
      }
    }

    try {
      var info = await redisCommand!.send_object(['INFO', 'REPLICATION']).timeout(const Duration(seconds: 5));
      if (info.contains('role:slave')) {
        print('Redis is read-only, skipping write for $key (johkasouId: ${widget.johkasouId})');
        return;
      }

      await redisCommand!.send_object(['SET', key, value]).timeout(const Duration(seconds: 10));
      await redisCommand!.send_object(['EXPIRE', key, 3600]).timeout(const Duration(seconds: 10));
      print('Successfully stored in Redis for johkasouId ${widget.johkasouId}: $key = $value');
    } catch (e) {
      if (e.toString().contains('READONLY')) {
        print('Redis is read-only, skipping write for $key (johkasouId: ${widget.johkasouId})');
      } else {
        print('Redis error while storing data for johkasouId ${widget.johkasouId}: $e');
        redisCommand = null;
        await _initializeRedis();
      }
    }
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    _apiService.close();
    _connectivity.onConnectivityChanged.drain();
    Hive.close();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;
    setState(() {
      _isConnected = (result != ConnectivityResult.none);
    });

    if (!_isConnected) {
      _showNoInternetDialog();
    } else if (!_isProcessingPendingUploads) {
      print('Internet connection restored, checking for pending uploads');
      _isProcessingPendingUploads = true;
      _processPendingUploads().then((_) {
        _isProcessingPendingUploads = false;
      });
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your network connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadLocalData() async {
    for (var category in categories) {
      for (var question in category.questions) {
        String optionKey = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
        if (_quizBox.containsKey(optionKey)) {
          selectedOptions[question.id] = _quizBox.get(optionKey);
        }

        String commentKey = 'comment_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
        if (_quizBox.containsKey(commentKey)) {
          questionComments[question.id] = _quizBox.get(commentKey);
        }

        if (question.type == 'number' || question.type == 'text') {
          String numberKey = 'number_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
          String? savedValue = _quizBox.get(numberKey);
          if (savedValue != null) {
            controllers[question.id] = TextEditingController(text: savedValue);
            selectedOptions[question.id] = savedValue;
            print('Loaded from Hive: $numberKey = $savedValue');
          } else {
            controllers[question.id] = TextEditingController(text: '');
          }
        }

        String imageKey = 'image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
        if (_quizBox.containsKey(imageKey)) {
          final path = _quizBox.get(imageKey);
          if (path != null && File(path).existsSync()) {
            questionImages[question.id] = File(path);
          }
        }

        String videoKey = 'video_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
        if (_quizBox.containsKey(videoKey)) {
          final path = _quizBox.get(videoKey);
          if (path != null && File(path).existsSync()) {
            questionVideos[question.id] = File(path);
          }
        }
      }
    }

    deviceInfo = _quizBox.get('device_info_${widget.maintenanceScheduleId}_${widget.johkasouId}') ?? 'Unknown';
    ipInfo = _quizBox.get('ip_info_${widget.maintenanceScheduleId}_${widget.johkasouId}') ?? 'Unknown';
    locationInfo = _quizBox.get('location_info_${widget.maintenanceScheduleId}_${widget.johkasouId}') ?? 'Unknown';

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _saveOptionToStorage(int questionId, String value) async {
    try {
      String key = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_$questionId';
      await _quizBox.put(key, value);
      if (redisCommand != null) {
        await _saveToRedis(key, value);
      }
    } catch (e) {
      print('Error saving option for question $questionId: $e');
    }
  }

  Future<void> _navigateToAnswersPreview() async {
    try {
      print('Preparing to navigate to AnswersPreviewScreen...');

      final Map<int, bool> copiedVisibility = Map<int, bool>.from(mainQuestionVisibility);
      final Map<int, TextEditingController> copiedControllers = {};

      for (var category in categories) {
        for (var question in category.questions) {
          if ((question.type == 'number' || question.type == 'text' || question.type == 'String') &&
              selectedOptions.containsKey(question.id) &&
              !copiedControllers.containsKey(question.id)) {
            copiedControllers[question.id] = TextEditingController(text: selectedOptions[question.id] ?? '');
          }
        }
      }

      final Map<int, String?> allOptions = Map<int, String?>.from(selectedOptions);
      final Map<int, String?> allComments = Map<int, String?>.from(questionComments);
      final Map<int, File?> allImages = Map<int, File?>.from(questionImages);
      final Map<int, TextEditingController> allControllers = {};

      // Copy all controllers
      for (var entry in controllers.entries) {
        allControllers[entry.key] = TextEditingController(text: entry.value.text);
      }

      print('Navigating to AnswersPreviewScreen with all data:');
      print('All Options count: ${allOptions.length}');
      print('All Comments count: ${allComments.length}');
      print('All Images count: ${allImages.length}');
      print('All Controllers count: ${allControllers.length}');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswersPreviewScreen(
            maintenanceScheduleId: widget.maintenanceScheduleId,
            johkasouId: widget.johkasouId,
            projectId: widget.projectId,
            selectedOptions: allOptions,
            questionImages: allImages,
            questionComments: allComments,
            categories: categories,
            mainQuestionVisibility: copiedVisibility,
            controllers: allControllers,
            isConnected: _isConnected,
            redisCommand: redisCommand,
          ),
        ),
      );

      _processBackgroundTasks();
    } catch (e) {
      print('Error in _submitAnswers: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _submitAnswers() async {
    if (!_isAllQuestionsAnswered()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all required questions')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await _saveCriticalData();

      final Map<int, String?> copiedOptions = Map.from(selectedOptions);
      final Map<int, String?> copiedComments = Map.from(questionComments);
      final Map<int, File?> copiedImages = Map.from(questionImages);
      final Map<int, TextEditingController> copiedControllers = {};
      final Map<int, bool> copiedVisibility = Map.from(mainQuestionVisibility);

      controllers.forEach((id, controller) {
        copiedControllers[id] = TextEditingController(text: controller.text);
      });

      for (var category in categories) {
        for (var question in category.questions) {
          if ((question.type == 'number' || question.type == 'text' || question.type == 'String') &&
              selectedOptions.containsKey(question.id) &&
              !copiedControllers.containsKey(question.id)) {
            copiedControllers[question.id] = TextEditingController(text: selectedOptions[question.id] ?? '');
          }
        }
      }

      final Map<int, String?> filteredOptions = {};
      final Map<int, String?> filteredComments = {};
      final Map<int, File?> filteredImages = {};
      final Map<int, TextEditingController> filteredControllers = {};

      for (var category in categories) {
        for (var question in category.questions) {
          bool shouldInclude = false;
          bool isVisible = mainQuestionVisibility[question.id] == true;
          bool hasAnswer = selectedOptions.containsKey(question.id) ||
              questionComments.containsKey(question.id) ||
              questionImages.containsKey(question.id) ||
              (controllers.containsKey(question.id) && controllers[question.id]!.text.isNotEmpty);

          if (isVisible && hasAnswer) {
            shouldInclude = true;
          }

          if (shouldInclude) {
            if (selectedOptions.containsKey(question.id)) {
              filteredOptions[question.id] = selectedOptions[question.id];
            }
            if (questionComments.containsKey(question.id)) {
              filteredComments[question.id] = questionComments[question.id];
            }
            if (questionImages.containsKey(question.id)) {
              filteredImages[question.id] = questionImages[question.id];
            }
            if (controllers.containsKey(question.id)) {
              filteredControllers[question.id] = TextEditingController(text: controllers[question.id]!.text);
            }
          }
        }
      }

      print('Navigating to AnswersPreviewScreen with filtered data:');
      print('Filtered Options count: ${filteredOptions.length}');
      print('Filtered Comments count: ${filteredComments.length}');
      print('Filtered Images count: ${filteredImages.length}');
      print('Filtered Controllers count: ${filteredControllers.length}');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnswersPreviewScreen(
            maintenanceScheduleId: widget.maintenanceScheduleId,
            johkasouId: widget.johkasouId,
            projectId: widget.projectId,
            selectedOptions: filteredOptions,
            questionImages: filteredImages,
            questionComments: filteredComments,
            categories: categories,
            mainQuestionVisibility: copiedVisibility,
            controllers: filteredControllers,
            isConnected: _isConnected,
            redisCommand: redisCommand,
          ),
        ),
      );

      _processBackgroundTasks();
    } catch (e) {
      print('Error in _submitAnswers: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _saveCriticalData() async {
    final List<Future> saveFutures = [];

    for (var entry in selectedOptions.entries) {
      final key = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
      saveFutures.add(_quizBox.put(key, entry.value ?? ''));
    }

    for (var entry in questionComments.entries) {
      final key = 'comment_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
      saveFutures.add(_quizBox.put(key, entry.value ?? ''));
    }

    await Future.wait(saveFutures);
  }

  Future<void> _processBackgroundTasks() async {
    try {
      final List<Future> saveFutures = [];

      for (var entry in controllers.entries) {
        final key = 'number_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
        saveFutures.add(_quizBox.put(key, entry.value.text));
      }

      for (var entry in questionImages.entries) {
        if (entry.value != null) {
          final key = 'image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
          saveFutures.add(_quizBox.put(key, entry.value!.path));
        }
      }

      await Future.wait(saveFutures);

      if (_isConnected) {
        await _uploadPendingMedia(widget.maintenanceScheduleId, widget.johkasouId);
      }
    } catch (e) {
      debugPrint('Background task error: $e');
    }
  }

  Future<void> _saveAllData() async {
    final List<Future> saveFutures = [];
    print('Saving all data in InspectorQuizScreen...');

    for (var entry in selectedOptions.entries) {
      final key = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
      final value = entry.value ?? '';
      saveFutures.add(_quizBox.put(key, value));
      print('Saving radio option - Key: $key, Value: $value');
    }

    for (var entry in questionComments.entries) {
      final key = 'comment_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
      final value = entry.value ?? '';
      saveFutures.add(_quizBox.put(key, value));
      print('Saving comment - Key: $key, Value: $value');
    }

    for (var entry in controllers.entries) {
      final key = 'number_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
      final value = entry.value.text;
      saveFutures.add(_quizBox.put(key, value));
      print('Saving number/text field - Key: $key, Value: $value');
    }

    for (var entry in questionImages.entries) {
      if (entry.value != null) {
        final key = 'image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
        final value = entry.value!.path;
        saveFutures.add(_quizBox.put(key, value));
        print('Saving image - Key: $key, Value: $value');
      }
    }

    for (var entry in questionVideos.entries) {
      if (entry.value != null) {
        final key = 'video_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
        final value = entry.value!.path;
        saveFutures.add(_quizBox.put(key, value));
        print('Saving video - Key: $key, Value: $value');
      }
    }

    saveFutures.add(_quizBox.put('device_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', deviceInfo));
    saveFutures.add(_quizBox.put('ip_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', ipInfo));
    saveFutures.add(_quizBox.put('location_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', locationInfo));

    await Future.wait(saveFutures);
    print('All data saved in InspectorQuizScreen.');

    // Save current category index
    await _saveCategoryIndex();

    if (redisCommand != null) {
      for (var entry in selectedOptions.entries) {
        final key = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
        final value = entry.value ?? '';
        await _saveToRedis(key, value);
      }

      for (var entry in questionComments.entries) {
        final key = 'comment_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
        final value = entry.value ?? '';
        await _saveToRedis(key, value);
      }

      for (var entry in controllers.entries) {
        final key = 'number_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
        final value = entry.value.text;
        await _saveToRedis(key, value);
      }

      for (var entry in questionImages.entries) {
        if (entry.value != null) {
          final key = 'image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
          await _saveMediaToRedis(key, entry.value!);
        }
      }

      for (var entry in questionVideos.entries) {
        if (entry.value != null) {
          final key = 'video_${widget.maintenanceScheduleId}_${widget.johkasouId}_${entry.key}';
          await _saveMediaToRedis(key, entry.value!);
        }
      }

      await _saveToRedis('device_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', deviceInfo);
      await _saveToRedis('ip_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', ipInfo);
      await _saveToRedis('location_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', locationInfo);
    }
  }

  Future<void> _saveCategoryIndex() async {
    try {
      final key = 'last_category_index_${widget.maintenanceScheduleId}_${widget.johkasouId}';
      await _quizBox.put(key, currentCategoryIndex);
      print('Saved category index: $key = $currentCategoryIndex');
      if (redisCommand != null) {
        await _saveToRedis(key, currentCategoryIndex.toString());
      }
    } catch (e) {
      print('Error saving category index: $e');
    }
  }

  Future<void> _uploadPendingMedia(int maintenanceScheduleId, int johkasouId) async {
    if (!_isConnected) {
      print('No internet connection, saving media for later upload (johkasouId: $johkasouId)');
      await _savePendingImages(maintenanceScheduleId, johkasouId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media will be uploaded when online')),
        );
      }
      return;
    }

    final uploadFutures = <Future<bool>>[];
    for (var entry in questionImages.entries) {
      if (entry.value != null) {
        uploadFutures.add(_uploadWithRetry(
          entry.key,
          entry.value!,
          maintenanceScheduleId,
          johkasouId,
        ));
      }
    }

    final results = await Future.wait(uploadFutures);
    final anyUploadFailed = results.contains(false);

    if (anyUploadFailed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some media files failed to upload after retries')),
      );
    }
  }

  Future<bool> _uploadWithRetry(
      int questionId,
      File imageFile,
      int maintenanceScheduleId,
      int johkasouId,
      ) async {
    const maxRetries = 2;
    const retryDelay = Duration(seconds: 2);
    int attempt = 0;
    bool success = false;

    while (attempt < maxRetries && !success) {
      attempt++;
      try {
        print('Attempt $attempt to upload image for question $questionId (johkasouId: $johkasouId)');
        success = await _apiService.uploadImage(
          questionId,
          imageFile,
          maintenanceScheduleId,
          johkasouId,
          ipInfo,
          locationInfo,
          deviceInfo,
        ).timeout(const Duration(seconds: 10));

        if (success) {
          print('Image uploaded successfully for question $questionId (johkasouId: $johkasouId)');
          await _quizBox.delete('image_${maintenanceScheduleId}_${johkasouId}_${questionId}');
          if (redisCommand != null) {
            try {
              await redisCommand!.send_object(['DEL', 'media:image_${maintenanceScheduleId}_${johkasouId}_${questionId}']);
            } catch (e) {
              print('Redis error while deleting image key: $e');
            }
          }
          return true;
        }
      } catch (e) {
        print('Error uploading image (attempt $attempt) for question $questionId (johkasouId: $johkasouId): $e');
      }

      if (!success && attempt < maxRetries) {
        print('Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }

    if (!success) {
      print('Failed to upload image for question $questionId after $maxRetries attempts (johkasouId: $johkasouId)');
      await _quizBox.put(
        'pending_image_${maintenanceScheduleId}_${johkasouId}_${questionId}',
        imageFile.path,
      );
    }

    return success;
  }

  Future<void> _savePendingImages(int maintenanceScheduleId, int johkasouId) async {
    for (var entry in questionImages.entries) {
      if (entry.value != null) {
        final key = 'image_${maintenanceScheduleId}_${johkasouId}_${entry.key}';
        await _quizBox.put(key, entry.value!.path);
        print('Saved pending image for question ${entry.key} (johkasouId: $johkasouId): ${entry.value!.path}');
      }
    }
  }

  Future<void> _processPendingUploads() async {
    final keys = _quizBox.keys
        .where((key) => key.toString().startsWith('pending_image_${widget.maintenanceScheduleId}_${widget.johkasouId}'))
        .toList();

    if (keys.isEmpty) {
      print('No pending images to upload');
      return;
    }

    print('Processing ${keys.length} pending images');
    for (var key in keys) {
      final parts = key.toString().split('_');
      if (parts.length >= 5) {
        final questionId = int.parse(parts[4]);
        final filePath = _quizBox.get(key);
        if (filePath != null && File(filePath).existsSync()) {
          questionImages[questionId] = File(filePath);
          print('Uploading pending image for question $questionId (johkasouId: ${widget.johkasouId})');
          await _uploadPendingMedia(widget.maintenanceScheduleId, widget.johkasouId);
        } else {
          await _quizBox.delete(key);
        }
      }
    }
  }

  Future<bool> _isRedisConnected() async {
    try {
      await redisCommand!.send_object(['PING']).timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<http.StreamedResponse> sendWithRetry(http.MultipartRequest request, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await request.send().timeout(const Duration(seconds: 5));
      } catch (e) {
        if (attempt == maxRetries) {
          print('Request failed after $maxRetries attempts for johkasouId ${widget.johkasouId}: $e');
          rethrow;
        }
        print('Attempt $attempt failed for johkasouId ${widget.johkasouId}: $e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('Failed to send request after $maxRetries attempts');
  }

  Widget _buildQuestionsForCategory(Category category) {
    print('Building questions for category: ${category.name}, Total questions: ${category.questions.length}');
    List<Widget> questionWidgets = [];

    for (var question in category.questions) {
      if (mainQuestionVisibility[question.id] == true) {
        print('  Including question: ${question.text} (ID: ${question.id})');
        questionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildQuestion(question),
          ),
        );
      } else {
        print('  Excluding question: ${question.text} (ID: ${question.id}, Not visible)');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questionWidgets,
    );
  }

  void _processDependentQuestions() {
    final newRelatedQuestions = <int, List<Question>>{};
    final newRelatedQuestionsVisibility = <int, bool>{};

    print('=== Processing Dependent Questions ===');
    for (var parentQuestion in parentQuestions) {
      print('Processing parent question: ${parentQuestion.text} (ID: ${parentQuestion.id})');
      for (var option in parentQuestion.options) {
        if (questionDependencies.containsKey(option.id)) {
          List<Question> dependentQuestions = [];
          for (int dependentId in questionDependencies[option.id]!) {
            Question? dependentQuestion = _findQuestionById(dependentId);
            if (dependentQuestion != null) {
              dependentQuestions.add(dependentQuestion);
            }
          }
          newRelatedQuestions[option.id] = dependentQuestions;
          bool isSelected = selectedOptions[parentQuestion.id] == option.value;
          newRelatedQuestionsVisibility[option.id] = isSelected;
          print('Option "${option.text}" (ID: ${option.id}) controls ${dependentQuestions.length} questions, selected: $isSelected');
        }
      }
    }

    if (!mounted) return;
    setState(() {
      relatedQuestions = newRelatedQuestions;
      relatedQuestionsVisibility = newRelatedQuestionsVisibility;
    });

    _updateRelatedQuestionVisibility();
  }

  Question? _findQuestionById(int questionId) {
    for (var category in categories) {
      for (var question in category.questions) {
        if (question.id == questionId) {
          return question;
        }
      }
    }
    return null;
  }

  void _updateRelatedQuestionVisibility() {
    print('=== All Questions Always Visible ===');
    final newVisibility = Map<int, bool>.from(mainQuestionVisibility);

    // Make all questions visible regardless of selections
    for (var category in categories) {
      for (var question in category.questions) {
        newVisibility[question.id] = true;
      }
    }

    if (!mounted) return;
    setState(() {
      mainQuestionVisibility = newVisibility;
      print('All ${newVisibility.length} questions set to visible');
    });

    _updateVisibleQuestions();
  }

  void _initializeMainQuestionVisibility() {
    mainQuestionVisibility.clear();
    print('=== Initializing All Questions as Visible ===');

    for (var category in categories) {
      for (var question in category.questions) {
        mainQuestionVisibility[question.id] = true;
        print('  Question ${question.text} (ID: ${question.id}) set to visible');
      }
    }

    print('Initialized mainQuestionVisibility for ${mainQuestionVisibility.length} questions');
  }

  void _updateVisibleQuestions() {
    final List<Question> newVisibleQuestions = [];
    for (var question in categories[currentCategoryIndex].questions) {
      if (mainQuestionVisibility[question.id] == true) {
        newVisibleQuestions.add(question);
      }
    }

    print('=== Visible Questions (${newVisibleQuestions.length}) ===');
    for (var q in newVisibleQuestions) {
      print(' - ${q.text} (ID: ${q.id})');
    }

    if (!mounted) return;
    setState(() {
      visibleQuestions = newVisibleQuestions;
    });
  }

  Future<void> _checkSessionValidity() async {
    final tokenExpired = await TokenManager.isTokenExpired();
    if (tokenExpired && mounted) {
      await TokenManager.clearToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _nextCategory() {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        if (currentCategoryIndex < categories.length - 1) {
          currentCategoryIndex++;
        }
      });
      _saveAllData();
    }
  }

  void _previousCategory() {
    if (!mounted) return;
    setState(() {
      if (currentCategoryIndex > 0) {
        currentCategoryIndex--;
      }
    });
    _saveAllData();
  }

  bool _isAllQuestionsAnswered() {
    bool isLastCategory = currentCategoryIndex == categories.length - 1;
    if (!isLastCategory) return false;

    for (var category in categories) {
      for (var question in category.questions) {
        bool isVisible = mainQuestionVisibility[question.id] == true;
        if (isVisible && question.required == 1) {
          if (question.type == 'radio' && selectedOptions[question.id] == null) {
            print('Validation failed: Radio question ${question.text} (ID: ${question.id}) is required but not answered');
            return false;
          }
          if ((question.type == 'number' || question.type == 'text') &&
              (controllers[question.id]?.text.isEmpty ?? true)) {
            print('Validation failed: Text/number question ${question.text} (ID: ${question.id}) is required but empty');
            return false;
          }
        }
      }
    }

    print('All required questions answered');
    return true;
  }

  // Widget _buildCommentField(Question question) {
  //   return TextFormField(
  //     key: Key('comment_${question.id}'),
  //     initialValue: questionComments[question.id],
  //     onChanged: (value) async {
  //       if (!mounted) return;
  //       setState(() {
  //         questionComments[question.id] = value;
  //       });
  //       try {
  //         final key = 'comment_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
  //         await _quizBox.put(key, value);
  //         if (redisCommand != null) {
  //           await _saveToRedis(key, value);
  //         }
  //       } catch (e) {
  //         print('Error saving comment for question ${question.id}: $e');
  //       }
  //     },
  //     maxLines: 1,
  //     // decoration: InputDecoration(
  //     //   focusedBorder: const OutlineInputBorder(
  //     //     borderSide: BorderSide(color: Color(0xFF0074BA)),
  //     //     borderRadius: BorderRadius.all(Radius.circular(8)),
  //     //   ),
  //     //   labelText: 'Remarks',
  //     //   labelStyle: const TextStyle(color: Color(0xFF0074BA)),
  //     //   border: const OutlineInputBorder(
  //     //     borderRadius: BorderRadius.all(Radius.circular(8)),
  //     //   ),
  //     //   filled: true,
  //     //   fillColor: Colors.white,
  //     // ),
  //   );
  // }

  Widget _buildTextFieldForNumber(Question question) {
    controllers.putIfAbsent(question.id, () => TextEditingController(text: selectedOptions[question.id] ?? ''));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        key: Key('number_${question.id}'),
        keyboardType: question.type == 'number' ? TextInputType.number : TextInputType.text,
        controller: controllers[question.id],
        onChanged: (value) async {
          if (!mounted) return;
          setState(() {
            selectedOptions[question.id] = value;
            touchedQuestions.add(question.id);
          });
          try {
            final key = 'number_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
            await _quizBox.put(key, value);
            if (redisCommand != null) {
              await _saveToRedis(key, value);
            }
          } catch (e) {
            print('Error saving number input for question ${question.id}: $e');
          }
        },
        validator: (value) {
          if (question.required == 1 && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (question.type == 'number' && value != null && value.isNotEmpty) {
            final doubleValue = double.tryParse(value);
            if (doubleValue == null) {
              return 'Please enter a valid number';
            }
            // if (question.min != null && doubleValue < question.min!) {
            //   return 'Please enter a value greater than or equal to ${question.min}';
            // }
            if (doubleValue > 1000) {
              return 'Please enter a value less than or equal to 1000';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: '${question.text}${question.unit != null ? " (${question.unit})" : ""}',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Future<void> _captureMedia(int questionId, bool isVideo) async {
    if (isVideo) {
      return;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 1200,
      );

      if (photo == null || !mounted) return;

      File imageFile = File(photo.path);
      final key = 'image_${widget.maintenanceScheduleId}_${widget.johkasouId}_$questionId';

      // Fetch device info, IP info, and location info
      String newDeviceInfo = await _getDeviceInfo();
      String newIpInfo = await _getIpInfo();
      String newLocationInfo = await _getLocationInfo();

      setState(() {
        questionImages[questionId] = imageFile;
        deviceInfo = newDeviceInfo;
        ipInfo = newIpInfo;
        locationInfo = newLocationInfo;
      });

      // Save to Hive
      await _quizBox.put(key, imageFile.path);
      await _quizBox.put('device_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', newDeviceInfo);
      await _quizBox.put('ip_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', newIpInfo);
      await _quizBox.put('location_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', newLocationInfo);

      // Save to Redis if connected
      if (redisCommand != null) {
        await _saveMediaToRedis(key, imageFile);
        await _saveToRedis('device_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', newDeviceInfo);
        await _saveToRedis('ip_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', newIpInfo);
        await _saveToRedis('location_info_${widget.maintenanceScheduleId}_${widget.johkasouId}', newLocationInfo);
      }

      if (_isConnected) {
        setState(() => isSubmitting = true);
        try {
          bool uploadSuccess = await _apiService.uploadImage(
            questionId,
            imageFile,
            widget.maintenanceScheduleId,
            widget.johkasouId,
            newIpInfo,
            newLocationInfo,
            newDeviceInfo,
          );

          if (uploadSuccess) {
            await _quizBox.delete(key);
            if (redisCommand != null) {
              await redisCommand!.send_object(['DEL', 'media:$key']);
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Image uploaded successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image saved locally (upload failed)'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => isSubmitting = false);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.signal_wifi_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Image saved locally (offline)'),
                ],
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return '${androidInfo.model} (${androidInfo.id})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return '${iosInfo.name} (${iosInfo.identifierForVendor})';
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    return 'Unknown Device';
  }

  Future<String> _getIpInfo() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP info: $e');
    }
    return 'Unknown IP';
  }

  Future<String> _getLocationInfo() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location Services Disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 'Location Permission Denied';
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location Permission Permanently Denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'Lat: ${position.latitude}, Lon: ${position.longitude}';
    } catch (e) {
      print('Error getting location info: $e');
    }
    return 'Unknown Location';
  }

  Widget _buildDropdownForOptions(Question question) {
    // Debug print to check question data
    print('Building dropdown for question: ${question.text}');
    print('Question options: ${question.options.map((o) => '${o.value}: ${o.text}').toList()}');
    print('Selected value: ${selectedOptions[question.id]}');

    // Ensure we have valid options
    if (question.options.isEmpty) {
      print('Warning: No options available for question ${question.id}');
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.red),
          color: Colors.red.withOpacity(0.1),
        ),
        child: const Text(
          'No options available for this question',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    // Check if selected value exists in options
    String? currentValue = selectedOptions[question.id];
    bool valueExists = currentValue == null ||
        question.options.any((option) => option.value == currentValue);

    if (!valueExists) {
      print('Warning: Selected value "$currentValue" not found in options for question ${question.id}');
      // Reset to null if selected value doesn't exist in options
      currentValue = null;
      selectedOptions[question.id] = null;
    }

    List<DropdownMenuItem<String>> dropdownItems = question.options.map((option) {
      return DropdownMenuItem<String>(
        value: option.value,
        child: Text(
          option.text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      );
    }).toList();

    // Add clear/remove option at the top
    dropdownItems.insert(0, const DropdownMenuItem<String>(
      value: '',
      child: Row(
        children: [
          Icon(Icons.clear, size: 16, color: Colors.red),
          SizedBox(width: 8),
          Text(
            'Clear Selection',
            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    ));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
          errorStyle: TextStyle(height: 0),
        ),
        items: dropdownItems,
        onChanged: (value) async {
          if (!mounted) return;

          setState(() {
            if (value == '') {
              selectedOptions.remove(question.id);
              touchedQuestions.remove(question.id);
              print('Cleared selection for question ${question.id}');
            } else {
              selectedOptions[question.id] = value;
              touchedQuestions.add(question.id);
              print('Selected "$value" for question ${question.id}');
            }
          });

          if (_formKey.currentState != null) {
            _formKey.currentState!.validate();
          }

          _updateRelatedQuestionVisibility();

          try {
            final key = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
            if (value == '') {
              // Remove from storage when cleared
              await _quizBox.delete(key);
              if (redisCommand != null) {
                await redisCommand!.send_object(['DEL', key]);
              }
            } else {
              await _quizBox.put(key, value);
              if (redisCommand != null) {
                await _saveToRedis(key, value!);
              }
            }
          } catch (e) {
            print('Error saving dropdown option for question ${question.id}: $e');
          }
        },
        validator: (value) {
          if ((value == null || value == '') && question.required == 1) {
            return '';
          }
          return null;
        },
        hint: const Text('Select an option'),
        isExpanded: true,
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    final isRequired = question.required == 1;
    return Card(
      color: const Color(0xffe8f3f4),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (question.unit != null)
              Text(
                'Unit: ${question.unit}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 5),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      // Expanded(
                      //   child: _buildCaptureButton(
                      //     onPressed: () => _captureMedia(question.id, false),
                      //     icon: Icons.camera_alt,
                      //     label: 'Upload Photo',
                      //   ),
                      // ),
                      const SizedBox(width: 8),
                      // Expanded(
                      //   child: _buildCaptureButton(
                      //     onPressed: () => _captureMedia(question.id, true),
                      //     icon: Icons.videocam,
                      //     label: 'Upload Video',
                      //   ),
                      // ),
                    ],
                  ),
                  if (questionImages[question.id] != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (locationInfo.isNotEmpty)
                          Text(locationInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (ipInfo.isNotEmpty)
                          Text(ipInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (deviceInfo.isNotEmpty)
                          Text(deviceInfo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (!mounted) return;
                        setState(() {
                          questionImages.remove(question.id);
                          locationInfo = '';
                          ipInfo = '';
                          deviceInfo = '';
                        });
                        try {
                          final key = 'image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
                          await _quizBox.delete(key);
                          if (redisCommand != null) {
                            await redisCommand!.send_object(['DEL', 'media:$key']);
                          }
                        } catch (e) {
                          print('Error deleting image for question ${question.id}: $e');
                        }
                      },
                    ),
                  ] else ...[
                    // const Text(
                    //   'No photo taken',
                    //   style: TextStyle(fontSize: 12, color: Colors.grey),
                    // ),
                  ],
                ],
              ),
            ),
            if (question.options.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownForOptions(question),
                  if (isRequired && (selectedOptions[question.id] == null || selectedOptions[question.id]!.isEmpty))
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '* Required',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              )
            else if (question.type == 'number' || question.type == 'String' || question.type == 'text')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldForNumber(question),
                  if (isRequired && (selectedOptions[question.id] == null || selectedOptions[question.id]!.isEmpty))
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '* Required',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 3),
            //   child: _buildCommentField(question),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.teal),
        label: Text(label, style: const TextStyle(color: Colors.red)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        ),
      ),
    );
  }

  Future<void> _saveMediaToRedis(String key, File mediaFile) async {
    try {
      if (!await mediaFile.exists()) {
        print('Media file does not exist for $key (johkasouId: ${widget.johkasouId})');
        return;
      }

      final fileSize = await mediaFile.length();
      if (fileSize == 0) {
        print('Media file is empty for $key (johkasouId: ${widget.johkasouId})');
        return;
      }

      if (fileSize > 10 * 1024 * 1024) {
        print('Media file too large for $key (size: ${fileSize / 1024 / 1024} MB, johkasouId: ${widget.johkasouId})');
        return;
      }

      if (redisCommand == null || !await _isRedisConnected()) {
        print('Redis not connected, attempting to initialize for $key (johkasouId: ${widget.johkasouId})');
        await _initializeRedis();
        if (redisCommand == null) {
          print('Redis initialization failed, skipping media save for $key (johkasouId: ${widget.johkasouId})');
          return;
        }
      }

      try {
        var info = await redisCommand!.send_object(['INFO', 'REPLICATION']).timeout(const Duration(seconds: 5));
        if (info.contains('role:slave')) {
          print('Redis is read-only (role:slave), skipping media write for $key (johkasouId: ${widget.johkasouId})');
          return;
        }
      } catch (e) {
        print('Error checking Redis replication status for $key (johkasouId: ${widget.johkasouId}): $e');
        return;
      }

      List<int> bytes;
      try {
        bytes = await mediaFile.readAsBytes();
        print('Read ${bytes.length} bytes from media file for $key (johkasouId: ${widget.johkasouId})');
      } catch (e) {
        print('Error reading media file for $key (johkasouId: ${widget.johkasouId}): $e');
        return;
      }

      String base64Data;
      try {
        base64Data = base64Encode(bytes);
        print('Encoded ${bytes.length} bytes to Base64 (length: ${base64Data.length}) for $key (johkasouId: ${widget.johkasouId})');
      } catch (e) {
        print('Error encoding media to Base64 for $key (johkasouId: ${widget.johkasouId}): $e');
        return;
      }

      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          await redisCommand!.send_object(['SET', 'media:$key', base64Data]).timeout(const Duration(seconds: 10));
          await redisCommand!.send_object(['EXPIRE', 'media:$key', 86400]).timeout(const Duration(seconds: 5));
          print('Successfully stored media in Redis for johkasouId ${widget.johkasouId}: $key');
          return;
        } catch (e) {
          if (e.toString().contains('READONLY')) {
            print('Redis is read-only, skipping media write for $key (johkasouId: ${widget.johkasouId})');
            return;
          } else if (attempt == 3) {
            print('Failed to store media in Redis for $key after $attempt attempts (johkasouId: ${widget.johkasouId}): $e');
            return;
          }
          print('Retrying media save for $key (attempt $attempt, johkasouId: ${widget.johkasouId}): $e');
          await Future.delayed(const Duration(seconds: 1));
          await _initializeRedis();
          if (redisCommand == null) {
            print('Redis reinitialization failed on retry, skipping media save for $key (johkasouId: ${widget.johkasouId})');
            return;
          }
        }
      }
    } catch (e) {
      print('Unexpected error storing media in Redis for johkasouId ${widget.johkasouId}: $e');
      redisCommand = null;
      await _initializeRedis();
    }
  }

  Future<void> _loadFromRedis() async {
    try {
      if (redisCommand == null || !await _isRedisConnected()) {
        await _initializeRedis();
        if (redisCommand == null) {
          print('Redis initialization failed, skipping load for johkasouId ${widget.johkasouId}');
          return;
        }
      }

      bool dataUpdated = false;
      await _initializeHive();

      for (var category in categories) {
        for (var question in category.questions) {
          try {
            String optionKey = 'option_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
            var optionData = await redisCommand!.send_object(['GET', optionKey]).timeout(
              const Duration(seconds: 5),
              onTimeout: () => null,
            );
            if (optionData != null && optionData != selectedOptions[question.id]) {
              selectedOptions[question.id] = optionData;
              await _quizBox.put(optionKey, optionData);
              dataUpdated = true;
              print('Loaded from Redis for johkasouId ${widget.johkasouId}: $optionKey = $optionData');
            }

            String commentKey = 'comment_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
            var commentData = await redisCommand!.send_object(['GET', commentKey]).timeout(
              const Duration(seconds: 5),
              onTimeout: () => null,
            );
            if (commentData != null && commentData != questionComments[question.id]) {
              questionComments[question.id] = commentData;
              await _quizBox.put(commentKey, commentData);
              dataUpdated = true;
              print('Loaded from Redis for johkasouId ${widget.johkasouId}: $commentKey = $commentData');
            }

            if (question.type == 'number' || question.type == 'text') {
              String numberKey = 'number_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
              var numberData = await redisCommand!.send_object(['GET', numberKey]).timeout(
                const Duration(seconds: 5),
                onTimeout: () => null,
              );
              if (numberData != null && numberData != selectedOptions[question.id]) {
                controllers.putIfAbsent(question.id, () => TextEditingController());
                controllers[question.id]!.text = numberData;
                selectedOptions[question.id] = numberData;
                await _quizBox.put(numberKey, numberData);
                dataUpdated = true;
                print('Loaded from Redis for johkasouId ${widget.johkasouId}: $numberKey = $numberData');
              }
            }

            String imageKey = 'media:image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
            var imageData = await redisCommand!.send_object(['GET', imageKey]).timeout(
              const Duration(seconds: 5),
              onTimeout: () => null,
            );
            if (imageData != null) {
              try {
                List<int> imageBytes = base64Decode(imageData);
                final tempDir = await getTemporaryDirectory();
                final imageFile = File('${tempDir.path}/image_${question.id}.jpg');
                await imageFile.writeAsBytes(imageBytes);
                if (await imageFile.exists()) {
                  await _initializeHive();
                  questionImages[question.id] = imageFile;
                  await _quizBox.put('image_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}', imageFile.path);
                  dataUpdated = true;
                  print('Loaded image from Redis for johkasouId ${widget.johkasouId}: $imageKey');
                } else {
                  print('Failed to save image file for $imageKey (johkasouId: ${widget.johkasouId})');
                }
              } catch (e) {
                print('Error decoding or saving image for $imageKey (johkasouId: ${widget.johkasouId}): $e');
              }
            }

            String videoKey = 'media:video_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}';
            var videoData = await redisCommand!.send_object(['GET', videoKey]).timeout(
              const Duration(seconds: 5),
              onTimeout: () => null,
            );
            if (videoData != null) {
              try {
                List<int> videoBytes = base64Decode(videoData);
                final tempDir = await getTemporaryDirectory();
                final videoFile = File('${tempDir.path}/video_${question.id}.mp4');
                if (await videoFile.exists()) {
                  await _initializeHive();
                  questionVideos[question.id] = videoFile;
                  await _quizBox.put('video_${widget.maintenanceScheduleId}_${widget.johkasouId}_${question.id}', videoFile.path);
                  dataUpdated = true;
                  print('Loaded video from Redis for johkasouId ${widget.johkasouId}: $videoKey');
                } else {
                  print('Failed to save video file for $videoKey (johkasouId: ${widget.johkasouId})');
                }
              } catch (e) {
                print('Error decoding or saving video for $videoKey (johkasouId: ${widget.johkasouId}): $e');
              }
            }
          } catch (e) {
            print('Error processing question ${question.id} for johkasouId ${widget.johkasouId}: $e');
          }
        }
      }

      await _initializeHive();
      String deviceInfoKey = 'device_info_${widget.maintenanceScheduleId}_${widget.johkasouId}';
      var deviceInfoData = await redisCommand!.send_object(['GET', deviceInfoKey]).timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (deviceInfoData != null && deviceInfoData != deviceInfo) {
        deviceInfo = deviceInfoData;
        await _quizBox.put(deviceInfoKey, deviceInfoData);
        dataUpdated = true;
        print('Loaded from Redis for johkasouId ${widget.johkasouId}: $deviceInfoKey = $deviceInfoData');
      }

      String ipInfoKey = 'ip_info_${widget.maintenanceScheduleId}_${widget.johkasouId}';
      var ipInfoData = await redisCommand!.send_object(['GET', ipInfoKey]).timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (ipInfoData != null && ipInfoData != ipInfo) {
        ipInfo = ipInfoData;
        await _quizBox.put(ipInfoKey, ipInfoData);
        dataUpdated = true;
        print('Loaded from Redis for johkasouId ${widget.johkasouId}: $ipInfoKey = $ipInfoData');
      }

      String locationInfoKey = 'location_info_${widget.maintenanceScheduleId}_${widget.johkasouId}';
      var locationInfoData = await redisCommand!.send_object(['GET', locationInfoKey]).timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (locationInfoData != null && locationInfoData != locationInfo) {
        locationInfo = locationInfoData;
        await _quizBox.put(locationInfoKey, locationInfoData);
        dataUpdated = true;
        print('Loaded from Redis for johkasouId ${widget.johkasouId}: $locationInfoKey = $locationInfoData');
      }

      if (dataUpdated && mounted) {
        setState(() {
          _updateRelatedQuestionVisibility();
          _updateVisibleQuestions();
        });
        print('UI updated with Redis data for johkasouId ${widget.johkasouId}');
      } else {
        print('No new data loaded from Redis for johkasouId ${widget.johkasouId}');
      }
    } catch (e) {
      print('Error in _loadFromRedis for johkasouId ${widget.johkasouId}: $e');
      redisCommand = null;
      await _initializeRedis();
    }
  }
}



