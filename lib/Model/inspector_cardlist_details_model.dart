// class TicketResponse {
//   final String message;
//   final TicketData data;
//   final List<TypeOfIssue> typeOfIssue;
//   final bool status;
//
//   TicketResponse({
//     required this.message,
//     required this.data,
//     required this.typeOfIssue,
//     required this.status,
//   });
//
//   factory TicketResponse.fromJson(Map<String, dynamic> json) {
//     return TicketResponse(
//       message: json['message'] ?? '',
//       data: TicketData.fromJson(json['data'] ?? {}),
//       typeOfIssue: (json['typeOfIssue'] as List? ?? [])
//           .map((issue) => TypeOfIssue.fromJson(issue ?? {}))
//           .toList(),
//       status: json['status'] ?? false,
//     );
//   }
// }
//
// class TicketData {
//   final int id;
//   final int typeOfIssueId;
//   final int submittedBy;
//   final String title;
//   final String description;
//   final String? file;
//   final String status;
//   final String? module;
//   final String priority;
//   final String createdAt;
//   final String updatedAt;
//   final int projectId;
//   final int check;
//   final String expectedDate;
//   final String code;
//   final String? assigned;
//   final List<Comment> comments;
//   final User submittedByUser;
//   final Project project;
//   final List<TicketFile> files;
//   final TypeOfIssue typeOfIssue;
//   final List<JohkasouModelForTicket> johkasouModelForTicket;
//
//   TicketData({
//     required this.id,
//     required this.typeOfIssueId,
//     required this.submittedBy,
//     required this.title,
//     required this.description,
//     this.file,
//     required this.status,
//     this.module,
//     required this.priority,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.projectId,
//     required this.check,
//     required this.expectedDate,
//     required this.code,
//     this.assigned,
//     required this.comments,
//     required this.submittedByUser,
//     required this.project,
//     required this.files,
//     required this.typeOfIssue,
//     required this.johkasouModelForTicket,
//   });
//
//   factory TicketData.fromJson(Map<String, dynamic> json) {
//     return TicketData(
//       id: json['id'] ?? 0,
//       typeOfIssueId: json['type_of_issue_id'] ?? 0,
//       submittedBy: json['submitted_by'] ?? 0,
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       file: json['file'],
//       status: json['status'] ?? '',
//       module: json['module'],
//       priority: json['priority'] ?? '',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       projectId: json['project_id'] ?? 0,
//       check: json['check'] ?? 0,
//       expectedDate: json['expected_date'] ?? '',
//       code: json['code'] ?? '',
//       assigned: json['assigned'],
//       comments: ((json['comment'] ?? []) as List)
//           .map((comment) => Comment.fromJson(comment ?? {}))
//           .toList(),
//       submittedByUser: User.fromJson(json['submitted_by_user'] ?? {}),
//       project: Project.fromJson(json['project'] ?? {}),
//       files: ((json['files'] ?? []) as List)
//           .map((file) => TicketFile.fromJson(file ?? {}))
//           .toList(),
//       typeOfIssue: TypeOfIssue.fromJson(json['type_of_issue'] ?? {}),
//       johkasouModelForTicket: ((json['johkasou_model_for_ticket'] ?? []) as List)
//           .map((model) => JohkasouModelForTicket.fromJson(model ?? {}))
//           .toList(),
//     );
//   }
// }
//
// class Comment {
//   final int id;
//   final int ticketId;
//   final String? file;
//   final String message;
//   final int commentedById;
//   final String createdAt;
//   final String updatedAt;
//   final User commentedBy;
//   final String? carStatus;
//
//   Comment({
//     required this.id,
//     required this.ticketId,
//     this.file,
//     required this.message,
//     required this.commentedById,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.commentedBy,
//     this.carStatus,
//   });
//
//   factory Comment.fromJson(Map<String, dynamic> json) {
//     return Comment(
//       id: json['id'] ?? 0,
//       ticketId: json['ticket_id'] ?? 0,
//       file: json['file'],
//       message: json['message'] ?? '',
//       commentedById: json['commented_by_id'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       commentedBy: User.fromJson(json['commented_by'] ?? {}),
//       carStatus: json['car_status'],
//     );
//   }
// }
//
// class User {
//   final int id;
//   final int companyId;
//   final int? branchId;
//   final String name;
//   final String email;
//   final String phone;
//   final String? photo;
//   final int status;
//   final String? emailVerifiedAt;
//   final String? rememberToken;
//   final String createdAt;
//   final String updatedAt;
//
//   User({
//     required this.id,
//     required this.companyId,
//     this.branchId,
//     required this.name,
//     required this.email,
//     required this.phone,
//     this.photo,
//     required this.status,
//     this.emailVerifiedAt,
//     this.rememberToken,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] ?? 0,
//       companyId: json['company_id'] ?? 0,
//       branchId: json['branch_id'],
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       photo: json['photo'],
//       status: json['status'] ?? 0,
//       emailVerifiedAt: json['email_verified_at'],
//       rememberToken: json['remember_token'],
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }
//
// class Project {
//   final int projectId;
//   final String pjCode;
//   final String projectName;
//   final String location;
//   final int projectLocationId;
//   final int client;
//   final String locationMap;
//   final String capacity;
//   final int johkasouModelId;
//   final String projectStatus;
//   final int projectStatusId;
//   final String maintenanceStatus;
//   final int maintenanceStatusId;
//   final String? contractedDate;
//   final String? expireDate;
//   final String? pic;
//   final String? noOfBlowers;
//   final String? installationStartTime;
//   final String? installationEndTime;
//   final String? remarks;
//   final String projectType;
//   final int projectTypeId;
//   final String projectFacilities;
//   final int projectFacilitieId;
//   final String? companyCode;
//   final String? projectImage;
//   final String? users;
//   final int branch;
//   final int companyId;
//   final String? bdmName;
//   final String? bdmNameId;
//   final Branch branches;
//
//   Project({
//     required this.projectId,
//     required this.pjCode,
//     required this.projectName,
//     required this.location,
//     required this.projectLocationId,
//     required this.client,
//     required this.locationMap,
//     required this.capacity,
//     required this.johkasouModelId,
//     required this.projectStatus,
//     required this.projectStatusId,
//     required this.maintenanceStatus,
//     required this.maintenanceStatusId,
//     this.contractedDate,
//     this.expireDate,
//     this.pic,
//     this.noOfBlowers,
//     this.installationStartTime,
//     this.installationEndTime,
//     this.remarks,
//     required this.projectType,
//     required this.projectTypeId,
//     required this.projectFacilities,
//     required this.projectFacilitieId,
//     this.companyCode,
//     this.projectImage,
//     this.users,
//     required this.branch,
//     required this.companyId,
//     this.bdmName,
//     this.bdmNameId,
//     required this.branches,
//   });
//
//   factory Project.fromJson(Map<String, dynamic> json) {
//     return Project(
//       projectId: json['project_id'] ?? 0,
//       pjCode: json['pj_code'] ?? '',
//       projectName: json['project_name'] ?? '',
//       location: json['location'] ?? '',
//       projectLocationId: json['project_location_id'] ?? 0,
//       client: json['client'] ?? 0,
//       locationMap: json['location_map'] ?? '',
//       capacity: json['capacity'] ?? '',
//       johkasouModelId: json['johkasouModel_id'] ?? 0,
//       projectStatus: json['project_status'] ?? '',
//       projectStatusId: json['project_status_id'] ?? 0,
//       maintenanceStatus: json['maintenance_status'] ?? '',
//       maintenanceStatusId: json['maintenance_status_id'] ?? 0,
//       contractedDate: json['contracted_date'],
//       expireDate: json['expire_date'],
//       pic: json['pic'],
//       noOfBlowers: json['no_of_blowers'],
//       installationStartTime: json['installation_start_time'],
//       installationEndTime: json['installation_end_time'],
//       remarks: json['remarks'],
//       projectType: json['project_type'] ?? '',
//       projectTypeId: json['project_type_id'] ?? 0,
//       projectFacilities: json['project_facilities'] ?? '',
//       projectFacilitieId: json['project_facilitie_id'] ?? 0,
//       companyCode: json['company_code'],
//       projectImage: json['project_image'],
//       users: json['users'],
//       branch: json['branch'] ?? 0,
//       companyId: json['company_id'] ?? 0,
//       bdmName: json['bdm_name'],
//       bdmNameId: json['bdm_name_id'],
//       branches: Branch.fromJson(json['branches'] ?? {}),
//     );
//   }
// }
//
// class Branch {
//   final int id;
//   final int companyId;
//   final String name;
//   final String? code;
//   final String? johkasouModel;
//   final String? orderPrefix;
//   final String? person;
//   final String? email;
//   final String? phone;
//   final String? address;
//   final String? type;
//   final String? logo;
//   final String createdAt;
//   final String updatedAt;
//
//   Branch({
//     required this.id,
//     required this.companyId,
//     required this.name,
//     this.code,
//     this.johkasouModel,
//     this.orderPrefix,
//     this.person,
//     this.email,
//     this.phone,
//     this.address,
//     this.type,
//     this.logo,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory Branch.fromJson(Map<String, dynamic> json) {
//     return Branch(
//       id: json['id'] ?? 0,
//       companyId: json['company_id'] ?? 0,
//       name: json['name'] ?? '',
//       code: json['code'],
//       johkasouModel: json['johkasou_model'],
//       orderPrefix: json['order_prefix'],
//       person: json['person'],
//       email: json['email'],
//       phone: json['phone'],
//       address: json['address'],
//       type: json['type'],
//       logo: json['logo'],
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }
//
// class TicketFile {
//   final int id;
//   final int ticketId;
//   final String file;
//   final String createdAt;
//   final String updatedAt;
//
//   TicketFile({
//     required this.id,
//     required this.ticketId,
//     required this.file,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory TicketFile.fromJson(Map<String, dynamic> json) {
//     return TicketFile(
//       id: json['id'] ?? 0,
//       ticketId: json['ticket_id'] ?? 0,
//       file: json['file'] ?? '',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }
//
// class TypeOfIssue {
//   final int id;
//   final String typeOfIssue;
//   final int status;
//   final String createdAt;
//   final String updatedAt;
//
//   TypeOfIssue({
//     required this.id,
//     required this.typeOfIssue,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory TypeOfIssue.fromJson(Map<String, dynamic> json) {
//     return TypeOfIssue(
//       id: json['id'] ?? 0,
//       typeOfIssue: json['type_of_issue'] ?? '',
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
// }
//
// class JohkasouModel {
//   final int id;
//   final String module;
//   final String slNumber;
//
//   JohkasouModel({
//     required this.id,
//     required this.module,
//     required this.slNumber,
//   });
//
//   factory JohkasouModel.fromJson(Map<String, dynamic> json) {
//     return JohkasouModel(
//       id: json['id'] ?? 0,
//       module: json['module'] ?? '',
//       slNumber: json['sl_number'] ?? '',
//     );
//   }
// }
//
// class JohkasouModelForTicket {
//   final int id;
//   final int johkasouModelId;
//   final int ticketId;
//   final int projectId;
//   final String? text;
//   final int status;
//   final String createdAt;
//   final String updatedAt;
//   final JohkasouModel johkasouModel;
//
//   JohkasouModelForTicket({
//     required this.id,
//     required this.johkasouModelId,
//     required this.ticketId,
//     required this.projectId,
//     this.text,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.johkasouModel,
//   });
//
//   factory JohkasouModelForTicket.fromJson(Map<String, dynamic> json) {
//     return JohkasouModelForTicket(
//       id: json['id'] ?? 0,
//       johkasouModelId: json['johkasou_model_id'] ?? 0,
//       ticketId: json['ticket_id'] ?? 0,
//       projectId: json['project_id'] ?? 0,
//       text: json['text'],
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       johkasouModel: JohkasouModel.fromJson(json['johkasou_model'] ?? {}),
//     );
//   }
// }



class TicketResponse {
  final String message;
  final TicketData data;
  final List<TypeOfIssue> typeOfIssue;
  final bool status;

  TicketResponse({
    required this.message,
    required this.data,
    required this.typeOfIssue,
    required this.status,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      message: json['message']?.toString() ?? '',
      data: TicketData.fromJson(json['data'] ?? {}),
      typeOfIssue: (json['typeOfIssue'] as List? ?? [])
          .map((issue) => TypeOfIssue.fromJson(issue ?? {}))
          .toList(),
      status: json['status'] is bool ? json['status'] : (json['status']?.toString().toLowerCase() == 'true'),
    );
  }
}

class TicketData {
  final int id;
  final int typeOfIssueId;
  final int submittedBy;
  final String title;
  final String? description;
  final String? file;
  final String status;
  final String? module;
  final String priority;
  final String createdAt;
  final String updatedAt;
  final int projectId;
  final int check;
  final String expectedDate;
  final String code;
  final String? carSerial;
  final String? receivedBy;
  final String? complaintBrief;
  final String? responseDate;
  final String? rootCause;
  final String? targetCompletionDate;
  final String? assigned;
  final List<Comment> comments;
  final User submittedByUser;
  final Project project;
  final List<TicketFile> files;
  final TypeOfIssue typeOfIssue;
  final List<Responsibility> responsibilities;
  final List<JohkasouModelForTicket> johkasouModelForTicket;

  TicketData({
    required this.id,
    required this.typeOfIssueId,
    required this.submittedBy,
    required this.title,
    this.description,
    this.file,
    required this.status,
    this.module,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    required this.projectId,
    required this.check,
    required this.expectedDate,
    required this.code,
    this.carSerial,
    this.receivedBy,
    this.complaintBrief,
    this.responseDate,
    this.rootCause,
    this.targetCompletionDate,
    this.assigned,
    required this.comments,
    required this.submittedByUser,
    required this.project,
    required this.files,
    required this.typeOfIssue,
    required this.responsibilities,
    required this.johkasouModelForTicket,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      id: _parseInt(json['id']) ?? 0,
      typeOfIssueId: _parseInt(json['type_of_issue_id']) ?? 0,
      submittedBy: _parseInt(json['submitted_by']) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      file: json['file']?.toString(),
      status: json['status']?.toString() ?? '',
      module: json['module']?.toString(),
      priority: json['priority']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      projectId: _parseInt(json['project_id']) ?? 0,
      check: _parseInt(json['check']) ?? 0,
      expectedDate: json['expected_date']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      carSerial: json['car_serial']?.toString(),
      receivedBy: json['received_by']?.toString(),
      complaintBrief: json['complaint_brief']?.toString(),
      responseDate: json['response_date']?.toString(),
      rootCause: json['root_cause']?.toString(),
      targetCompletionDate: json['target_completion_date']?.toString(),
      assigned: json['assigned']?.toString(),
      comments: ((json['comment'] ?? []) as List)
          .map((comment) => Comment.fromJson(comment ?? {}))
          .toList(),
      submittedByUser: User.fromJson(json['submitted_by_user'] ?? {}),
      project: Project.fromJson(json['project'] ?? {}),
      files: ((json['files'] ?? []) as List)
          .map((file) => TicketFile.fromJson(file ?? {}))
          .toList(),
      typeOfIssue: TypeOfIssue.fromJson(json['type_of_issue'] ?? {}),
      responsibilities: ((json['responsibilities'] ?? []) as List)
          .map((resp) => Responsibility.fromJson(resp ?? {}))
          .toList(),
      johkasouModelForTicket: ((json['johkasou_model_for_ticket'] ?? []) as List)
          .map((model) => JohkasouModelForTicket.fromJson(model ?? {}))
          .toList(),
    );
  }
}

class Comment {
  final int id;
  final int ticketId;
  final String? file;
  final String message;
  final int commentedById;
  final String createdAt;
  final String updatedAt;
  final User commentedBy;
  final String? carStatus;

  Comment({
    required this.id,
    required this.ticketId,
    this.file,
    required this.message,
    required this.commentedById,
    required this.createdAt,
    required this.updatedAt,
    required this.commentedBy,
    this.carStatus,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: _parseInt(json['id']) ?? 0,
      ticketId: _parseInt(json['ticket_id']) ?? 0,
      file: json['file']?.toString(),
      message: json['message']?.toString() ?? '',
      commentedById: _parseInt(json['commented_by_id']) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      commentedBy: User.fromJson(json['commented_by'] ?? {}),
      carStatus: json['car_status']?.toString(),
    );
  }
}

class User {
  final int id;
  final int companyId;
  final int? branchId;
  final String name;
  final String email;
  final String phone;
  final String? photo;
  final int status;
  final String? emailVerifiedAt;
  final String? rememberToken;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.companyId,
    this.branchId,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
    required this.status,
    this.emailVerifiedAt,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']) ?? 0,
      companyId: _parseInt(json['company_id']) ?? 0,
      branchId: _parseInt(json['branch_id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      photo: json['photo']?.toString(),
      status: _parseInt(json['status']) ?? 0,
      emailVerifiedAt: json['email_verified_at']?.toString(),
      rememberToken: json['remember_token']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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
  final String locationMap;
  final String capacity;
  final int johkasouModelId;
  final String projectStatus;
  final int projectStatusId;
  final String maintenanceStatus;
  final int maintenanceStatusId;
  final String? contractedDate;
  final String? expireDate;
  final String? pic;
  final String? noOfBlowers;
  final String? installationStartTime;
  final String? installationEndTime;
  final String? remarks;
  final String projectType;
  final int projectTypeId;
  final String projectFacilities;
  final int projectFacilitieId;
  final String? companyCode;
  final String? projectImage;
  final String? users;
  final int branch;
  final int companyId;
  final String? bdmName;
  final String? bdmNameId;
  final Branch branches;

  Project({
    required this.projectId,
    required this.pjCode,
    required this.projectName,
    required this.location,
    required this.projectLocationId,
    required this.client,
    required this.locationMap,
    required this.capacity,
    required this.johkasouModelId,
    required this.projectStatus,
    required this.projectStatusId,
    required this.maintenanceStatus,
    required this.maintenanceStatusId,
    this.contractedDate,
    this.expireDate,
    this.pic,
    this.noOfBlowers,
    this.installationStartTime,
    this.installationEndTime,
    this.remarks,
    required this.projectType,
    required this.projectTypeId,
    required this.projectFacilities,
    required this.projectFacilitieId,
    this.companyCode,
    this.projectImage,
    this.users,
    required this.branch,
    required this.companyId,
    this.bdmName,
    this.bdmNameId,
    required this.branches,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: _parseInt(json['project_id']) ?? 0,
      pjCode: json['pj_code']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      projectLocationId: _parseInt(json['project_location_id']) ?? 0,
      client: _parseInt(json['client']) ?? 0,
      locationMap: json['location_map']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      johkasouModelId: _parseInt(json['johkasouModel_id']) ?? 0,
      projectStatus: json['project_status']?.toString() ?? '',
      projectStatusId: _parseInt(json['project_status_id']) ?? 0,
      maintenanceStatus: json['maintenance_status']?.toString() ?? '',
      maintenanceStatusId: _parseInt(json['maintenance_status_id']) ?? 0,
      contractedDate: json['contracted_date']?.toString(),
      expireDate: json['expire_date']?.toString(),
      pic: json['pic']?.toString(),
      noOfBlowers: json['no_of_blowers']?.toString(),
      installationStartTime: json['installation_start_time']?.toString(),
      installationEndTime: json['installation_end_time']?.toString(),
      remarks: json['remarks']?.toString(),
      projectType: json['project_type']?.toString() ?? '',
      projectTypeId: _parseInt(json['project_type_id']) ?? 0,
      projectFacilities: json['project_facilities']?.toString() ?? '',
      projectFacilitieId: _parseInt(json['project_facilitie_id']) ?? 0,
      companyCode: json['company_code']?.toString(),
      projectImage: json['project_image']?.toString(),
      users: json['users'] is List ? json['users'].join(', ') : json['users']?.toString(),
      branch: _parseInt(json['branch']) ?? 0,
      companyId: _parseInt(json['company_id']) ?? 0,
      bdmName: json['bdm_name']?.toString(),
      bdmNameId: json['bdm_name_id']?.toString(),
      branches: Branch.fromJson(json['branches'] ?? {}),
    );
  }
}

class Branch {
  final int id;
  final int companyId;
  final String name;
  final String? code;
  final String? johkasouModel;
  final String? orderPrefix;
  final String? person;
  final String? email;
  final String? phone;
  final String? address;
  final String? type;
  final String? logo;
  final String createdAt;
  final String updatedAt;

  Branch({
    required this.id,
    required this.companyId,
    required this.name,
    this.code,
    this.johkasouModel,
    this.orderPrefix,
    this.person,
    this.email,
    this.phone,
    this.address,
    this.type,
    this.logo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: _parseInt(json['id']) ?? 0,
      companyId: _parseInt(json['company_id']) ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      johkasouModel: json['johkasou_model']?.toString(),
      orderPrefix: json['order_prefix']?.toString(),
      person: json['person']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      type: json['type']?.toString(),
      logo: json['logo']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class TicketFile {
  final int id;
  final int ticketId;
  final String file;
  final String createdAt;
  final String updatedAt;

  TicketFile({
    required this.id,
    required this.ticketId,
    required this.file,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketFile.fromJson(Map<String, dynamic> json) {
    return TicketFile(
      id: _parseInt(json['id']) ?? 0,
      ticketId: _parseInt(json['ticket_id']) ?? 0,
      file: json['file']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class TypeOfIssue {
  final int id;
  final String typeOfIssue;
  final int status;
  final String createdAt;
  final String updatedAt;

  TypeOfIssue({
    required this.id,
    required this.typeOfIssue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TypeOfIssue.fromJson(Map<String, dynamic> json) {
    return TypeOfIssue(
      id: _parseInt(json['id']) ?? 0,
      typeOfIssue: json['type_of_issue']?.toString() ?? '',
      status: _parseInt(json['status']) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class JohkasouModel {
  final int id;
  final String module;
  final String slNumber;

  JohkasouModel({
    required this.id,
    required this.module,
    required this.slNumber,
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    return JohkasouModel(
      id: _parseInt(json['id']) ?? 0,
      module: json['module']?.toString() ?? '',
      slNumber: json['sl_number']?.toString() ?? '',
    );
  }
}

class JohkasouModelForTicket {
  final int id;
  final int johkasouModelId;
  final int ticketId;
  final int projectId;
  final String? text;
  final int status;
  final String createdAt;
  final String updatedAt;
  final JohkasouModel johkasouModel;

  JohkasouModelForTicket({
    required this.id,
    required this.johkasouModelId,
    required this.ticketId,
    required this.projectId,
    this.text,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.johkasouModel,
  });

  factory JohkasouModelForTicket.fromJson(Map<String, dynamic> json) {
    return JohkasouModelForTicket(
      id: _parseInt(json['id']) ?? 0,
      johkasouModelId: _parseInt(json['johkasou_model_id']) ?? 0,
      ticketId: _parseInt(json['ticket_id']) ?? 0,
      projectId: _parseInt(json['project_id']) ?? 0,
      text: json['text']?.toString(),
      status: _parseInt(json['status']) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      johkasouModel: JohkasouModel.fromJson(json['johkasou_model'] ?? {}),
    );
  }
}

class Responsibility {
  final int responsibilityId;
  final String responsibilityName;
  final String responsibilityEmail;
  final String responsibilityPhone;
  final Pivot pivot;

  Responsibility({
    required this.responsibilityId,
    required this.responsibilityName,
    required this.responsibilityEmail,
    required this.responsibilityPhone,
    required this.pivot,
  });

  factory Responsibility.fromJson(Map<String, dynamic> json) {
    return Responsibility(
      responsibilityId: _parseInt(json['responsibility_id']) ?? 0,
      responsibilityName: json['responsibility_name']?.toString() ?? '',
      responsibilityEmail: json['responsibility_email']?.toString() ?? '',
      responsibilityPhone: json['responsibility_phone']?.toString() ?? '',
      pivot: Pivot.fromJson(json['pivot'] ?? {}),
    );
  }
}

class Pivot {
  final int ticketId;
  final int responsibilityId;
  final String createdAt;
  final String updatedAt;

  Pivot({
    required this.ticketId,
    required this.responsibilityId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      ticketId: _parseInt(json['ticket_id']) ?? 0,
      responsibilityId: _parseInt(json['responsibility_id']) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

// Helper function to parse integers safely
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}