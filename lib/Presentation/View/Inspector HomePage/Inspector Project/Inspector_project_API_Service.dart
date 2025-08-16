import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Model/Inspector_Project_Model.dart';

class InspectorProjectsApiService {
  static const String baseUrl = '${DaikiAPI.api_key}/api/v1';

  Future<List<Project>> getProjects() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/project'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('API Response: $responseData');
        if (responseData['status'] == true) {
          List projectsData = responseData['data']?['projects']?['data'] ?? [];
          if (projectsData.isEmpty) {
            print('No projects found in response');
            return [];
          }
          return projectsData.map((projectJson) {
            if (projectJson is! Map<String, dynamic>) {
              print('Invalid project data: $projectJson');
              return Project(
                projectId: 0,
                pjCode: '-',
                projectName: 'Invalid Project',
                location: 'Unknown',
                projectLocationId: null,
                capacity: '',
                projectStatus: null,
                maintenanceStatus: null,
                contractedDate: null,
                expireDate: null,
                client: Client.placeholder(0),
                pic: null,
                remarks: null,
                projectType: null,
                projectFacilities: null,
                users: [],
                branchId: 0,
                companyId: 0,
                modules: null,
                projectLocation: null,
                branch: null,
                bdmName: null,
                totalServiceCount: null,
                totalServicedCount: null,
                lastServiceMonth: null,
                servicedMaintenanceScheduleCount: null,
                nonServicedMaintenanceScheduleCount: null,
                totalMaintenanceScheduleCount: null,
                yearlyServicedMaintenanceScheduleCount: null,
                yearlyNonServicedMaintenanceScheduleCount: null,
                monthlyServicedMaintenanceScheduleCount: null,
                monthlyNonServicedMaintenanceScheduleCount: null,
                monthlyMaintenanceSummary: null,
                maintenanceScheduleByProject: null,
                clientRelation: null,
                usersForClients: null,
                representative: null,
                maintenanceSchedules: null,
                projectPump: null,
                johkasouModel: null,
              );
            }
            return Project.fromJson(projectJson);
          }).toList();
        } else {
          throw Exception('API returned status false');
        }
      }
      throw Exception('Failed to load projects: Status ${response.statusCode}');
    } catch (e, stackTrace) {
      print('Error in getProjects: $e');
      print('Stack Trace: $stackTrace');
      throw Exception('Error: $e');
    }
  }

  Future<Project> getProjectDetail(int projectId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/project/$projectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Project Detail Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Decoded Project Response: $responseData');
        if (responseData['status'] == true) {
          var projectData = responseData['data']['project'];
          if (projectData == null) {
            throw Exception('Project data not found in response');
          }
// Log project_type and project_facilities specifically
          print('project_type: ${projectData['project_type']}');
          print('project_facilities: ${projectData['project_facilities']}');

          return Project.fromJson(projectData);
        } else {
          throw Exception(
              'API returned status false: ${responseData['message']}');
        }
      }
      throw Exception(
          'Failed to load project details: Status ${response.statusCode}');
    } catch (e) {
      print('Error in getProjectDetail: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Client> getClientDetail(int clientId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/client/$clientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return Client.fromJson(responseData['data']['client']);
        } else {
          throw Exception('API returned status false');
        }
      }
      throw Exception(
          'Failed to load client details: Status ${response.statusCode}');
    } catch (e) {
      print('Error in getClientDetail: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<ProjectUser>> getProjectUsers(int projectId) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$baseUrl/project/$projectId/users');
      print('Requesting URL: $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Users API Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          if (responseData['data'] != null &&
              responseData['data']['users'] != null) {
            List usersData = responseData['data']['users'] ?? [];
            print('Parsed Users Data: $usersData');
            return usersData
                .map((userData) => ProjectUser.fromJson(userData))
                .toList();
          } else {
            print('No users data found in response');
            return [];
          }
        } else {
          print('API returned status false: ${responseData['message']}');
          return [];
        }
      }
      print('Failed to load project users: Status ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error in getProjectUsers: $e');
      return [];
    }
  }
}
