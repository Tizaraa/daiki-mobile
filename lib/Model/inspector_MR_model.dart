// Updated MaintenanceResponse class to include group name and johkasou models
class MaintenanceResponse {
  final String id;
  final String userName;
  final String projectName;
  final String remarks;
  final String scheduleDate;
  final String maintenanceFrequency;
  final String createdAt;
  final String pj_code;
  final String projectStatus;
  final String maintenanceStatus;
  final String updatedAt;
  final String groupName; // Added for group name
  final List<JohkasouModel> johkasouModels; // Added for johkasou models

  MaintenanceResponse({
    required this.id,
    required this.userName,
    required this.projectName,
    required this.remarks,
    required this.scheduleDate,
    required this.maintenanceFrequency,
    required this.createdAt,
    required this.pj_code,
    required this.projectStatus,
    required this.maintenanceStatus,
    required this.updatedAt,
    required this.groupName,
    required this.johkasouModels,
  });

  factory MaintenanceResponse.fromJson(Map<String, dynamic> json) {
    // Parse johkasou models if available
    List<JohkasouModel> models = [];
    if (json['johkasou_models'] != null) {
      models = (json['johkasou_models'] as List)
          .map((model) => JohkasouModel.fromJson(model))
          .toList();
    }

    // Handle remarks data properly
    String remarksText = 'N/A';
    if (json['remarks'] != null) {
      if (json['remarks'] is String) {
        remarksText = json['remarks'] ?? 'N/A';
      } else if (json['remarks'] is Map && json['remarks']['text'] != null) {
        remarksText = json['remarks']['text'] ?? 'N/A';
      }
    }

    return MaintenanceResponse(
      id: json['id']?.toString() ?? 'N/A',
      userName: json['user']?['name'] ?? 'N/A',
      projectName: json['project']?['project_name'] ?? 'N/A',
      remarks: remarksText, // Use the properly parsed remarks
      scheduleDate: json['maintenance_schedule']?['maintenance_date'] ?? 'N/A',
      maintenanceFrequency: json['maintenance_schedule']?['frequency'] ?? 'N/A',
      createdAt: json['created_at'] ?? 'N/A',
      pj_code: json['project']?['pj_code'] ?? 'N/A',
      projectStatus: json['project']?['project_status'] ?? 'N/A',
      maintenanceStatus: json['project']?['maintenance_status'] ?? 'N/A',
      updatedAt: json['updated_at'] ?? 'N/A',
      groupName: json['maintenance_schedule']?['group']?['name'] ?? 'N/A',
      johkasouModels: models,
    );
  }
}

// New class for Johkasou Model
class JohkasouModel {
  final String id; // ID of the johkasou_models entry (e.g., 119)
  final String johkasouModelId; // ID of the johkasou_model (e.g., 578)
  final String module; // Field for the module name (e.g., "BA-50")
  final String description; // Optional, as it's not in the JSON

  JohkasouModel({
    required this.id,
    required this.johkasouModelId,
    required this.module,
    required this.description,
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    // Access the nested johkasou_model object
    final modelData = json['johkasou_model'] as Map<String, dynamic>?;

    return JohkasouModel(
      id: json['id']?.toString() ?? '', // e.g., "119"
      johkasouModelId: json['johkasou_model_id']?.toString() ?? '', // e.g., "578"
      module: modelData?['module'] ?? 'Unknown Module', // e.g., "BA-50"
      description: modelData?['remark'] ?? '', // Use remark as description
    );
  }
}
