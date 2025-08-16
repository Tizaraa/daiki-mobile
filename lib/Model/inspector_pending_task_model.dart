// Model classes
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
  final int status; // Added status field
  final String taskStatus; // This will hold "0" or "1" from jokhasou_models

  JohkasouModel({
    required this.id,
    required this.projectId,
    required this.module,
    this.serialNumber,
    this.blowerModel,
    this.quantity,
    required this.status,
    required this.taskStatus, // Added taskStatus parameter
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    return JohkasouModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      module: json['module']?.toString() ?? '',
      serialNumber: json['sl_number']?.toString(),
      blowerModel: json['blower_model']?.toString(),
      quantity: json['quantity']?.toString(),
      status: json['status'] ?? 0,
      taskStatus: "0", // Default value, will be set from parent parsing
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

  MaintenanceSchedule({
    required this.id,
    required this.projectId,
    required this.maintenanceDate,
    required this.frequency,
    required this.nextMaintenanceDate,

    required this.project,
    required this.group,
    required this.johkasouModels,
  });

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    List<JohkasouModel> models = [];
    if (json['jokhasou_models'] != null) {
      for (var modelData in json['jokhasou_models']) {
        var johkasouModel = JohkasouModel.fromJson(modelData['johkasou_model'] ?? {});
        // Create new instance with the status from jokhasou_models array
        models.add(JohkasouModel(
          id: johkasouModel.id,
          projectId: johkasouModel.projectId,
          module: johkasouModel.module,
          serialNumber: johkasouModel.serialNumber,
          blowerModel: johkasouModel.blowerModel,
          quantity: johkasouModel.quantity,
          status: johkasouModel.status,
          taskStatus: modelData['status']?.toString() ?? "0", // Get status from outer object
        ));
      }
    }

    return MaintenanceSchedule(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      maintenanceDate: json['maintenance_date']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      nextMaintenanceDate: json['next_maintenance_date']?.toString() ?? '',

      project: Project.fromJson(json['project'] ?? {}),
      group: Group.fromJson(json['group'] ?? {}),
      johkasouModels: models, // Use the updated models list
    );
  }
}

// Model classes for the category and questions API response
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
  final List<Question> questions;

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
    required this.questions,
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
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ??
          [],
    );
  }
}

class Question {
  final int id;
  final int categoryId;
  final String text;
  final String type;
  final String? unit;
  final int required;
  final int? slNo;
  final dynamic min;
  final dynamic max;
  final String? textSriLanka;
  final dynamic string;
  final int status;

  Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.type,
    this.unit,
    required this.required,
    this.slNo,
    this.min,
    this.max,
    this.textSriLanka,
    this.string,
    required this.status,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      unit: json['unit'],
      required: json['required'] ?? 0,
      slNo: json['sl_no'],
      min: json['min'],
      max: json['max'],
      textSriLanka: json['text_srilanka'],
      string: json['string'],
      status: json['status'] ?? 0,
    );
  }
}
