
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';
import '../../Authentication/login_screen.dart';
import '../../HomePageDir/Inspector_QuestionPage.dart';
import 'Inspector_MultiJohkasouPreviewScreen.dart';
import 'Inspector_maintenance_questions.dart';

// Model classes
class MaintenanceResponse {
  bool? status;
  MaintenanceData? data;

  MaintenanceResponse({this.status, this.data});

  factory MaintenanceResponse.fromJson(Map<String, dynamic> json) {
    return MaintenanceResponse(
      status: json['status'],
      data: json['data'] != null ? MaintenanceData.fromJson(json['data']) : null,
    );
  }
}

class MaintenanceData {
  MaintenanceSchedule? maintenanceSchedule;

  MaintenanceData({this.maintenanceSchedule});

  factory MaintenanceData.fromJson(Map<String, dynamic> json) {
    return MaintenanceData(
      maintenanceSchedule: json['maintenance_schedule'] != null
          ? MaintenanceSchedule.fromJson(json['maintenance_schedule'])
          : null,
    );
  }
}

class MaintenanceSchedule {
  List<MaintenanceItem>? data;

  MaintenanceSchedule({this.data});

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) return MaintenanceSchedule(data: null);

    return MaintenanceSchedule(
      data: (json['data'] as List)
          .map((v) => MaintenanceItem.fromJson(v))
          .toList(),
    );
  }
}

class MaintenanceItem {
  final int id;
  final int projectId;
  final String maintenanceDate;
  final String? nextMaintenanceDate;
  final String? frequency;
  final Project project;
  final String createdAt;
  final List<JohkasouModel>? johkasouModels;
  final Group? group;
  final List<Assignment>? assignments;
  final int? status;

  MaintenanceItem({
    required this.id,
    required this.projectId,
    required this.maintenanceDate,
    this.nextMaintenanceDate,
    this.frequency,
    required this.project,
    required this.createdAt,
    this.johkasouModels,
    this.group,
    this.assignments,
    required this.status,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    List<JohkasouModel>? johkasouModels;
    if (json['jokhasou_models'] != null && json['jokhasou_models'] is List) {
      johkasouModels = (json['jokhasou_models'] as List)
          .map((model) => JohkasouModel.fromJson(model))
          .toList();
    }

    List<Assignment>? assignments;
    if (json['assignments'] != null && json['assignments'] is List) {
      assignments = (json['assignments'] as List)
          .map((assignment) => Assignment.fromJson(assignment))
          .toList();
    }

    return MaintenanceItem(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      maintenanceDate: json['maintenance_date']?.toString() ?? '',
      nextMaintenanceDate: json['next_maintenance_date']?.toString(),
      frequency: json['frequency']?.toString(),
      project: Project.fromJson(json['project'] ?? {}),
      createdAt: json['created_at']?.toString() ?? '',
      group: json['group'] != null ? Group.fromJson(json['group']) : null,
      johkasouModels: johkasouModels,
      assignments: assignments,
      status: json['status']?? 0,
    );
  }
}

class Assignment {
  final int id;
  final int scheduleId;
  final int userId;
  final User? user;

  Assignment({
    required this.id,
    required this.scheduleId,
    required this.userId,
    this.user,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class Group {
  final String? name;
  final User? inspector;

  Group({this.name, this.inspector});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name']?.toString(),
      inspector: json['inspector'] != null ? User.fromJson(json['inspector']) : null,
    );
  }
}

class Project {
  final String projectName;
  final String pjCode;
  final String projectType;
  final String projectStatus;
  final String? assignments;
  final String projectFacilities;
  final String capacity;
  final String? maintenanceStatus;
  final Branch? branches;
  final Client? client;

  Project({
    required this.projectName,
    required this.pjCode,
    required this.projectType,
    required this.projectStatus,
    this.assignments,
    required this.projectFacilities,
    required this.capacity,
    this.maintenanceStatus,
    this.branches,
    this.client,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectName: json['project_name']?.toString() ?? '',
      pjCode: json['pj_code']?.toString() ?? '',
      projectType: json['project_type']?.toString() ?? '',
      projectStatus: json['project_status']?.toString() ?? '',
      assignments: json['assignments'] != null
          ? (json['assignments'] as List).map((a) => a['user']['name']?.toString() ?? '').join(', ')
          : null,
      projectFacilities: json['project_facilities']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      maintenanceStatus: json['maintenance_status']?.toString(),
      branches: json['branches'] != null ? Branch.fromJson(json['branches']) : null,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
    );
  }
}

class Branch {
  final String? name;
  final Company? company;

  Branch({this.name, this.company});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name']?.toString(),
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }
}

class Client {
  final Company? company;

  Client({this.company});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }
}

class Company {
  final int? id;
  final String? name;

  Company({this.id, this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int?,
      name: json['name']?.toString(),
    );
  }
}

class JohkasouModel {
  final int id;
  final String module;
  final int? johkasouModelId;

  JohkasouModel({
    required this.id,
    required this.module,
    this.johkasouModelId,
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    return JohkasouModel(
      id: json['johkasou_model_id'] ?? 0,
      module: json['johkasou_model'] != null
          ? json['johkasou_model']['module']?.toString() ?? ''
          : json['module']?.toString() ?? '',
      johkasouModelId: json['johkasou_model_id'] as int?,
    );
  }
}

// API Service class
class ApiService {
  Future<List<MaintenanceItem>> fetchMaintenanceSchedules() async {
    try {
      String? token = await TokenManager.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Raw API response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final maintenanceResponse = MaintenanceResponse.fromJson(responseData);
        if (maintenanceResponse.status == true &&
            maintenanceResponse.data != null &&
            maintenanceResponse.data!.maintenanceSchedule != null &&
            maintenanceResponse.data!.maintenanceSchedule!.data != null) {
          return maintenanceResponse.data!.maintenanceSchedule!.data!;
        } else {
          throw Exception('Maintenance schedules data not found.');
        }
      } else {
        throw Exception('Failed to load maintenance schedules. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching maintenance schedules: $e');
    }
  }
}

class Inspector_MaintenanceScheduleScreen extends StatefulWidget {
  const Inspector_MaintenanceScheduleScreen({Key? key}) : super(key: key);

  @override
  _Inspector_MaintenanceScheduleScreenState createState() => _Inspector_MaintenanceScheduleScreenState();
}

class _Inspector_MaintenanceScheduleScreenState extends State<Inspector_MaintenanceScheduleScreen> {
  final ApiService _apiService = ApiService();
  List<MaintenanceItem> maintenanceItems = [];
  List<MaintenanceItem> filteredItems = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMaintenanceStatus;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceSchedules();
    _checkSessionValidity();
    _searchController.addListener(_filterSchedules);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSchedules() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = maintenanceItems.where((item) {
        final projectName = item.project.projectName.toLowerCase();
        final date = item.maintenanceDate.toLowerCase();
        final maintenanceStatus = item.project.maintenanceStatus?.toLowerCase() ?? '';

        final matchesQuery = projectName.contains(query) || date.contains(query);
        final matchesStatus = _selectedMaintenanceStatus == null ||
            _selectedMaintenanceStatus!.isEmpty ||
            maintenanceStatus == _selectedMaintenanceStatus!.toLowerCase();

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  Future<void> _checkSessionValidity() async {
    final tokenExpired = await TokenManager.isTokenExpired();
    if (tokenExpired) {
      await TokenManager.clearToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _loadMaintenanceSchedules() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final items = await _apiService.fetchMaintenanceSchedules();
      setState(() {
        maintenanceItems = items;
        filteredItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _navigateToQuizScreen(int maintenanceScheduleId, int projectId, int? johkasouId,
      String projectName, String nextMaintenanceDate) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => InspectorQuestionpage(
          maintenanceScheduleId: maintenanceScheduleId,
          johkasouId: johkasouId ?? 0,
          project_name: projectName,
          next_maintenance_date: nextMaintenanceDate,
          projectId: projectId,
        ),
      ),
          (route) => route.isFirst, // Keep only the first route (Inspector_MaintenanceScheduleScreen)
    );
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maintenance Schedule",style: TextStyle(color: Colors.white),),
        backgroundColor: TizaraaColors.Tizara,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadMaintenanceSchedules, // Use your existing load function
        color: TizaraaColors.Tizara,
        backgroundColor: Colors.white,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF7F9FB),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by Name or Date',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 110,
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedMaintenanceStatus,
                        hint: const Text('Filter',style: TextStyle(fontSize: 12),),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('All'),
                          ),
                          ...maintenanceItems
                              .map((item) => item.project.maintenanceStatus)
                              .where((status) => status != null)
                              .toSet()
                              .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status ?? '-'),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMaintenanceStatus = value;
                            _filterSchedules();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                  height: 40,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "SL",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Project Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            TizaraaColors.Tizara),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading schedules...',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : error != null
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadMaintenanceSchedules,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : filteredItems.isEmpty
                    ? Center(
                  child: Text(
                    'No maintenance schedules found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ExpansionCard(
                      schedule: item,
                      onTaskPressed: (int? johkasouId) {
                        _navigateToQuizScreen(
                          item.id,
                          item.projectId,
                          johkasouId,
                          item.project.projectName,
                          item.nextMaintenanceDate ?? '',
                        );
                      },
                      serialNumber: index + 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpansionCard extends StatefulWidget {
  final MaintenanceItem schedule;
  final Function(int?) onTaskPressed;
  final int serialNumber;

  const ExpansionCard({
    Key? key,
    required this.schedule,
    required this.onTaskPressed,
    required this.serialNumber,
  }) : super(key: key);

  @override
  _ExpansionCardState createState() => _ExpansionCardState();
}

class _ExpansionCardState extends State<ExpansionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shadowColor: Colors.black.withOpacity(0.2),
        child: Container(
          color: TizaraaColors.primaryColor,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        widget.serialNumber.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: TizaraaColors.Tizara,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.schedule.project.projectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TizaraaColors.Tizara,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              widget.schedule.maintenanceDate,
                              style: const TextStyle(
                                color: TizaraaColors.Tizara,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: TizaraaColors.Tizara,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: Container(),
                secondChild: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Maintenance Date',
                              widget.schedule.maintenanceDate,
                              Icons.calendar_today,
                            ),
                            if (widget.schedule.nextMaintenanceDate != null)
                              _buildInfoRow(
                                'Next Maintenance',
                                widget.schedule.nextMaintenanceDate!,
                                Icons.event,
                              ),
                            _buildInfoRow(
                              'Project Code',
                              widget.schedule.project.pjCode,
                              Icons.code,
                            ),
                            _buildInfoRow(
                              'Project Type',
                              widget.schedule.project.projectType,
                              Icons.category,
                            ),
                            _buildInfoRow(
                              'Contract Status',
                              widget.schedule.project.projectStatus,
                              Icons.assignment,
                            ),
                            if (widget.schedule.project.assignments != null)
                              _buildInfoRow(
                                'Assigned Inspector',
                                widget.schedule.project.assignments!,
                                Icons.person,
                              ),
                            _buildInfoRow(
                              'Project Facility',
                              widget.schedule.project.projectFacilities,
                              Icons.business,
                            ),
                            _CapacityModel(
                              'Johkasou Modules',
                              widget.schedule.johkasouModels,
                              Icons.speed,
                              widget.schedule.projectId,
                              widget.schedule.project.projectName,
                              widget.schedule.nextMaintenanceDate ?? '',
                              widget.schedule.id,
                              widget.onTaskPressed,
                              context,
                            ),
                            if (widget.schedule.frequency != null)
                              _buildInfoRow(
                                'Frequency',
                                widget.schedule.frequency!,
                                Icons.repeat,
                              ),
                            if (widget.schedule.status != null)
                              _buildInfoRow(
                                'Maintenance Status',

                                widget.schedule.status.toString() == '0' ? 'Pending' : 'Completed',
                                Icons.build,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
                alignment: Alignment.topCenter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: TizaraaColors.Tizara),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityModel extends StatelessWidget {
  final String label;
  final List<dynamic>? johkasouModels;
  final IconData icon;
  final int projectId;
  final String projectName;
  final String nextMaintenanceDate;
  final int maintenanceScheduleId;
  final Function(int?)? onTaskPressed; // This is not needed for JohkasouModel tap
  final BuildContext parentContext;

  const _CapacityModel(
      this.label,
      this.johkasouModels,
      this.icon,
      this.projectId,
      this.projectName,
      this.nextMaintenanceDate,
      this.maintenanceScheduleId,
      this.onTaskPressed,
      this.parentContext, {
        Key? key,
      }) : super(key: key);

  Future<bool> _isTaskCompleted(int johkasouId) async {
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

  Future<bool> _areAllTasksCompleted() async {
    if (johkasouModels == null || johkasouModels!.isEmpty) {
      return false;
    }

    for (var model in johkasouModels!) {
      int johkasouId = model is Map ? model['id'] : (model is JohkasouModel ? model.id : model);
      bool isCompleted = await _isTaskCompleted(johkasouId);
      if (!isCompleted) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _submitFinalTask({
    required int maintenanceScheduleId,
    required int johkasouId,
    required int projectId,
  }) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance/stp-final-submit'),
        body: json.encode({
          'maintenance_schedule_id': maintenanceScheduleId,
          'johkasou_id': johkasouId,
          'project_id': projectId,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting final task: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (johkasouModels == null || johkasouModels!.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: Colors.blueGrey),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade800,
                    fontSize: 12,
                  ),
                ),
              ),
              const Expanded(
                flex: 3,
                child: Text(
                  'No modules available',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 17, color: Colors.blueGrey),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: johkasouModels!.map((model) {
                  int johkasouId = model is Map ? model['id'] : (model is JohkasouModel ? model.id : model);
                  String moduleName = model is Map ? model['module'] : (model is JohkasouModel ? model.module : 'Module');

                  return FutureBuilder<bool>(
                    future: _isTaskCompleted(johkasouId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const SizedBox(width: 80, height: 40),
                          ),
                        );
                      }

                      final isCompleted = snapshot.data ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () {
                            print('Module tapped - ID: $johkasouId, Schedule ID: $maintenanceScheduleId, Project ID: $projectId');
                            Navigator.push(
                              parentContext,
                              MaterialPageRoute(
                                builder: (context) => InspectorMaintenanceQuestionpage(
                                  maintenanceScheduleId: maintenanceScheduleId,
                                  johkasouId: johkasouId,
                                  project_name: projectName,
                                  next_maintenance_date: nextMaintenanceDate,
                                  projectId: projectId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.grey.shade300 : Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moduleName,
                                  style: TextStyle(
                                    color: isCompleted ? Colors.grey.shade600 : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                if (isCompleted)
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error in _CapacityModel: $e');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'Error displaying module information: ${e.toString()}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}