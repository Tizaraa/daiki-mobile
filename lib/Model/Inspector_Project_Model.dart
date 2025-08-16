import 'dart:convert';

class Project {
  final int projectId;
  final String pjCode;
  final String projectName;
  final String location;
  final int? projectLocationId;
  final String capacity;
  final MaintenanceStatus? projectStatus;
  final MaintenanceStatus? maintenanceStatus;
  final String? contractedDate;
  final String? expireDate;
  final Client client;
  final User? pic;
  final String? remarks;
  final MaintenanceStatus? projectType;
  final MaintenanceStatus? projectFacilities;
  final List<String> users;
  final int branchId;
  final int companyId;
  final List<ProjectModule>? modules;
  final ProjectLocation? projectLocation;
  final Branch? branch;
  final BdmName? bdmName;
  final int? totalServiceCount;
  final int? totalServicedCount;
  final String? lastServiceMonth;
  final int? servicedMaintenanceScheduleCount;
  final int? nonServicedMaintenanceScheduleCount;
  final int? totalMaintenanceScheduleCount;
  final int? yearlyServicedMaintenanceScheduleCount;
  final int? yearlyNonServicedMaintenanceScheduleCount;
  final int? monthlyServicedMaintenanceScheduleCount;
  final int? monthlyNonServicedMaintenanceScheduleCount;
  final List<MonthlyMaintenanceSummary>? monthlyMaintenanceSummary;
  final MaintenanceScheduleByProject? maintenanceScheduleByProject;
  final ClientRelation? clientRelation;
  final List<ProjectUser>? usersForClients;
  final List<dynamic>? representative;
  final List<MaintenanceSchedule>? maintenanceSchedules;
  final List<dynamic>? projectPump;
  final MaintenanceStatus? johkasouModel;

  Project({
    required this.projectId,
    required this.pjCode,
    required this.projectName,
    required this.location,
    this.projectLocationId,
    required this.capacity,
    this.projectStatus,
    this.maintenanceStatus,
    this.contractedDate,
    this.expireDate,
    required this.client,
    this.pic,
    this.remarks,
    this.projectType,
    this.projectFacilities,
    required this.users,
    required this.branchId,
    required this.companyId,
    this.modules,
    this.projectLocation,
    this.branch,
    this.bdmName,
    this.totalServiceCount,
    this.totalServicedCount,
    this.lastServiceMonth,
    this.servicedMaintenanceScheduleCount,
    this.nonServicedMaintenanceScheduleCount,
    this.totalMaintenanceScheduleCount,
    this.yearlyServicedMaintenanceScheduleCount,
    this.yearlyNonServicedMaintenanceScheduleCount,
    this.monthlyServicedMaintenanceScheduleCount,
    this.monthlyNonServicedMaintenanceScheduleCount,
    this.monthlyMaintenanceSummary,
    this.maintenanceScheduleByProject,
    this.clientRelation,
    this.usersForClients,
    this.representative,
    this.maintenanceSchedules,
    this.projectPump,
    this.johkasouModel,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['project_id'] is int ? json['project_id'] : 0,
      pjCode: json['pj_code']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      location: json['location']?.toString() ??
          (json['project_location'] is Map
              ? (json['project_location']['district']?.toString() ?? '')
              : ''),
      projectLocationId: json['project_location_id'] is int
          ? json['project_location_id']
          : null,
      capacity: json['capacity']?.toString() ?? '',
      projectStatus:
          json['project_status'] != null && json['project_status'] is Map
              ? MaintenanceStatus.fromJson(json['project_status'])
              : null,
      maintenanceStatus: json['maintenance_status'] != null &&
              json['maintenance_status'] is Map
          ? MaintenanceStatus.fromJson(json['maintenance_status'])
          : null,
      contractedDate: json['contracted_date']?.toString(),
      expireDate: json['expire_date']?.toString(),
      client: json['client'] is int
          ? Client.placeholder(json['client'])
          : json['client'] != null && json['client'] is Map
              ? Client.fromJson(json['client'] as Map<String, dynamic>)
              : Client.placeholder(0),
      pic: json['pic'] is int
          ? User.placeholder(json['pic'])
          : json['pic'] != null && json['pic'] is Map
              ? User.fromJson(json['pic'] as Map<String, dynamic>)
              : null,
      remarks: json['remarks']?.toString(),
      projectType: json['project_type'] != null && json['project_type'] is Map
          ? MaintenanceStatus.fromJson(json['project_type'])
          : null,
      projectFacilities: json['project_facilities'] != null &&
              json['project_facilities'] is Map
          ? MaintenanceStatus.fromJson(json['project_facilities'])
          : null,
      users: json['users'] is List ? List<String>.from(json['users']) : [],
      branchId: json['branch'] is int ? json['branch'] : 0,
      companyId: json['company_id'] is int ? json['company_id'] : 0,
      modules: json['project_module'] != null && json['project_module'] is List
          ? (json['project_module'] as List)
              .where((module) => module is Map && module.isNotEmpty)
              .map((module) =>
                  ProjectModule.fromJson(module as Map<String, dynamic>))
              .toList()
          : null,
      projectLocation:
          json['project_location'] != null && json['project_location'] is Map
              ? ProjectLocation.fromJson(
                  json['project_location'] as Map<String, dynamic>)
              : null,
      branch: json['branches'] != null && json['branches'] is Map
          ? Branch.fromJson(json['branches'] as Map<String, dynamic>)
          : null,
      bdmName: json['bdm_name'] != null && json['bdm_name'] is Map
          ? BdmName.fromJson(json['bdm_name'])
          : null,
      totalServiceCount: json['total_service_count'] is int
          ? json['total_service_count']
          : null,
      totalServicedCount: json['total_serviced_count'] is int
          ? json['total_serviced_count']
          : null,
      lastServiceMonth: json['last_service_month']?.toString(),
      servicedMaintenanceScheduleCount:
          json['serviced_maintenance_schedule_count'] is int
              ? json['serviced_maintenance_schedule_count']
              : null,
      nonServicedMaintenanceScheduleCount:
          json['non_serviced_maintenance_schedule_count'] is int
              ? json['non_serviced_maintenance_schedule_count']
              : null,
      totalMaintenanceScheduleCount:
          json['total_maintenance_schedule_count'] is int
              ? json['total_maintenance_schedule_count']
              : null,
      yearlyServicedMaintenanceScheduleCount:
          json['yearly_serviced_maintenance_schedule_count'] is int
              ? json['yearly_serviced_maintenance_schedule_count']
              : null,
      yearlyNonServicedMaintenanceScheduleCount:
          json['yearly_non_serviced_maintenance_schedule_count'] is int
              ? json['yearly_non_serviced_maintenance_schedule_count']
              : null,
      monthlyServicedMaintenanceScheduleCount:
          json['monthly_serviced_maintenance_schedule_count'] is int
              ? json['monthly_serviced_maintenance_schedule_count']
              : null,
      monthlyNonServicedMaintenanceScheduleCount:
          json['monthly_non_serviced_maintenance_schedule_count'] is int
              ? json['monthly_non_serviced_maintenance_schedule_count']
              : null,
      monthlyMaintenanceSummary: json['monthly_maintenance_summary'] != null &&
              json['monthly_maintenance_summary'] is List
          ? (json['monthly_maintenance_summary'] as List)
              .map((item) => MonthlyMaintenanceSummary.fromJson(item))
              .toList()
          : null,
      maintenanceScheduleByProject:
          json['maintenance_schedule_by_project'] != null &&
                  json['maintenance_schedule_by_project'] is Map
              ? MaintenanceScheduleByProject.fromJson(
                  json['maintenance_schedule_by_project'])
              : null,
      clientRelation:
          json['client_relation'] != null && json['client_relation'] is Map
              ? ClientRelation.fromJson(json['client_relation'])
              : null,
      usersForClients:
          json['users_for_clients'] != null && json['users_for_clients'] is List
              ? (json['users_for_clients'] as List)
                  .map((item) => ProjectUser.fromJson(item))
                  .toList()
              : null,
      representative: json['representative'] is List
          ? List<dynamic>.from(json['representative'])
          : null,
      maintenanceSchedules: json['maintenance_schedules'] != null &&
              json['maintenance_schedules'] is List
          ? (json['maintenance_schedules'] as List)
              .map((item) => MaintenanceSchedule.fromJson(item))
              .toList()
          : null,
      projectPump: json['project_pump'] is List
          ? List<dynamic>.from(json['project_pump'])
          : null,
      johkasouModel:
          json['johkasou_model'] != null && json['johkasou_model'] is Map
              ? MaintenanceStatus.fromJson(json['johkasou_model'])
              : null,
    );
  }
}

class MaintenanceStatus {
  final int id;
  final String name;
  final int status;
  final String? createdAt;
  final String? updatedAt;
  final int? duration;
  final int? servicePerAlumn;

  MaintenanceStatus({
    required this.id,
    required this.name,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.duration,
    this.servicePerAlumn,
  });

  factory MaintenanceStatus.fromJson(Map<String, dynamic> json) {
    return MaintenanceStatus(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      duration: json['duration'] is int ? json['duration'] : null,
      servicePerAlumn:
          json['service_per_alumn'] is int ? json['service_per_alumn'] : null,
    );
  }
}

class BdmName {
  final int id;
  final String name;
  final int status;
  final String? createdAt;
  final String? updatedAt;
  final String? phone;
  final String? email;

  BdmName({
    required this.id,
    required this.name,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.email,
  });

  factory BdmName.fromJson(Map<String, dynamic> json) {
    return BdmName(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class MonthlyMaintenanceSummary {
  final String month;
  final int totalServiced;
  final int totalNonServiced;
  final List<MaintenanceSchedule> schedules;

  MonthlyMaintenanceSummary({
    required this.month,
    required this.totalServiced,
    required this.totalNonServiced,
    required this.schedules,
  });

  factory MonthlyMaintenanceSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyMaintenanceSummary(
      month: json['month']?.toString() ?? '',
      totalServiced: json['total_serviced'] is int ? json['total_serviced'] : 0,
      totalNonServiced:
          json['total_non_serviced'] is int ? json['total_non_serviced'] : 0,
      schedules: json['schedules'] is List
          ? (json['schedules'] as List)
              .map((item) => MaintenanceSchedule.fromJson(item))
              .toList()
          : [],
    );
  }
}

class MaintenanceScheduleByProject {
  final List<ServicedSchedule> serviced;
  final List<NonServicedSchedule> nonServiced;

  MaintenanceScheduleByProject({
    required this.serviced,
    required this.nonServiced,
  });

  factory MaintenanceScheduleByProject.fromJson(Map<String, dynamic> json) {
    return MaintenanceScheduleByProject(
      serviced: json['serviced'] is List
          ? (json['serviced'] as List)
              .map((item) => ServicedSchedule.fromJson(item))
              .toList()
          : [],
      nonServiced: json['non_serviced'] is List
          ? (json['non_serviced'] as List)
              .map((item) => NonServicedSchedule.fromJson(item))
              .toList()
          : [],
    );
  }
}

class ServicedSchedule {
  final int id;
  final String taskDescription;
  final int projectId;
  final int taskId;
  final int scheduleCount;

  ServicedSchedule({
    required this.id,
    required this.taskDescription,
    required this.projectId,
    required this.taskId,
    required this.scheduleCount,
  });

  factory ServicedSchedule.fromJson(Map<String, dynamic> json) {
    return ServicedSchedule(
      id: json['id'] is int ? json['id'] : 0,
      taskDescription: json['task_description']?.toString() ?? '',
      projectId: json['project_id'] is int ? json['project_id'] : 0,
      taskId: json['task_id'] is int ? json['task_id'] : 0,
      scheduleCount: json['schedule_count'] is int ? json['schedule_count'] : 0,
    );
  }
}

class NonServicedSchedule {
  final int id;
  final String taskDescription;
  final int projectId;
  final int taskId;
  final int scheduleCount;

  NonServicedSchedule({
    required this.id,
    required this.taskDescription,
    required this.projectId,
    required this.taskId,
    required this.scheduleCount,
  });

  factory NonServicedSchedule.fromJson(Map<String, dynamic> json) {
    return NonServicedSchedule(
      id: json['id'] is int ? json['id'] : 0,
      taskDescription: json['task_description']?.toString() ?? '',
      projectId: json['project_id'] is int ? json['project_id'] : 0,
      taskId: json['task_id'] is int ? json['task_id'] : 0,
      scheduleCount: json['schedule_count'] is int ? json['schedule_count'] : 0,
    );
  }
}

class MaintenanceSchedule {
  final int id;
  final int projectId;
  final String maintenanceDate;
  final String? frequency;
  final int groupId;
  final String? task;
  final int taskId;
  final String? nextMaintenanceDate;
  final String? remarks;
  final String createdAt;
  final String updatedAt;
  final int status;
  final int isBulkAssign;
  final int? jokhasouModelId;
  final String? serialNo;
  final List<Assignment> assignments;
  final TaskInfo taskInfo;
  final GroupInfo group;

  MaintenanceSchedule({
    required this.id,
    required this.projectId,
    required this.maintenanceDate,
    this.frequency,
    required this.groupId,
    this.task,
    required this.taskId,
    this.nextMaintenanceDate,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.isBulkAssign,
    this.jokhasouModelId,
    this.serialNo,
    required this.assignments,
    required this.taskInfo,
    required this.group,
  });

  factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
    return MaintenanceSchedule(
      id: json['id'] is int ? json['id'] : 0,
      projectId: json['project_id'] is int ? json['project_id'] : 0,
      maintenanceDate: json['maintenance_date']?.toString() ?? '',
      frequency: json['frequency']?.toString(),
      groupId: json['group_id'] is int ? json['group_id'] : 0,
      task: json['task']?.toString(),
      taskId: json['task_id'] is int ? json['task_id'] : 0,
      nextMaintenanceDate: json['next_maintenance_date']?.toString(),
      remarks: json['remarks']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      isBulkAssign: json['is_bulk_assign'] is int ? json['is_bulk_assign'] : 0,
      jokhasouModelId:
          json['jokhasou_model_id'] is int ? json['jokhasou_model_id'] : null,
      serialNo: json['serial_no']?.toString(),
      assignments: json['assignments'] is List
          ? (json['assignments'] as List)
              .map((item) => Assignment.fromJson(item))
              .toList()
          : [],
      taskInfo: json['task_info'] != null
          ? TaskInfo.fromJson(json['task_info'])
          : TaskInfo(
              id: 0,
              taskDescription: '',
              status: 0,
              createdAt: '',
              updatedAt: ''),
      group: json['group'] != null
          ? GroupInfo.fromJson(json['group'])
          : GroupInfo(id: 0, name: ''),
    );
  }
}

class Assignment {
  final int id;
  final int scheduleId;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Assignment({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] is int ? json['id'] : 0,
      scheduleId: json['schedule_id'] is int ? json['schedule_id'] : 0,
      userId: json['user_id'] is int ? json['user_id'] : 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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
      id: json['id'] is int ? json['id'] : 0,
      taskDescription: json['task_description']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class GroupInfo {
  final int id;
  final String name;

  GroupInfo({
    required this.id,
    required this.name,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class Branch {
  final int id;
  final String name;
  final int companyId;
  final String code;
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
    required this.name,
    required this.companyId,
    required this.code,
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
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      companyId: json['company_id'] is int ? json['company_id'] : 0,
      code: json['code']?.toString() ?? '',
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

class ProjectModule {
  final int id;
  final int projectId;
  final String module;
  final String? number;
  final String? blowerModel;
  final String? quantity;
  final String? slNumber;
  final String? remark;
  final String? commissionaryDate;
  final int status;
  final String createdAt;
  final String updatedAt;

  ProjectModule({
    required this.id,
    required this.projectId,
    required this.module,
    this.number,
    this.blowerModel,
    this.quantity,
    this.slNumber,
    this.remark,
    this.commissionaryDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModule.fromJson(Map<String, dynamic> json) {
    return ProjectModule(
      id: json['id'] is int ? json['id'] : 0,
      projectId: json['project_id'] is int ? json['project_id'] : 0,
      module: json['module']?.toString() ?? '',
      number: json['number']?.toString(),
      blowerModel: json['blower_model']?.toString(),
      quantity: json['quantity']?.toString(),
      slNumber: json['sl_number']?.toString(),
      remark: json['remark']?.toString(),
      commissionaryDate: json['commissionary_date']?.toString(),
      status: json['status'] is int ? json['status'] : 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class ProjectLocation {
  final int id;
  final int codeId;
  final int districtId;
  final int provinceId;
  final String dCode;
  final String district;
  final String division;
  final String country;
  final String createdAt;
  final String updatedAt;
  final int countryId;

  ProjectLocation({
    required this.id,
    required this.codeId,
    required this.districtId,
    required this.provinceId,
    required this.dCode,
    required this.district,
    required this.division,
    required this.country,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
  });

  factory ProjectLocation.fromJson(Map<String, dynamic> json) {
    return ProjectLocation(
      id: json['id'] is int ? json['id'] : 0,
      codeId: json['code_id'] is int ? json['code_id'] : 0,
      districtId: json['district_id'] is int ? json['district_id'] : 0,
      provinceId: json['province_id'] is int ? json['province_id'] : 0,
      dCode: json['d_code']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      division: json['division']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      countryId: json['country_id'] is int ? json['country_id'] : 0,
    );
  }
}

class Client {
  final int id;
  final String name;
  final String code;
  final String phone;
  final String email;
  final String? photo;
  final String? address;
  final String? shippingAddress;
  final String type;
  final String? nid;
  final int? creditLimit;
  final String? tin;
  final String? bin;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? website;
  final int serviceProviderCompanyId;
  final Company? company;

  Client({
    required this.id,
    required this.name,
    required this.code,
    required this.phone,
    required this.email,
    this.photo,
    this.address,
    this.shippingAddress,
    required this.type,
    this.nid,
    this.creditLimit,
    this.tin,
    this.bin,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.website,
    required this.serviceProviderCompanyId,
    this.company,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      photo: json['photo']?.toString(),
      address: json['address']?.toString(),
      shippingAddress: json['shipping_address']?.toString(),
      type: json['type']?.toString() ?? '',
      nid: json['nid']?.toString(),
      creditLimit: json['credit_limit'] is int ? json['credit_limit'] : null,
      tin: json['tin']?.toString(),
      bin: json['bin']?.toString(),
      status: json['status'] is int ? json['status'] : 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      website: json['website']?.toString(),
      serviceProviderCompanyId: json['service_provider_company_id'] is int
          ? json['service_provider_company_id']
          : 0,
      company: json['company'] != null
          ? Company.fromJson(json['company'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Client.placeholder(int id) {
    return Client(
      id: id,
      name: 'Loading...',
      code: '',
      phone: '',
      email: '',
      type: '',
      status: 0,
      createdAt: '',
      updatedAt: '',
      serviceProviderCompanyId: 0,
    );
  }
}

class Company {
  final int id;
  final String name;
  final String slug;
  final String? companyCode;
  final String? contactPerson;
  final String contactNumber;
  final String contactEmail;
  final String contactAddress;
  final String companyTin;
  final String companyBin;
  final String? businessType;
  final String createdAt;
  final String updatedAt;
  final int countryId;

  Company({
    required this.id,
    required this.name,
    required this.slug,
    this.companyCode,
    this.contactPerson,
    required this.contactNumber,
    required this.contactEmail,
    required this.contactAddress,
    required this.companyTin,
    required this.companyBin,
    this.businessType,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      companyCode: json['company_code']?.toString(),
      contactPerson: json['contact_person']?.toString(),
      contactNumber: json['contact_number']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      contactAddress: json['contact_address']?.toString() ?? '',
      companyTin: json['company_tin']?.toString() ?? '',
      companyBin: json['company_bin']?.toString() ?? '',
      businessType: json['business_type']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      countryId: json['country_id'] is int ? json['country_id'] : 0,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final Company company;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      company: json['company'] != null
          ? Company.fromJson(json['company'] as Map<String, dynamic>)
          : Company(
              id: 0,
              name: '',
              slug: '',
              contactNumber: '',
              contactEmail: '',
              contactAddress: '',
              companyTin: '',
              companyBin: '',
              createdAt: '',
              updatedAt: '',
              countryId: 0,
            ),
    );
  }

  factory User.placeholder(int id) {
    return User(
      id: id,
      name: 'N/A',
      email: '',
      phone: '',
      company: Company(
        id: 0,
        name: '',
        slug: '',
        contactNumber: '',
        contactEmail: '',
        contactAddress: '',
        companyTin: '',
        companyBin: '',
        createdAt: '',
        updatedAt: '',
        countryId: 0,
      ),
    );
  }
}

class ClientRelation {
  final int id;
  final int companyId;
  final int? branchId;
  final String name;
  final String email;
  final String timezone;
  final String phone;
  final String photo;
  final int status;
  final String emailVerifiedAt;
  final String? rememberToken;
  final String createdAt;
  final String updatedAt;
  final Company company;

  ClientRelation({
    required this.id,
    required this.companyId,
    this.branchId,
    required this.name,
    required this.email,
    required this.timezone,
    required this.phone,
    required this.photo,
    required this.status,
    required this.emailVerifiedAt,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    required this.company,
  });

  factory ClientRelation.fromJson(Map<String, dynamic> json) {
    return ClientRelation(
      id: json['id'] is int ? json['id'] : 0,
      companyId: json['company_id'] is int ? json['company_id'] : 0,
      branchId: json['branch_id'] is int ? json['branch_id'] : null,
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? 'N/A',
      timezone: json['timezone']?.toString() ?? '',
      phone: json['phone']?.toString() ?? 'N/A',
      photo: json['photo']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : 0,
      emailVerifiedAt: json['email_verified_at']?.toString() ?? '',
      rememberToken: json['remember_token']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : Company(
              id: 0,
              name: 'Unknown',
              slug: '',
              contactNumber: '',
              contactEmail: '',
              contactAddress: '',
              companyTin: '',
              companyBin: '',
              createdAt: '',
              updatedAt: '',
              countryId: 0,
            ),
    );
  }
}

class ProjectUser {
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
  final UserCompany company;

  ProjectUser({
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
    required this.company,
  });

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      id: json['id'] is int ? json['id'] : 0,
      companyId: json['company_id'] is int ? json['company_id'] : 0,
      branchId: json['branch_id'] is int ? json['branch_id'] : null,
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? 'N/A',
      phone: json['phone']?.toString() ?? 'N/A',
      photo: json['photo']?.toString(),
      status: json['status'] is int ? json['status'] : 0,
      emailVerifiedAt: json['email_verified_at']?.toString(),
      rememberToken: json['remember_token']?.toString(),
      createdAt: json['created_at']?.toString() ?? 'Not set',
      updatedAt: json['updated_at']?.toString() ?? 'Not set',
      company: json['company'] != null
          ? UserCompany.fromJson(json['company'])
          : UserCompany(
              id: 0,
              name: 'Unknown',
              slug: '',
              logo: null,
              brandLogo: null,
              companyCode: '',
              orderPrefix: '',
              businessType: null,
              contactPerson: '',
              contactNumber: '',
              contactEmail: '',
              contactAddress: '',
              companyTin: '',
              companyBin: '',
              countryId: 0,
              createdAt: '',
              updatedAt: '',
            ),
    );
  }
}

class UserCompany {
  final int id;
  final String name;
  final String slug;
  final String? logo;
  final String? brandLogo;
  final String companyCode;
  final String orderPrefix;
  final String? businessType;
  final String contactPerson;
  final String contactNumber;
  final String contactEmail;
  final String contactAddress;
  final String companyTin;
  final String companyBin;
  final String createdAt;
  final String updatedAt;
  final int countryId;

  UserCompany({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.brandLogo,
    required this.companyCode,
    required this.orderPrefix,
    this.businessType,
    required this.contactPerson,
    required this.contactNumber,
    required this.contactEmail,
    required this.contactAddress,
    required this.companyTin,
    required this.companyBin,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
  });

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? 'Unknown',
      slug: json['slug']?.toString() ?? 'N/A',
      logo: json['logo']?.toString(),
      brandLogo: json['brand_logo']?.toString(),
      companyCode: json['company_code']?.toString() ?? 'N/A',
      orderPrefix: json['order_prefix']?.toString() ?? 'N/A',
      businessType: json['business_type']?.toString(),
      contactPerson: json['contact_person']?.toString() ?? 'N/A',
      contactNumber: json['contact_number']?.toString() ?? 'N/A',
      contactEmail: json['contact_email']?.toString() ?? 'N/A',
      contactAddress: json['contact_address']?.toString() ?? 'N/A',
      companyTin: json['company_tin']?.toString() ?? 'N/A',
      companyBin: json['company_bin']?.toString() ?? 'N/A',
      createdAt: json['created_at']?.toString() ?? 'Not set',
      updatedAt: json['updated_at']?.toString() ?? 'Not set',
      countryId: json['country_id'] is int ? json['country_id'] : 0,
    );
  }
}
