class Company {
  final String? name;
  final String? logo;
  final String? contactPerson;
  final String? contactNumber;
  final String? contactEmail;
  final String? contactAddress;
  final String? businessType;
  final String? companyCode;
  final String? companyTin;
  final String? companyBin;

  Company({
    this.name,
    this.logo,
    this.contactPerson,
    this.contactNumber,
    this.contactEmail,
    this.contactAddress,
    this.businessType,
    this.companyCode,
    this.companyTin,
    this.companyBin,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      logo: json['logo'],
      contactPerson: json['contact_person'],
      contactNumber: json['contact_number'],
      contactEmail: json['contact_email'],
      contactAddress: json['contact_address'],
      businessType: json['business_type'],
      companyCode: json['company_code'],
      companyTin: json['company_tin'],
      companyBin: json['company_bin'],
    );
  }
}