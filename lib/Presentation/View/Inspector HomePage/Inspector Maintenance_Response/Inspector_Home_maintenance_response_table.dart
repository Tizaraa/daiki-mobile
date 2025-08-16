import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import 'Inspector_maintenance_details_screen.dart';



// MaintenanceResponse class remains the same
class MaintenanceResponse {
  final String id;
  final String userName;
  final String projectName;
  final String scheduleDate;
  final String maintenanceFrequency;
  final String createdAt;
  final String pj_code;
  final String projectStatus;
  final String maintenanceStatus;
  final String updatedAt;

  MaintenanceResponse({
    required this.id,
    required this.userName,
    required this.projectName,
    required this.scheduleDate,
    required this.maintenanceFrequency,
    required this.createdAt,
    required this.pj_code,
    required this.projectStatus,
    required this.maintenanceStatus,
    required this.updatedAt,
  });

  factory MaintenanceResponse.fromJson(Map<String, dynamic> json) {
    return MaintenanceResponse(
      id: json['id']?.toString() ?? 'N/A',
      userName: json['user']?['name'] ?? 'N/A',
      projectName: json['project']?['project_name'] ?? 'N/A',
      scheduleDate: json['maintenance_schedule']?['maintenance_date'] ?? 'N/A',
      maintenanceFrequency: json['maintenance_schedule']?['frequency'] ?? 'N/A',
      createdAt: json['created_at'] ?? 'N/A',
      pj_code: json['project']?['pj_code'] ?? 'N/A',
      projectStatus: json['project']?['project_status'] ?? 'N/A',
      maintenanceStatus: json['project']?['maintenance_status'] ?? 'N/A',
      updatedAt: json['updated_at'] ?? 'N/A',
    );
  }
}

class Inspector_Home_MaintenanceScreenOutput extends StatefulWidget {
  const Inspector_Home_MaintenanceScreenOutput({super.key});

  @override
  _Inspector_Home_MaintenanceScreenOutputState createState() => _Inspector_Home_MaintenanceScreenOutputState();
}

class _Inspector_Home_MaintenanceScreenOutputState extends State<Inspector_Home_MaintenanceScreenOutput> {
  late Future<List<MaintenanceResponse>> _maintenanceData;

  @override
  void initState() {
    super.initState();
    _maintenanceData = fetchMaintenanceData();
  }

  Future<List<MaintenanceResponse>> fetchMaintenanceData() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || await TokenManager.isTokenExpired()) {
        throw Exception('Token is missing or expired');
      }

      final response = await http.get(
        Uri.parse('https://minio.johkasou-erp.com/api/v1/maintenance/responses'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data']['data'] != null) {
          final List<dynamic> data = jsonResponse['data']['data'];
          return data.map((json) => MaintenanceResponse.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load maintenance data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance Reports'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF52E2F6), Color(0xFFBFFAF4)],
              center: Alignment.bottomCenter,
              focal: Alignment.bottomRight,
              radius: 2.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _maintenanceData = fetchMaintenanceData();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MaintenanceResponse>>(
        future: _maintenanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _maintenanceData = fetchMaintenanceData();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No maintenance reports available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final report = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(report.projectName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${report.userName}'),
                      Text('Date: ${report.scheduleDate}'),
                      Text('Status: ${report.maintenanceStatus}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Inspector_MaintenanceDetailScreen(id: report.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


