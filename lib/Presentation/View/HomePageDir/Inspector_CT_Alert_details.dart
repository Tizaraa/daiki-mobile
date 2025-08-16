import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';



// models/abnormal_response_model.dart
class AbnormalResponseModel {
  final bool status;
  final AbnormalData data;
  final String errors;
  final String message;

  AbnormalResponseModel({
    required this.status,
    required this.data,
    required this.errors,
    required this.message,
  });

  factory AbnormalResponseModel.fromJson(Map<String, dynamic> json) {
    return AbnormalResponseModel(
      status: json['status'] ?? false,
      data: AbnormalData.fromJson(json['data'] ?? {}),
      errors: json['errors'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class AbnormalData {
  final Schedule schedule;
  final List<JohkasouModelData> johkasouModel;

  AbnormalData({
    required this.schedule,
    required this.johkasouModel,
  });

  factory AbnormalData.fromJson(Map<String, dynamic> json) {
    return AbnormalData(
      schedule: Schedule.fromJson(json['schedule'] ?? {}),
      johkasouModel: (json['johkasou_model'] as List<dynamic>?)
          ?.map((e) => JohkasouModelData.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Schedule {
  final int id;
  final int projectId;
  final String maintenanceDate;
  final String? frequency;
  final int groupId;
  final String? task;
  final int taskId;
  final String? nextMaintenanceDate;
  final String remarks;
  final String createdAt;
  final String updatedAt;
  final int status;
  final int isBulkAssign;
  final int? jokhasouModelId;
  final String? serialNo;
  final TaskInfo taskInfo;
  final Project project;
  final Group group;

  Schedule({
    required this.id,
    required this.projectId,
    required this.maintenanceDate,
    this.frequency,
    required this.groupId,
    this.task,
    required this.taskId,
    this.nextMaintenanceDate,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.isBulkAssign,
    this.jokhasouModelId,
    this.serialNo,
    required this.taskInfo,
    required this.project,
    required this.group,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      maintenanceDate: json['maintenance_date'] ?? '',
      frequency: json['frequency'],
      groupId: json['group_id'] ?? 0,
      task: json['task'],
      taskId: json['task_id'] ?? 0,
      nextMaintenanceDate: json['next_maintenance_date'],
      remarks: json['remarks'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      status: json['status'] ?? 0,
      isBulkAssign: json['is_bulk_assign'] ?? 0,
      jokhasouModelId: json['jokhasou_model_id'],
      serialNo: json['serial_no'],
      taskInfo: TaskInfo.fromJson(json['task_info'] ?? {}),
      project: Project.fromJson(json['project'] ?? {}),
      group: Group.fromJson(json['group'] ?? {}),
    );
  }
}

class TaskInfo {
  final int id;
  final String taskDescription;
  final int status;
  final String createdAt;
  final String updatedAt;

  TaskInfo({
    required this.id,
    required this.taskDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskInfo.fromJson(Map<String, dynamic> json) {
    return TaskInfo(
      id: json['id'] ?? 0,
      taskDescription: json['task_description'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Project {
  final int projectId;
  final String pjCode;
  final String projectName;
  final String location;
  final int projectLocationId;
  final int client;
  final String contractedDate;
  final int branch;
  final int companyId;
  final int totalServicedCount;
  final Branch branches;

  Project({
    required this.projectId,
    required this.pjCode,
    required this.projectName,
    required this.location,
    required this.projectLocationId,
    required this.client,
    required this.contractedDate,
    required this.branch,
    required this.companyId,
    required this.totalServicedCount,
    required this.branches,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'] ?? 0,
      pjCode: json['pj_code'] ?? '',
      projectName: json['project_name'] ?? '',
      location: json['location'] ?? '',
      projectLocationId: json['project_location_id'] ?? 0,
      client: json['client'] ?? 0,
      contractedDate: json['contracted_date'] ?? '',
      branch: json['branch'] ?? 0,
      companyId: json['company_id'] ?? 0,
      totalServicedCount: json['total_serviced_count'] ?? 0,
      branches: Branch.fromJson(json['branches'] ?? {}),
    );
  }
}

class Branch {
  final int id;
  final int companyId;
  final String name;
  final String orderPrefix;
  final String createdAt;
  final String updatedAt;

  Branch({
    required this.id,
    required this.companyId,
    required this.name,
    required this.orderPrefix,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      name: json['name'] ?? '',
      orderPrefix: json['order_prefix'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Group {
  final int id;
  final String name;
  final int inspectorId;
  final String createdAt;
  final String updatedAt;
  final List<int> members;
  final int status;
  final int companyId;
  final Inspector inspector;

  Group({
    required this.id,
    required this.name,
    required this.inspectorId,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.status,
    required this.companyId,
    required this.inspector,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      inspectorId: json['inspector_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      members: (json['members'] as List<dynamic>?)?.cast<int>() ?? [],
      status: json['status'] ?? 0,
      companyId: json['company_id'] ?? 0,
      inspector: Inspector.fromJson(json['inspector'] ?? {}),
    );
  }
}

class Inspector {
  final int id;
  final int companyId;
  final String name;
  final String email;
  final String timezone;
  final String phone;
  final int status;
  final String createdAt;
  final String updatedAt;

  Inspector({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    required this.timezone,
    required this.phone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inspector.fromJson(Map<String, dynamic> json) {
    return Inspector(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      timezone: json['timezone'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class JohkasouModelData {
  final JohkasouModel johkasouModel;
  final Schedule schedule;
  final List<ResponseData> data;

  JohkasouModelData({
    required this.johkasouModel,
    required this.schedule,
    required this.data,
  });

  factory JohkasouModelData.fromJson(Map<String, dynamic> json) {
    return JohkasouModelData(
      johkasouModel: JohkasouModel.fromJson(json['johkasou_model'] ?? {}),
      schedule: Schedule.fromJson(json['schedule'] ?? {}),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ResponseData.fromJson(e))
          .toList() ?? [],
    );
  }
}

class JohkasouModel {
  final int id;
  final int projectId;
  final String module;
  final String slNumber;
  final int status;
  final String createdAt;
  final String updatedAt;

  JohkasouModel({
    required this.id,
    required this.projectId,
    required this.module,
    required this.slNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    return JohkasouModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      module: json['module'] ?? '',
      slNumber: json['sl_number'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ResponseData {
  final int id;
  final int responseMasterId;
  final int responseDataId;
  final int questionId;
  final int categoryId;
  final String response;
  final String expectedRange;
  final String abnormalType;
  final String createdAt;
  final String updatedAt;
  final Category category;
  final Question question;

  ResponseData({
    required this.id,
    required this.responseMasterId,
    required this.responseDataId,
    required this.questionId,
    required this.categoryId,
    required this.response,
    required this.expectedRange,
    required this.abnormalType,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.question,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      id: json['id'] ?? 0,
      responseMasterId: json['response_master_id'] ?? 0,
      responseDataId: json['response_data_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      response: json['response'] ?? '',
      expectedRange: json['expected_range'] ?? '',
      abnormalType: json['abnormal_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      question: Question.fromJson(json['question'] ?? {}),
    );
  }
}

class Category {
  final int id;
  final String name;
  final int slNo;
  final int countryId;
  final String description;
  final String createdAt;
  final String updatedAt;
  final int status;
  final String nameSriLanka;
  final String model;

  Category({
    required this.id,
    required this.name,
    required this.slNo,
    required this.countryId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.nameSriLanka,
    required this.model,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slNo: json['sl_no'] ?? 0,
      countryId: json['country_id'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      status: json['status'] ?? 0,
      nameSriLanka: json['name_sri_lanka'] ?? '',
      model: json['model'] ?? '',
    );
  }
}

class Question {
  final int id;
  final int categoryId;
  final String text;
  final String type;
  final String unit;
  final int required;
  final int slNo;
  final double min;
  final double max;
  final String textSrilanka;
  final int status;

  Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.type,
    required this.unit,
    required this.required,
    required this.slNo,
    required this.min,
    required this.max,
    required this.textSrilanka,
    required this.status,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      unit: json['unit'] ?? '',
      required: json['required'] ?? 0,
      slNo: json['sl_no'] ?? 0,
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
      textSrilanka: json['text_srilanka'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}


class ApiService {
  static Future<AbnormalResponseModel> getAbnormalResponses(int scheduleId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/abnormal/responses/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return AbnormalResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}


class InspectorCTAlertDetails extends StatefulWidget {
  final int scheduleId;

  const InspectorCTAlertDetails({
    Key? key,
    required this.scheduleId,
  }) : super(key: key);

  @override
  _InspectorCTAlertDetailsState createState() => _InspectorCTAlertDetailsState();
}

class _InspectorCTAlertDetailsState extends State<InspectorCTAlertDetails> {
  late Future<AbnormalResponseModel> _futureAbnormalResponses;

  @override
  void initState() {
    super.initState();
    _futureAbnormalResponses = ApiService.getAbnormalResponses(widget.scheduleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<AbnormalResponseModel>(
        future: _futureAbnormalResponses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureAbnormalResponses = ApiService.getAbnormalResponses(widget.scheduleId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleCard(data.data.schedule),
                  const SizedBox(height: 16),
                  _buildProjectCard(data.data.schedule.project),
                  const SizedBox(height: 16),
                  _buildJohkasouModelsSection(data.data.johkasouModel),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Task', schedule.taskInfo.taskDescription),
            _buildInfoRow('Maintenance Date', _formatDate(schedule.maintenanceDate)),
            _buildInfoRow('Remarks', schedule.remarks),
            _buildInfoRow('Status', schedule.status == 1 ? 'Active' : 'Inactive'),
            _buildInfoRow('Group', schedule.group.name),
            _buildInfoRow('Inspector', schedule.group.inspector.name),
            _buildInfoRow('Inspector Email', schedule.group.inspector.email),
            _buildInfoRow('Inspector Phone', schedule.group.inspector.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Project Name', project.projectName),
            _buildInfoRow('Project Code', project.pjCode),
            _buildInfoRow('Location', project.location),
            _buildInfoRow('Branch', project.branches.name),
            _buildInfoRow('Contracted Date', _formatDate(project.contractedDate)),
            _buildInfoRow('Total Serviced', project.totalServicedCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildJohkasouModelsSection(List<JohkasouModelData> models) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Johkasou Models & Responses',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...models.map((model) => _buildJohkasouModelCard(model)),
      ],
    );
  }

  Widget _buildJohkasouModelCard(JohkasouModelData modelData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model: ${modelData.johkasouModel.module}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Serial Number', modelData.johkasouModel.slNumber),
            _buildInfoRow('Status', modelData.johkasouModel.status == 1 ? 'Active' : 'Inactive'),
            const SizedBox(height: 16),
            if (modelData.data.isNotEmpty) ...[
              Text(
                'Abnormal Responses:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...modelData.data.map((response) => _buildResponseCard(response)),
            ] else ...[
              const Text(
                'No abnormal responses recorded',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(ResponseData response) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${response.question.text} (${response.category.name})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Response', response.response),
          _buildInfoRow('Expected Range', response.expectedRange),
          _buildInfoRow('Abnormal Type', response.abnormalType.toUpperCase()),
          _buildInfoRow('Unit', response.question.unit),
          _buildInfoRow('Date', _formatDate(response.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
