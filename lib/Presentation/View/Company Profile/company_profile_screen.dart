import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Utils/api_service.dart';
import '../../../Core/Utils/colors.dart';
import '../../../Model/company_profile_model.dart';

class CompanyProfileScreen extends StatefulWidget {
  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  late Future<Company> futureCompany;

  @override
  void initState() {
    super.initState();
    futureCompany = fetchCompanyProfile();
  }

  Future<Company> fetchCompanyProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final email = prefs.getString('user_email');
      final password = prefs.getString('user_password');

      if (email == null || password == null) {
        throw Exception('No login credentials found');
      }

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if company data exists
        if (data['company'] == null) {
          throw Exception('No company data found in response');
        }

        final company = Company.fromJson(data['company']);
        return company;
      } else {
        throw Exception('Failed to load company profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching company profile: $e');
      throw Exception('Failed to load company profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Company>(
        future: futureCompany,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          } else if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final company = snapshot.data!;
            return _buildCompanyProfileView(company);
          } else {
            return _buildNoDataScreen();
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade200,
            Colors.blue.shade800,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade200,
            Colors.red.shade800,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Error: $error',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    futureCompany = fetchCompanyProfile();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade800,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade800,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No Company Data Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  futureCompany = fetchCompanyProfile();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade800,
              ),
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyProfileView(Company company) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F8FF), // #F0F8FF
            Color(0xFFEFFEFD), // #EFFEFD
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                SizedBox(height: 20),

                // Company Logo
                _buildCompanyLogo(company.logo),

                // Company Name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    company.name ?? "Company Name",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TizaraaColors.Tizara,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Company Information Card
                Card(
                  color: TizaraaColors.primaryColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.person,
                          label: "Contact Person",
                          value: _getSafeString(company.contactPerson),
                        ),
                        Divider(color: Colors.grey.shade300),
                        _buildInfoTile(
                          icon: Icons.phone,
                          label: "Contact Number",
                          value: _getSafeString(company.contactNumber),
                        ),
                        Divider(color: Colors.grey.shade300),
                        _buildInfoTile(
                          icon: Icons.email,
                          label: "Contact Email",
                          value: _getSafeString(company.contactEmail),
                        ),
                        Divider(color: Colors.grey.shade300),
                        _buildInfoTile(
                          icon: Icons.location_on,
                          label: "Address",
                          value: _getSafeString(company.contactAddress),
                        ),
                        Divider(color: Colors.grey.shade300),
                        _buildInfoTile(
                          icon: Icons.business,
                          label: "Business Type",
                          value: _getSafeString(company.businessType),
                        ),
                        // Uncomment these if you need them
                        // Divider(color: Colors.grey.shade300),
                        // _buildInfoTile(
                        //   icon: Icons.code,
                        //   label: "Company Code",
                        //   value: _getSafeString(company.companyCode),
                        // ),
                        // Divider(color: Colors.grey.shade300),
                        // _buildInfoTile(
                        //   icon: Icons.numbers,
                        //   label: "Company TIN",
                        //   value: _getSafeString(company.companyTin),
                        // ),
                        // Divider(color: Colors.grey.shade300),
                        // _buildInfoTile(
                        //   icon: Icons.numbers,
                        //   label: "Company BIN",
                        //   value: _getSafeString(company.companyBin),
                        // ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(String? logoUrl) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                color: TizaraaColors.Tizara,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.business,
              size: 80,
              color: Colors.grey.shade600,
            ),
          ),
        )
            : Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.business,
            size: 80,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade700,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper function to safely handle null strings
  String _getSafeString(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return "Not Available";
    }
    return value.trim();
  }
}