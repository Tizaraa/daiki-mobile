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
  final Company company;

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
    required this.company,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      companyId: json['company_id'],
      name: json['name'],
      code: json['code'],
      johkasouModel: json['johkasou_model'],
      orderPrefix: json['order_prefix'],
      person: json['person'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      type: json['type'],
      logo: json['logo'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      company: Company.fromJson(json['company']),
    );
  }

  // Convenience getters for accessing company data
  String get companyName => company.name;
  String? get contactNumber => phone ?? company.contactNumber;
  String? get contactEmail => email ?? company.contactEmail;
  String? get contactAddress => address ?? company.contactAddress;
}

class Company {
  final int id;
  final String name;
  final String slug;
  final String? logo;
  final String? brandLogo;
  final String? companyCode;
  final String? orderPrefix;
  final String? businessType;
  final String? contactPerson;
  final String? contactNumber;
  final String? contactEmail;
  final String? contactAddress;
  final String? companyTin;
  final String? companyBin;
  final String createdAt;
  final String updatedAt;
  final int countryId;

  Company({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.brandLogo,
    this.companyCode,
    this.orderPrefix,
    this.businessType,
    this.contactPerson,
    this.contactNumber,
    this.contactEmail,
    this.contactAddress,
    this.companyTin,
    this.companyBin,
    required this.createdAt,
    required this.updatedAt,
    required this.countryId,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      logo: json['logo'],
      brandLogo: json['brand_logo'],
      companyCode: json['company_code'],
      orderPrefix: json['order_prefix'],
      businessType: json['business_type'],
      contactPerson: json['contact_person'],
      contactNumber: json['contact_number'],
      contactEmail: json['contact_email'],
      contactAddress: json['contact_address'],
      companyTin: json['company_tin'],
      companyBin: json['company_bin'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      countryId: json['country_id'],
    );
  }
}