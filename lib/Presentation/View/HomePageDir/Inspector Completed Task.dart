import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_CT_Alert_details.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_PT_view_album.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redis/redis.dart';
import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';
import '../../../Core/Utils/colors.dart';
import '../../../Model/inspector_completed_task_model.dart';
import '../Authentication/login_screen.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_questions.dart';
import 'Inspector_Image_after_before_screen.dart' hide Category;

class ApiService {
  Future<List<MaintenanceSchedule>> fetchMaintenanceSchedules() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      List<MaintenanceSchedule> allSchedules = [];
      int currentPage = 1;
      bool hasMoreData = true;

      while (hasMoreData) {
        final response = await http.get(
          Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules-complete-task?page=$currentPage'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print('API Response Status (Page $currentPage): ${response.statusCode}');
        print('API Response Body (Page $currentPage): ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == true) {
            if (data['data'] != null && data['data']['maintenance_schedule'] != null) {
              final maintenanceScheduleData = data['data']['maintenance_schedule'];
              final maintenanceSchedulesJson = maintenanceScheduleData['data'] as List?;

              if (maintenanceSchedulesJson != null && maintenanceSchedulesJson.isNotEmpty) {
                final pageSchedules = maintenanceSchedulesJson
                    .map((json) => MaintenanceSchedule.fromJson(json))
                    .toList();

                allSchedules.addAll(pageSchedules);

                // Check pagination - try different common pagination patterns
                bool shouldContinue = false;

                // Pattern 1: Check current_page vs last_page
                if (maintenanceScheduleData.containsKey('current_page') &&
                    maintenanceScheduleData.containsKey('last_page')) {
                  final currentPageNum = maintenanceScheduleData['current_page'];
                  final lastPage = maintenanceScheduleData['last_page'];
                  shouldContinue = currentPageNum < lastPage;
                }
                // Pattern 2: Check if has_more_pages exists
                else if (maintenanceScheduleData.containsKey('has_more_pages')) {
                  shouldContinue = maintenanceScheduleData['has_more_pages'] == true;
                }
                // Pattern 3: Check next_page_url
                else if (maintenanceScheduleData.containsKey('next_page_url')) {
                  shouldContinue = maintenanceScheduleData['next_page_url'] != null;
                }
                // Pattern 4: If less than expected per page (assuming 20 per page)
                else {
                  shouldContinue = maintenanceSchedulesJson.length >= 20;
                }

                if (shouldContinue) {
                  currentPage++;
                } else {
                  hasMoreData = false;
                }

                print('Fetched ${pageSchedules.length} schedules from page $currentPage. Total so far: ${allSchedules.length}');
              } else {
                hasMoreData = false; // No more data
                print('No data found on page $currentPage, stopping pagination');
              }
            } else {
              throw Exception('Maintenance schedules data structure is invalid');
            }
          } else {
            throw Exception('API returned false status: ${data['message'] ?? 'Unknown error'}');
          }
        } else {
          throw Exception('Failed to load maintenance schedules. Status code: ${response.statusCode}');
        }
      }

      print('Total maintenance schedules fetched: ${allSchedules.length}');
      return allSchedules;

    } catch (e) {
      print('Error in fetchMaintenanceSchedules: $e');
      throw Exception('Error fetching maintenance schedules: $e');
    }
  }

  Future<List<Category>> fetchCategoriesWithQuestions(int johkasouModelId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}}/api/v1/get-category-with-questions?johkasou_model_id=$johkasouModelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Categories API Response Status: ${response.statusCode}');
      print('Categories API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final categoriesJson = data['date'] as List?;
          if (categoriesJson != null) {
            return categoriesJson.map((json) => Category.fromJson(json)).toList();
          } else {
            throw Exception('Categories data is null');
          }
        } else {
          throw Exception('API returned false status: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchCategoriesWithQuestions: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<bool> isTaskCompleted(int scheduleId, int johkasouModelId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/task-status?schedule_id=$scheduleId&johkasou_model_id=$johkasouModelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['is_completed'] ?? false;
      } else {
        throw Exception('Failed to check task status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in isTaskCompleted: $e');
      return false;
    }
  }
}

class Inspector_CompletedTaskScreen extends StatefulWidget {
  final String title;
  final int hasAbnormalResponse;
  const Inspector_CompletedTaskScreen({super.key, required this.title, required this.hasAbnormalResponse});

  @override
  _Inspector_CompletedTaskScreenState createState() => _Inspector_CompletedTaskScreenState();
}

class _Inspector_CompletedTaskScreenState extends State<Inspector_CompletedTaskScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<MaintenanceSchedule> _maintenanceSchedules = [];
  List<MaintenanceSchedule> _filteredSchedules = [];
  List<bool> _isExpanded = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _checkSessionValidity();
      await _loadMaintenanceSchedules();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error in _loadData: $e');
    }
  }

  Future<void> _checkSessionValidity() async {
    try {
      final tokenExpired = await TokenManager.isTokenExpired();
      if (tokenExpired) {
        await TokenManager.clearToken();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print('Error in _checkSessionValidity: $e');
    }
  }

  Future<void> _loadMaintenanceSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final schedules = await _apiService.fetchMaintenanceSchedules();
      setState(() {
        _maintenanceSchedules = schedules;
        _filteredSchedules = schedules;
        _isExpanded = List.generate(schedules.length, (_) => false);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
      print('Error in _loadMaintenanceSchedules: $e');
    }
  }

  // Add the task completion checking method with SharedPreferences and Redis
  Future<bool> _isTaskCompleted(int maintenanceScheduleId, int johkasouId) async {
    final prefs = await SharedPreferences.getInstance();
    bool isCompleted = prefs.getBool('completed_${maintenanceScheduleId}_$johkasouId') ?? false;

    try {
      final redisConnection = RedisConnection();
      final redisCommand = await redisConnection.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
      await redisCommand.send_object(['AUTH', 'password']).timeout(Duration(seconds: 2));
      var redisData = await redisCommand.send_object(['GET', 'completed_${maintenanceScheduleId}_$johkasouId']).timeout(Duration(seconds: 2));
      await redisCommand.send_object(['QUIT']);
      await redisConnection.close();

      if (redisData != null && redisData == 'true') {
        isCompleted = true;
        await prefs.setBool('completed_${maintenanceScheduleId}_$johkasouId', true);
      }
    } catch (e) {
      print('Redis error checking completion for johkasouId $johkasouId: $e');
    }

    return isCompleted;
  }

  void _filterSchedules(String query) {
    setState(() {
      _filteredSchedules = _maintenanceSchedules.where((schedule) {
        final projectName = schedule.project.projectName.toLowerCase();
        final pjCode = schedule.project.pjCode.toLowerCase();
        final maintenanceDate = schedule.maintenanceDate.toLowerCase();
        final groupName = schedule.group.name.toLowerCase();
        final moduleNames = schedule.johkasouModels.map((m) => m.module.toLowerCase()).join(' ');
        return projectName.contains(query.toLowerCase()) ||
            pjCode.contains(query.toLowerCase()) ||
            maintenanceDate.contains(query.toLowerCase()) ||
            groupName.contains(query.toLowerCase()) ||
            moduleNames.contains(query.toLowerCase());
      }).toList();
      _isExpanded = List.generate(_filteredSchedules.length, (_) => false);
    });
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Completed Tasks Found',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildJohkasouModulesList(MaintenanceSchedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, bottom: 2.0),
          child: Text(
            'Johkasou Modules:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        ...schedule.johkasouModels.map((model) {
          return FutureBuilder<bool>(
            future: _isTaskCompleted(schedule.id, model.id), // Use the new method
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final isTaskCompleted = snapshot.data ?? false;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompactInfoRow('Module', model.module, Icons.hardware),
                    if (model.serialNumber != null)
                      _buildCompactInfoRow('Serial', model.serialNumber!, Icons.confirmation_number),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InspectorPtViewAlbum(
                                    johkasouModelID: model.id,
                                    ScheduleID: schedule.id,
                                    title: 'Categories for ${model.module}',
                                  ),
                                ),
                              );
                              print('Album view pressed for module ${model.id}');
                            },
                            icon: const Icon(Icons.photo_library, size: 16),
                            label: const Text('View Album', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0074BA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryQuestionsScreen(
                                    johkasouModelId: model.id,
                                    title: 'Categories for ${model.module}',
                                    projectId: schedule.project.projectId,
                                    scheduleId: schedule.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                            label: const Text('Upload Image', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0074BA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Modified Perform Task Button - ALWAYS CLICKABLE
                        // Expanded(
                        //   child: TextButton(
                        //     // ALWAYS CLICKABLE - removed the null condition
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (_) => InspectorMaintenanceQuestionpage(
                        //             maintenanceScheduleId: schedule.id,
                        //             johkasouId: model.id,
                        //             project_name: schedule.project.projectName,
                        //             next_maintenance_date: schedule.nextMaintenanceDate ?? '',
                        //             projectId: schedule.project.projectId,
                        //           ),
                        //         ),
                        //       ).then((_) {
                        //         // Refresh data after task completion
                        //         _loadMaintenanceSchedules();
                        //       });
                        //     },
                        //     style: TextButton.styleFrom(
                        //       backgroundColor: isTaskCompleted ? Colors.grey.shade300 : const Color(0xFF0074BA),
                        //       foregroundColor: isTaskCompleted ? Colors.grey.shade600 : Colors.white,
                        //       padding: const EdgeInsets.symmetric(horizontal: 2),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(6),
                        //       ),
                        //     ),
                        //     child: Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           Icons.task,
                        //           size: 16,
                        //           color: isTaskCompleted ? Colors.grey.shade600 : Colors.white,
                        //         ),
                        //         Text(
                        //           isTaskCompleted ? "Completed" : "Perform Task",
                        //           style: TextStyle(
                        //             fontSize: 11,
                        //             color: isTaskCompleted ? Colors.grey.shade600 : Colors.white,
                        //           ),
                        //         ),
                        //         if (isTaskCompleted)
                        //           Text(
                        //             '✓',
                        //             style: TextStyle(
                        //               color: Colors.teal,
                        //               fontSize: 10,
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCompactInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Name, Code, Date',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _filterSchedules,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x0476BD).withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            height: 35,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "SL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "Project Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _filteredSchedules.isEmpty
              ? _buildNoDataWidget()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filteredSchedules.length,
            itemBuilder: (context, index) {
              final schedule = _filteredSchedules[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ExpansionTile(
                  backgroundColor: TizaraaColors.primaryColor,
                  collapsedBackgroundColor: TizaraaColors.primaryColor2,
                  leading: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: TizaraaColors.Tizara,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  initiallyExpanded: _isExpanded[index],
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isExpanded[index] = expanded;
                    });
                  },
                  title: Text(
                    schedule.project.projectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TizaraaColors.Tizara,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    schedule.maintenanceDate,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    _isExpanded[index] ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF0074BA),
                    size: 20,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: TizaraaColors.primaryColor2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCompactInfoRow('Location', schedule.project.location, Icons.location_on),
                                _buildCompactInfoRow('Group Name', schedule.group.name, Icons.group),
                                _buildCompactInfoRow('Maintenance Date', schedule.maintenanceDate, Icons.calendar_today),
                                _buildCompactInfoRow('Project Code', schedule.project.pjCode, Icons.code),
                                const Divider(height: 16),
                                if (schedule.johkasouModels.isNotEmpty)
                                  _buildJohkasouModulesList(schedule),
                                if (schedule.hasAbnormalResponse == 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        print('Schedule ID: ${schedule.id}');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InspectorCTAlertDetails(scheduleId: schedule.id)));
                                      },
                                      icon: const Icon(Icons.warning, color: Colors.red),
                                      label: const Text("Alert Details"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        foregroundColor: Colors.red,
                                        side: BorderSide(color: Colors.red.shade300),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TizaraaColors.Tizara,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildMainContent(),
    );
  }
}
