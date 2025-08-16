class Group {
  final int id;
  final String name;

  Group({
    required this.id,
    required this.name,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class JohkasouModel {
  final int id;
  final int projectId;
  final String module;
  final String? serialNumber;
  final String? blowerModel;
  final String? quantity;
  final bool isTaskCompleted; // Added property

  JohkasouModel({
    required this.id,
    required this.projectId,
    required this.module,
    this.serialNumber,
    this.blowerModel,
    this.quantity,
    required this.isTaskCompleted, // Required field
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    return JohkasouModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      module: json['module']?.toString() ?? '',
      serialNumber: json['sl_number']?.toString(),
      blowerModel: json['blower_model']?.toString(),
      quantity: json['quantity']?.toString(),
      isTaskCompleted: json['is_task_completed'] ?? false, // Adjust based on API field
    );
  }
}

class Project {
  final int projectId;
  final String projectName;
  final String location;
  final String pjCode;
  final String projectType;
  final String projectStatus;
  final String assignments;
  final String projectFacilities;
  final String capacity;
  final String frequency;
  final String maintenanceStatus;

  Project({
    required this.projectId,
    required this.projectName,
    required this.location,
    required this.pjCode,
    required this.projectType,
    required this.projectStatus,
    required this.assignments,
    required this.projectFacilities,
    required this.capacity,
    required this.frequency,
    required this.maintenanceStatus,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'] ?? 0,
      projectName: json['project_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      pjCode: json['pj_code']?.toString() ?? '',
      projectType: json['project_type']?.toString() ?? '',
      projectStatus: json['project_status']?.toString() ?? '',
      assignments: json['assignments']?.toString() ?? '',
      projectFacilities: json['project_facilities']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      maintenanceStatus: json['maintenance_status']?.toString() ?? '',
    );
  }
}

class MaintenanceSchedule {
  final int id;
  final int projectId;
  final String maintenanceDate;
  final String frequency;
  final String nextMaintenanceDate;
  final Project project;
  final Group group;
  final List<JohkasouModel> johkasouModels;
  final int hasAbnormalResponse;

  MaintenanceSchedule({
    required this.id,
    required this.projectId,
    required this.maintenanceDate,
    required this.frequency,
    required this.nextMaintenanceDate,
    required this.project,
    required this.group,
    required this.johkasouModels,
    required this.hasAbnormalResponse,
  });

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    return MaintenanceSchedule(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      maintenanceDate: json['maintenance_date']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      nextMaintenanceDate: json['next_maintenance_date']?.toString() ?? '',
      project: Project.fromJson(json['project'] ?? {}),
      group: Group.fromJson(json['group'] ?? {}),
      johkasouModels: (json['jokhasou_models'] as List<dynamic>?)
          ?.map((modelJson) => JohkasouModel.fromJson(modelJson['johkasou_model'] ?? {}))
          .toList() ??
          [],
      hasAbnormalResponse: json['has_abnormal_response'] ?? 0,
    );
  }
}