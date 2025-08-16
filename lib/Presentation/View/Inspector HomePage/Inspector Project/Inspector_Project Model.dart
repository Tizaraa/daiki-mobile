// // class Project {
// //   final int projectId;
// //   final String pjCode;
// //   final String projectName;
// //   final String location;
// //   final String capacity;
// //   final String projectStatus;
// //   final String maintenanceStatus;
// //   final String? contractedDate;
// //   final String? expireDate;
// //   final Client client;
// //   final User pic;
// //   final String? remarks;
// //   final String? projectType;
// //   final String? projectFacilities;
// //   final List<String> users;
// //   final int branchId;
// //   final int companyId;
// //   final List<ProjectModule>? modules;
// //   final ProjectLocation? projectLocation;
// //   final Branch? branch; // New field for branch
// //
// //   Project({
// //     required this.projectId,
// //     required this.pjCode,
// //     required this.projectName,
// //     required this.location,
// //     required this.capacity,
// //     required this.projectStatus,
// //     required this.maintenanceStatus,
// //     this.contractedDate,
// //     this.expireDate,
// //     required this.client,
// //     required this.pic,
// //     this.remarks,
// //     this.projectType,
// //     this.projectFacilities,
// //     required this.users,
// //     required this.branchId,
// //     required this.companyId,
// //     this.modules,
// //     this.projectLocation,
// //     this.branch,
// //   });
// //
// //   factory Project.fromJson(Map<String, dynamic> json) {
// //     return Project(
// //       projectId: json['project_id'] is int ? json['project_id'] : 0,
// //       pjCode: json['pj_code']?.toString() ?? '',
// //       projectName: json['project_name']?.toString() ?? '',
// //       location: json['location']?.toString() ??
// //           (json['project_location'] is Map
// //               ? (json['project_location'] as Map<String, dynamic>)['district']?.toString() ?? ''
// //               : ''),
// //       capacity: json['capacity']?.toString() ?? '',
// //       projectStatus: json['project_status']?.toString() ?? '',
// //       maintenanceStatus: json['maintenance_status'] is Map
// //           ? (json['maintenance_status'] as Map<String, dynamic>)['name']?.toString() ?? ''
// //           : json['maintenance_status']?.toString() ?? '',
// //       contractedDate: json['contracted_date']?.toString(),
// //       expireDate: json['expire_date']?.toString(),
// //       client: json['client'] is int
// //           ? Client.placeholder(json['client'])
// //           : json['client'] != null && json['client'] is Map
// //           ? Client.fromJson(json['client'] as Map<String, dynamic>)
// //           : Client.placeholder(0),
// //       pic: json['pic'] is int
// //           ? User.placeholder(json['pic'])
// //           : json['pic'] != null && json['pic'] is Map
// //           ? User.fromJson(json['pic'] as Map<String, dynamic>)
// //           : User.placeholder(0),
// //       remarks: json['remarks']?.toString(),
// //       projectType: json['project_type']?.toString(),
// //       projectFacilities: json['project_facilities']?.toString(),
// //       users: json['users'] is List ? List<String>.from(json['users']) : [],
// //       branchId: json['branch'] is int ? json['branch'] : 0,
// //       companyId: json['company_id'] is int ? json['company_id'] : 0,
// //       modules: json['project_module'] != null && json['project_module'] is List
// //           ? (json['project_module'] as List)
// //           .where((module) => module is Map && module.isNotEmpty)
// //           .map((module) => ProjectModule.fromJson(module as Map<String, dynamic>))
// //           .toList()
// //           : null,
// //       projectLocation: json['project_location'] != null && json['project_location'] is Map
// //           ? ProjectLocation.fromJson(json['project_location'] as Map<String, dynamic>)
// //           : null,
// //       branch: json['branches'] != null && json['branches'] is Map
// //           ? Branch.fromJson(json['branches'] as Map<String, dynamic>)
// //           : null,
// //     );
// //   }
// // }
// //
// // class Branch {
// //   final int id;
// //   final String name;
// //
// //   Branch({
// //     required this.id,
// //     required this.name,
// //   });
// //
// //   factory Branch.fromJson(Map<String, dynamic> json) {
// //     return Branch(
// //       id: json['id'] is int ? json['id'] : 0,
// //       name: json['name']?.toString() ?? '',
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'id': id,
// //       'name': name,
// //     };
// //   }
// // }
// //
// // class ProjectModule {
// //   final int id;
// //   final int projectId;
// //   final String module;
// //   final String? number;
// //   final String? blowerModel;
// //   final String? quantity;
// //   final String? slNumber;
// //   final String? remark;
// //   final String? commissionaryDate;
// //   final int status;
// //
// //   ProjectModule({
// //     required this.id,
// //     required this.projectId,
// //     required this.module,
// //     this.number,
// //     this.blowerModel,
// //     this.quantity,
// //     this.slNumber,
// //     this.remark,
// //     this.commissionaryDate,
// //     required this.status,
// //   });
// //
// //   factory ProjectModule.fromJson(Map<String, dynamic> json) {
// //     return ProjectModule(
// //       id: json['id'] is int ? json['id'] : 0,
// //       projectId: json['project_id'] is int ? json['project_id'] : 0,
// //       module: json['module']?.toString() ?? '',
// //       number: json['number']?.toString(),
// //       blowerModel: json['blower_model']?.toString(),
// //       quantity: json['quantity']?.toString(),
// //       slNumber: json['sl_number']?.toString(),
// //       remark: json['remark']?.toString(),
// //       commissionaryDate: json['commissionary_date']?.toString(),
// //       status: json['status'] is int ? json['status'] : 0,
// //     );
// //   }
// // }
// //
// // class ProjectLocation {
// //   final int id;
// //   final int codeId;
// //   final int districtId;
// //   final int provinceId;
// //   final String dCode;
// //   final String district;
// //   final String division;
// //   final String country;
// //   final String createdAt;
// //   final String updatedAt;
// //   final int countryId;
// //
// //   ProjectLocation({
// //     required this.id,
// //     required this.codeId,
// //     required this.districtId,
// //     required this.provinceId,
// //     required this.dCode,
// //     required this.district,
// //     required this.division,
// //     required this.country,
// //     required this.createdAt,
// //     required this.updatedAt,
// //     required this.countryId,
// //   });
// //
// //   factory ProjectLocation.fromJson(Map<String, dynamic> json) {
// //     return ProjectLocation(
// //       id: json['id'] is int ? json['id'] : 0,
// //       codeId: json['code_id'] is int ? json['code_id'] : 0,
// //       districtId: json['district_id'] is int ? json['district_id'] : 0,
// //       provinceId: json['province_id'] is int ? json['province_id'] : 0,
// //       dCode: json['d_code']?.toString() ?? '',
// //       district: json['district']?.toString() ?? '',
// //       division: json['division']?.toString() ?? '',
// //       country: json['country']?.toString() ?? '',
// //       createdAt: json['created_at']?.toString() ?? '',
// //       updatedAt: json['updated_at']?.toString() ?? '',
// //       countryId: json['country_id'] is int ? json['country_id'] : 0,
// //     );
// //   }
// // }
// //
// // class Client {
// //   final int id;
// //   final String name;
// //   final String code;
// //   final String phone;
// //   final String email;
// //   final String address;
// //   final String type;
// //   final Company? company;
// //
// //   Client({
// //     required this.id,
// //     required this.name,
// //     this.code = '',
// //     required this.phone,
// //     required this.email,
// //     required this.address,
// //     required this.type,
// //     this.company,
// //   });
// //
// //   factory Client.fromJson(Map<String, dynamic> json) {
// //     return Client(
// //       id: json['id'] is int ? json['id'] : 0,
// //       name: json['name']?.toString() ?? '',
// //       code: json['code']?.toString() ?? '',
// //       phone: json['phone']?.toString() ?? '',
// //       email: json['email']?.toString() ?? '',
// //       address: json['address']?.toString() ?? '',
// //       type: json['type']?.toString() ?? '',
// //       company: json['company'] != null ? Company.fromJson(json['company'] as Map<String, dynamic>) : null,
// //     );
// //   }
// //
// //   factory Client.placeholder(int id) {
// //     return Client(
// //       id: id,
// //       name: 'Loading...',
// //       phone: '',
// //       email: '',
// //       address: '',
// //       type: '',
// //     );
// //   }
// // }
// //
// // class Company {
// //   final int id;
// //   final String name;
// //   final String slug;
// //   final String? companyCode;
// //   final String? contactPerson;
// //   final String contactNumber;
// //   final String contactEmail;
// //   final String contactAddress;
// //   final String companyTin;
// //   final String companyBin;
// //   final String? businessType;
// //
// //   Company({
// //     required this.id,
// //     required this.name,
// //     required this.slug,
// //     this.companyCode,
// //     this.contactPerson,
// //     required this.contactNumber,
// //     required this.contactEmail,
// //     required this.contactAddress,
// //     required this.companyTin,
// //     required this.companyBin,
// //     this.businessType,
// //   });
// //
// //   factory Company.fromJson(Map<String, dynamic> json) {
// //     return Company(
// //       id: json['id'] is int ? json['id'] : 0,
// //       name: json['name']?.toString() ?? '',
// //       slug: json['slug']?.toString() ?? '',
// //       companyCode: json['company_code']?.toString(),
// //       contactPerson: json['contact_person']?.toString(),
// //       contactNumber: json['contact_number']?.toString() ?? '',
// //       contactEmail: json['contact_email']?.toString() ?? '',
// //       contactAddress: json['contact_address']?.toString() ?? '',
// //       companyTin: json['company_tin']?.toString() ?? '',
// //       companyBin: json['company_bin']?.toString() ?? '',
// //       businessType: json['business_type']?.toString(),
// //     );
// //   }
// // }
// //
// // class User {
// //   final int id;
// //   final String name;
// //   final String email;
// //   final String phone;
// //   final Company company;
// //
// //   User({
// //     required this.id,
// //     required this.name,
// //     required this.email,
// //     required this.phone,
// //     required this.company,
// //   });
// //
// //   factory User.fromJson(Map<String, dynamic> json) {
// //     return User(
// //       id: json['id'] is int ? json['id'] : 0,
// //       name: json['name']?.toString() ?? '',
// //       email: json['email']?.toString() ?? '',
// //       phone: json['phone']?.toString() ?? '',
// //       company: json['company'] != null
// //           ? Company.fromJson(json['company'] as Map<String, dynamic>)
// //           : Company(
// //         id: 0,
// //         name: '',
// //         slug: '',
// //         contactNumber: '',
// //         contactEmail: '',
// //         contactAddress: '',
// //         companyTin: '',
// //         companyBin: '',
// //       ),
// //     );
// //   }
// //
// //   factory User.placeholder(int id) {
// //     return User(
// //       id: id,
// //       name: 'Loading...',
// //       email: '',
// //       phone: '',
// //       company: Company(
// //         id: 0,
// //         name: '',
// //         slug: '',
// //         contactNumber: '',
// //         contactEmail: '',
// //         contactAddress: '',
// //         companyTin: '',
// //         companyBin: '',
// //       ),
// //     );
// //   }
// // }
// //
// // class ProjectUser {
// //   final int id;
// //   final int companyId;
// //   final int? branchId;
// //   final String name;
// //   final String email;
// //   final String phone;
// //   final String? photo;
// //   final int status;
// //   final String? emailVerifiedAt;
// //   final String? rememberToken;
// //   final String createdAt;
// //   final String updatedAt;
// //   final UserCompany company;
// //
// //   ProjectUser({
// //     required this.id,
// //     required this.companyId,
// //     this.branchId,
// //     required this.name,
// //     required this.email,
// //     required this.phone,
// //     this.photo,
// //     required this.status,
// //     this.emailVerifiedAt,
// //     this.rememberToken,
// //     required this.createdAt,
// //     required this.updatedAt,
// //     required this.company,
// //   });
// //
// //   factory ProjectUser.fromJson(Map<String, dynamic> json) {
// //     print('Parsing ProjectUser JSON: $json');
// //     return ProjectUser(
// //       id: json['id'] ?? 0,
// //       companyId: json['company_id'] ?? 0,
// //       branchId: json['branch_id'],
// //       name: json['name'] ?? 'Unknown',
// //       email: json['email'] ?? 'N/A',
// //       phone: json['phone'] ?? 'N/A',
// //       photo: json['photo'],
// //       status: json['status'] ?? 0,
// //       emailVerifiedAt: json['email_verified_at'],
// //       rememberToken: json['remember_token'],
// //       createdAt: json['created_at'] ?? 'Not set',
// //       updatedAt: json['updated_at'] ?? 'Not set',
// //       company: json['company'] != null
// //           ? UserCompany.fromJson(json['company'])
// //           : UserCompany(
// //         id: 0,
// //         name: 'Unknown',
// //         slug: '',
// //         logo: null,
// //         brandLogo: null,
// //         companyCode: '',
// //         orderPrefix: '',
// //         businessType: null,
// //         contactPerson: '',
// //         contactNumber: '',
// //         contactEmail: '',
// //         contactAddress: '',
// //         companyTin: '',
// //         companyBin: '',
// //         createdAt: '',
// //         updatedAt: '',
// //         countryId: 0,
// //       ),
// //     );
// //   }
// // }
// //
// // class UserCompany {
// //   final int id;
// //   final String name;
// //   final String slug;
// //   final String? logo;
// //   final String? brandLogo;
// //   final String companyCode;
// //   final String orderPrefix;
// //   final String? businessType;
// //   final String contactPerson;
// //   final String contactNumber;
// //   final String contactEmail;
// //   final String contactAddress;
// //   final String companyTin;
// //   final String companyBin;
// //   final String createdAt;
// //   final String updatedAt;
// //   final int countryId;
// //
// //   UserCompany({
// //     required this.id,
// //     required this.name,
// //     required this.slug,
// //     this.logo,
// //     this.brandLogo,
// //     required this.companyCode,
// //     required this.orderPrefix,
// //     this.businessType,
// //     required this.contactPerson,
// //     required this.contactNumber,
// //     required this.contactEmail,
// //     required this.contactAddress,
// //     required this.companyTin,
// //     required this.companyBin,
// //     required this.createdAt,
// //     required this.updatedAt,
// //     required this.countryId,
// //   });
// //
// //   factory UserCompany.fromJson(Map<String, dynamic> json) {
// //     print('Parsing UserCompany JSON: $json');
// //     return UserCompany(
// //       id: json['id'] ?? 0,
// //       name: json['name'] ?? 'Unknown',
// //       slug: json['slug'] ?? 'N/A',
// //       logo: json['logo'],
// //       brandLogo: json['brand_logo'],
// //       companyCode: json['company_code'] ?? 'N/A',
// //       orderPrefix: json['order_prefix'] ?? 'N/A',
// //       businessType: json['business_type'],
// //       contactPerson: json['contact_person'] ?? 'N/A',
// //       contactNumber: json['contact_number'] ?? 'N/A',
// //       contactEmail: json['contact_email'] ?? 'N/A',
// //       contactAddress: json['contact_address'] ?? 'N/A',
// //       companyTin: json['company_tin'] ?? 'N/A',
// //       companyBin: json['company_bin'] ?? 'N/A',
// //       createdAt: json['created_at'] ?? 'Not set',
// //       updatedAt: json['updated_at'] ?? 'Not set',
// //       countryId: json['country_id'] ?? 0,
// //     );
// //   }
// // }
//
//
// class Project {
//   final int projectId;
//   final String pjCode;
//   final String projectName;
//   final String location;
//   final String capacity;
//   final String projectStatus;
//   final String maintenanceStatus;
//   final String? contractedDate;
//   final String? expireDate;
//   final Client client;
//   final User pic;
//   final String? remarks;
//   final String? projectType; // Now stores the 'name' value directly
//   final String? projectFacilities; // Now stores a comma-separated list of 'name' values
//   final List<String> users;
//   final int branchId;
//   final int companyId;
//   final List<ProjectModule>? modules;
//   final ProjectLocation? projectLocation;
//   final Branch? branch;
//
//   Project({
//     required this.projectId,
//     required this.pjCode,
//     required this.projectName,
//     required this.location,
//     required this.capacity,
//     required this.projectStatus,
//     required this.maintenanceStatus,
//     this.contractedDate,
//     this.expireDate,
//     required this.client,
//     required this.pic,
//     this.remarks,
//     this.projectType,
//     this.projectFacilities,
//     required this.users,
//     required this.branchId,
//     required this.companyId,
//     this.modules,
//     this.projectLocation,
//     this.branch,
//   });
//
//   factory Project.fromJson(Map<String, dynamic> json) {
//     String? parseNameFromJson(dynamic value) {
//       if (value is Map<String, dynamic>) {
//         return value['name']?.toString();
//       }
//       return null;
//     }
//
//     String? parseFacilitiesFromJson(dynamic value) {
//       if (value is List) {
//         final names = value
//             .where((item) => item is Map<String, dynamic> && item['name'] != null)
//             .map((item) => item['name'].toString())
//             .toList();
//         return names.isNotEmpty ? names.join(', ') : null;
//       } else if (value is Map<String, dynamic>) {
//         return value['name']?.toString();
//       }
//       return null;
//     }
//
//     return Project(
//       projectId: json['project_id'] is int ? json['project_id'] : 0,
//       pjCode: json['pj_code']?.toString() ?? '',
//       projectName: json['project_name']?.toString() ?? '',
//       location: json['location']?.toString() ??
//           (json['project_location'] is Map
//               ? (json['project_location'] as Map<String, dynamic>)['district']?.toString() ?? ''
//               : ''),
//       capacity: json['capacity']?.toString() ?? '',
//       projectStatus: json['project_status']?.toString() ?? '',
//       maintenanceStatus: json['maintenance_status'] is Map
//           ? (json['maintenance_status'] as Map<String, dynamic>)['name']?.toString() ?? ''
//           : json['maintenance_status']?.toString() ?? '',
//       contractedDate: json['contracted_date']?.toString(),
//       expireDate: json['expire_date']?.toString(),
//       client: json['client'] is int
//           ? Client.placeholder(json['client'])
//           : json['client'] != null && json['client'] is Map
//           ? Client.fromJson(json['client'] as Map<String, dynamic>)
//           : Client.placeholder(0),
//       pic: json['pic'] is int
//           ? User.placeholder(json['pic'])
//           : json['pic'] != null && json['pic'] is Map
//           ? User.fromJson(json['pic'] as Map<String, dynamic>)
//           : User.placeholder(0),
//       remarks: json['remarks']?.toString(),
//       projectType: parseNameFromJson(json['project_type']),
//       projectFacilities: parseFacilitiesFromJson(json['project_facilities']),
//       users: json['users'] is List ? List<String>.from(json['users']) : [],
//       branchId: json['branch'] is int ? json['branch'] : 0,
//       companyId: json['company_id'] is int ? json['company_id'] : 0,
//       modules: json['project_module'] != null && json['project_module'] is List
//           ? (json['project_module'] as List)
//           .where((module) => module is Map && module.isNotEmpty)
//           .map((module) => ProjectModule.fromJson(module as Map<String, dynamic>))
//           .toList()
//           : null,
//       projectLocation: json['project_location'] != null && json['project_location'] is Map
//           ? ProjectLocation.fromJson(json['project_location'] as Map<String, dynamic>)
//           : null,
//       branch: json['branches'] != null && json['branches'] is Map
//           ? Branch.fromJson(json['branches'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }
//
// class Branch {
//   final int id;
//   final String name;
//
//   Branch({
//     required this.id,
//     required this.name,
//   });
//
//   factory Branch.fromJson(Map<String, dynamic> json) {
//     return Branch(
//       id: json['id'] is int ? json['id'] : 0,
//       name: json['name']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//     };
//   }
// }
//
// class ProjectModule {
//   final int id;
//   final int projectId;
//   final String module;
//   final String? number;
//   final String? blowerModel;
//   final String? quantity;
//   final String? slNumber;
//   final String? remark;
//   final String? commissionaryDate;
//   final int status;
//
//   ProjectModule({
//     required this.id,
//     required this.projectId,
//     required this.module,
//     this.number,
//     this.blowerModel,
//     this.quantity,
//     this.slNumber,
//     this.remark,
//     this.commissionaryDate,
//     required this.status,
//   });
//
//   factory ProjectModule.fromJson(Map<String, dynamic> json) {
//     return ProjectModule(
//       id: json['id'] is int ? json['id'] : 0,
//       projectId: json['project_id'] is int ? json['project_id'] : 0,
//       module: json['module']?.toString() ?? '',
//       number: json['number']?.toString(),
//       blowerModel: json['blower_model']?.toString(),
//       quantity: json['quantity']?.toString(),
//       slNumber: json['sl_number']?.toString(),
//       remark: json['remark']?.toString(),
//       commissionaryDate: json['commissionary_date']?.toString(),
//       status: json['status'] is int ? json['status'] : 0,
//     );
//   }
// }
//
// class ProjectLocation {
//   final int id;
//   final int codeId;
//   final int districtId;
//   final int provinceId;
//   final String dCode;
//   final String district;
//   final String division;
//   final String country;
//   final String createdAt;
//   final String updatedAt;
//   final int countryId;
//
//   ProjectLocation({
//     required this.id,
//     required this.codeId,
//     required this.districtId,
//     required this.provinceId,
//     required this.dCode,
//     required this.district,
//     required this.division,
//     required this.country,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.countryId,
//   });
//
//   factory ProjectLocation.fromJson(Map<String, dynamic> json) {
//     return ProjectLocation(
//       id: json['id'] is int ? json['id'] : 0,
//       codeId: json['code_id'] is int ? json['code_id'] : 0,
//       districtId: json['district_id'] is int ? json['district_id'] : 0,
//       provinceId: json['province_id'] is int ? json['province_id'] : 0,
//       dCode: json['d_code']?.toString() ?? '',
//       district: json['district']?.toString() ?? '',
//       division: json['division']?.toString() ?? '',
//       country: json['country']?.toString() ?? '',
//       createdAt: json['created_at']?.toString() ?? '',
//       updatedAt: json['updated_at']?.toString() ?? '',
//       countryId: json['country_id'] is int ? json['country_id'] : 0,
//     );
//   }
// }
//
// class Client {
//   final int id;
//   final String name;
//   final String code;
//   final String phone;
//   final String email;
//   final String address;
//   final String type;
//   final Company? company;
//
//   Client({
//     required this.id,
//     required this.name,
//     this.code = '',
//     required this.phone,
//     required this.email,
//     required this.address,
//     required this.type,
//     this.company,
//   });
//
//   factory Client.fromJson(Map<String, dynamic> json) {
//     return Client(
//       id: json['id'] is int ? json['id'] : 0,
//       name: json['name']?.toString() ?? '',
//       code: json['code']?.toString() ?? '',
//       phone: json['phone']?.toString() ?? '',
//       email: json['email']?.toString() ?? '',
//       address: json['address']?.toString() ?? '',
//       type: json['type']?.toString() ?? '',
//       company: json['company'] != null ? Company.fromJson(json['company'] as Map<String, dynamic>) : null,
//     );
//   }
//
//   factory Client.placeholder(int id) {
//     return Client(
//       id: id,
//       name: 'Loading...',
//       phone: '',
//       email: '',
//       address: '',
//       type: '',
//     );
//   }
// }
//
// class Company {
//   final int id;
//   final String name;
//   final String slug;
//   final String? companyCode;
//   final String? contactPerson;
//   final String contactNumber;
//   final String contactEmail;
//   final String contactAddress;
//   final String companyTin;
//   final String companyBin;
//   final String? businessType;
//
//   Company({
//     required this.id,
//     required this.name,
//     required this.slug,
//     this.companyCode,
//     this.contactPerson,
//     required this.contactNumber,
//     required this.contactEmail,
//     required this.contactAddress,
//     required this.companyTin,
//     required this.companyBin,
//     this.businessType,
//   });
//
//   factory Company.fromJson(Map<String, dynamic> json) {
//     return Company(
//       id: json['id'] is int ? json['id'] : 0,
//       name: json['name']?.toString() ?? '',
//       slug: json['slug']?.toString() ?? '',
//       companyCode: json['company_code']?.toString(),
//       contactPerson: json['contact_person']?.toString(),
//       contactNumber: json['contact_number']?.toString() ?? '',
//       contactEmail: json['contact_email']?.toString() ?? '',
//       contactAddress: json['contact_address']?.toString() ?? '',
//       companyTin: json['company_tin']?.toString() ?? '',
//       companyBin: json['company_bin']?.toString() ?? '',
//       businessType: json['business_type']?.toString(),
//     );
//   }
// }
//
// class User {
//   final int id;
//   final String name;
//   final String email;
//   final String phone;
//   final Company company;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.company,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] is int ? json['id'] : 0,
//       name: json['name']?.toString() ?? '',
//       email: json['email']?.toString() ?? '',
//       phone: json['phone']?.toString() ?? '',
//       company: json['company'] != null
//           ? Company.fromJson(json['company'] as Map<String, dynamic>)
//           : Company(
//         id: 0,
//         name: '',
//         slug: '',
//         contactNumber: '',
//         contactEmail: '',
//         contactAddress: '',
//         companyTin: '',
//         companyBin: '',
//       ),
//     );
//   }
//
//   factory User.placeholder(int id) {
//     return User(
//       id: id,
//       name: 'N/A',
//       email: '',
//       phone: '',
//       company: Company(
//         id: 0,
//         name: '',
//         slug: '',
//         contactNumber: '',
//         contactEmail: '',
//         contactAddress: '',
//         companyTin: '',
//         companyBin: '',
//       ),
//     );
//   }
// }
//
// class ProjectUser {
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
//   final UserCompany company;
//
//   ProjectUser({
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
//     required this.company,
//   });
//
//   factory ProjectUser.fromJson(Map<String, dynamic> json) {
//     print('Parsing ProjectUser JSON: $json');
//     return ProjectUser(
//       id: json['id'] ?? 0,
//       companyId: json['company_id'] ?? 0,
//       branchId: json['branch_id'],
//       name: json['name'] ?? 'Unknown',
//       email: json['email'] ?? 'N/A',
//       phone: json['phone'] ?? 'N/A',
//       photo: json['photo'],
//       status: json['status'] ?? 0,
//       emailVerifiedAt: json['email_verified_at'],
//       rememberToken: json['remember_token'],
//       createdAt: json['created_at'] ?? 'Not set',
//       updatedAt: json['updated_at'] ?? 'Not set',
//       company: json['company'] != null
//           ? UserCompany.fromJson(json['company'])
//           : UserCompany(
//         id: 0,
//         name: 'Unknown',
//         slug: '',
//         logo: null,
//         brandLogo: null,
//         companyCode: '',
//         orderPrefix: '',
//         businessType: null,
//         contactPerson: '',
//         contactNumber: '',
//         contactEmail: '',
//         contactAddress: '',
//         companyTin: '',
//         companyBin: '',
//         countryId: 0, createdAt: '', updatedAt: '',
//       ),
//     );
//   }
// }
//
// class UserCompany {
//   final int id;
//   final String name;
//   final String slug;
//   final String? logo;
//   final String? brandLogo;
//   final String companyCode;
//   final String orderPrefix;
//   final String? businessType;
//   final String contactPerson;
//   final String contactNumber;
//   final String contactEmail;
//   final String contactAddress;
//   final String companyTin;
//   final String companyBin;
//   final String createdAt;
//   final String updatedAt;
//   final int countryId;
//
//   UserCompany({
//     required this.id,
//     required this.name,
//     required this.slug,
//     this.logo,
//     this.brandLogo,
//     required this.companyCode,
//     required this.orderPrefix,
//     this.businessType,
//     required this.contactPerson,
//     required this.contactNumber,
//     required this.contactEmail,
//     required this.contactAddress,
//     required this.companyTin,
//     required this.companyBin,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.countryId,
//   });
//
//   factory UserCompany.fromJson(Map<String, dynamic> json) {
//     print('Parsing UserCompany JSON: $json');
//     return UserCompany(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? 'Unknown',
//       slug: json['slug'] ?? 'N/A',
//       logo: json['logo'],
//       brandLogo: json['brand_logo'],
//       companyCode: json['company_code'] ?? 'N/A',
//       orderPrefix: json['order_prefix'] ?? 'N/A',
//       businessType: json['business_type'],
//       contactPerson: json['contact_person'] ?? 'N/A',
//       contactNumber: json['contact_number'] ?? 'N/A',
//       contactEmail: json['contact_email'] ?? 'N/A',
//       contactAddress: json['contact_address'] ?? 'N/A',
//       companyTin: json['company_tin'] ?? 'N/A',
//       companyBin: json['company_bin'] ?? 'N/A',
//       createdAt: json['created_at'] ?? 'Not set',
//       updatedAt: json['updated_at'] ?? 'Not set',
//       countryId: json['country_id'] ?? 0,
//     );
//   }
// }