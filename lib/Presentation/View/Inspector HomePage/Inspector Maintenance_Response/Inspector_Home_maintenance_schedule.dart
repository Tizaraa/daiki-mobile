// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';
//
// import '../../../../Core/Token-Manager/token_manager_screen.dart';
// import '../../../../Core/Utils/api_service.dart';
// import '../../Authentication/login_screen.dart';
//
//
//
//
// // Model Classes
// class Project {
//   final int projectId;
//   final String projectName;
//   final String location;
//   final String pjCode;
//   final String projectType;
//   final String projectStatus;
//   final String assignments;
//   final String projectFacilities;
//   final String capacity;
//   final String frequency;
//   final String maintenanceStatus;
//
//   Project({
//     required this.projectId,
//     required this.projectName,
//     required this.location,
//     required this.pjCode,
//     required this.projectType,
//     required this.projectStatus,
//     required this.assignments,
//     required this.projectFacilities,
//     required this.capacity,
//     required this.frequency,
//     required this.maintenanceStatus,
//   });
//
//   factory Project.fromJson(Map<String, dynamic> json) {
//     return Project(
//       projectId: json['project_id'] ?? 0,
//       projectName: json['project_name']?.toString() ?? '',
//       location: json['location']?.toString() ?? '',
//       pjCode: json['pj_code']?.toString() ?? '',
//       projectType: json['project_type']?.toString() ?? '',
//       projectStatus: json['project_status']?.toString() ?? '',
//       assignments: json['assignments']?.toString() ?? '',
//       projectFacilities: json['project_facilities']?.toString() ?? '',
//       capacity: json['capacity']?.toString() ?? '',
//       frequency: json['frequency']?.toString() ?? '',
//       maintenanceStatus: json['maintenance_status']?.toString() ?? '',
//     );
//   }
// }
//
// class MaintenanceSchedule {
//   final int id;
//   final int projectId;
//   final String maintenanceDate;
//   final String frequency;
//   final String nextMaintenanceDate;
//   final Project project;
//
//   MaintenanceSchedule({
//     required this.id,
//     required this.projectId,
//     required this.maintenanceDate,
//     required this.frequency,
//     required this.nextMaintenanceDate,
//     required this.project,
//   });
//
//   factory MaintenanceSchedule.fromJson(Map<String, dynamic> json) {
//     return MaintenanceSchedule(
//       id: json['id'] ?? 0,
//       projectId: json['project_id'] ?? 0,
//       maintenanceDate: json['maintenance_date']?.toString() ?? '',
//       frequency: json['frequency']?.toString() ?? '',
//       nextMaintenanceDate: json['next_maintenance_date']?.toString() ?? '',
//       project: Project.fromJson(json['project'] ?? {}),
//     );
//   }
// }
//
// class JohkasouModel {
//   int? johkasou_model_id;
//   String? module;
//   TaskInfo? taskInfo;
//
//   JohkasouModel({this.johkasou_model_id, this.module, this.taskInfo});
//
//   JohkasouModel.fromJson(Map<String, dynamic> json) {
//     johkasou_model_id = json['id'];
//     module = json['module']?.toString();
//     taskInfo = json['task_info'] != null ? TaskInfo.fromJson(json['task_info']) : null;
//   }
// }
//
// class TaskInfo {
//   String? taskDescription;
//   String? remarks;
//
//   TaskInfo({this.taskDescription, this.remarks});
//
//   TaskInfo.fromJson(Map<String, dynamic> json) {
//     taskDescription = json['task_description']?.toString();
//     remarks = json['remarks']?.toString();
//   }
// }
//
// // API Service
// class ApiService {
//   Future<List<MaintenanceSchedule>> fetchMaintenanceSchedules() async {
//     try {
//       String? token = await TokenManager.getToken();
//
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication token is missing.');
//       }
//
//       final response = await http.get(
//         Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data['status'] == true && data['data']['maintenance_schedule'] != null) {
//           final maintenanceSchedulesJson = data['data']['maintenance_schedule']['data'] as List;
//           return maintenanceSchedulesJson.map((json) => MaintenanceSchedule.fromJson(json)).toList();
//         } else {
//           throw Exception('Maintenance schedules data not found.');
//         }
//       } else {
//         throw Exception('Failed to load maintenance schedules. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching maintenance schedules: $e');
//     }
//   }
// }
//
// // Inspector Maintenance Question Page
// class InspectorMaintenanceQuestionpage extends StatelessWidget {
//   final int maintenanceScheduleId;
//   final int projectId;
//   final String project_name;
//   final String next_maintenance_date;
//   final int? johkasou_model_id;
//
//   const InspectorMaintenanceQuestionpage({
//     Key? key,
//     required this.maintenanceScheduleId,
//     required this.projectId,
//     required this.project_name,
//     required this.next_maintenance_date,
//     this.johkasou_model_id, required int johkasouId,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Maintenance Questions'),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: RadialGradient(
//               colors: [Color(0xFFDAE6E8), Color(0xFFEEF4F3)],
//               center: Alignment.bottomCenter,
//               focal: Alignment.bottomRight,
//               radius: 2.0,
//             ),
//           ),
//         ),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 'Maintenance Questions for $project_name',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               if (johkasou_model_id != null)
//                 Text(
//                   'Module ID: $johkasou_model_id',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               const SizedBox(height: 8),
//               Text(
//                 'Project ID: $projectId',
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Next Maintenance: $next_maintenance_date',
//                 style: const TextStyle(fontSize: 16),
//               ),
//               // Add more question-related UI here as needed
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Main UI Screen
// // class Inspector_Home_MaintenanceScheduleScreen extends StatefulWidget {
// //   const Inspector_Home_MaintenanceScheduleScreen({super.key});
// //
// //   @override
// //   _Inspector_Home_MaintenanceScheduleScreenState createState() => _Inspector_Home_MaintenanceScheduleScreenState();
// // }
// //
// // class _Inspector_Home_MaintenanceScheduleScreenState extends State<Inspector_Home_MaintenanceScheduleScreen> {
// //   final ApiService _apiService = ApiService();
// //   List<MaintenanceSchedule> maintenanceSchedules = [];
// //   List<MaintenanceSchedule> filteredSchedules = [];
// //   bool isLoading = true;
// //   String? error;
// //   final TextEditingController _searchController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadMaintenanceSchedules();
// //     _checkSessionValidity();
// //     _searchController.addListener(_filterSchedules);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _filterSchedules() {
// //     final query = _searchController.text.toLowerCase();
// //     setState(() {
// //       filteredSchedules = maintenanceSchedules.where((schedule) {
// //         final projectName = schedule.project.projectName.toLowerCase();
// //         final pjCode = schedule.project.pjCode.toLowerCase();
// //         return projectName.contains(query) || pjCode.contains(query);
// //       }).toList();
// //     });
// //   }
// //
// //   Future<void> _checkSessionValidity() async {
// //     final tokenExpired = await TokenManager.isTokenExpired();
// //     if (tokenExpired) {
// //       await TokenManager.clearToken();
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => const LoginPage()),
// //       );
// //     }
// //   }
// //
// //   Future<void> _loadMaintenanceSchedules() async {
// //     try {
// //       setState(() {
// //         isLoading = true;
// //         error = null;
// //       });
// //
// //       final schedules = await _apiService.fetchMaintenanceSchedules();
// //       setState(() {
// //         maintenanceSchedules = schedules;
// //         filteredSchedules = schedules;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         error = e.toString();
// //         isLoading = false;
// //       });
// //     }
// //   }
// //
// //   void _navigateToQuizScreen({
// //     required int maintenanceScheduleId,
// //     required int projectId,
// //     required String projectName,
// //     required String nextMaintenanceDate,
// //     int? moduleId,
// //   }) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => InspectorMaintenanceQuestionpage(
// //           maintenanceScheduleId: maintenanceScheduleId,
// //           projectId: projectId,
// //           project_name: projectName,
// //           next_maintenance_date: nextMaintenanceDate,
// //           johkasou_model_id: moduleId,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Create Maintenance"),
// //         centerTitle: true,
// //         flexibleSpace: Container(
// //           decoration: const BoxDecoration(
// //             gradient: RadialGradient(
// //               colors: [Color(0xFFDAE6E8), Color(0xFFEEF4F3)],
// //               center: Alignment.bottomCenter,
// //               focal: Alignment.bottomRight,
// //               radius: 2.0,
// //             ),
// //           ),
// //         ),
// //       ),
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFFFFFFFF),
// //               Color(0xFFFFFFFF),
// //             ],
// //           ),
// //         ),
// //         child: Column(
// //           children: [
// //             Padding(
// //               padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10),
// //               child: TextField(
// //                 controller: _searchController,
// //                 decoration: InputDecoration(
// //                   hintText: 'Search by Project Name or Code',
// //                   prefixIcon: const Icon(Icons.search),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.grey),
// //                   ),
// //                   filled: true,
// //                   fillColor: Colors.white,
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: isLoading
// //                   ? Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     CircularProgressIndicator(
// //                       valueColor: AlwaysStoppedAnimation<Color>(TizaraaColors.primaryColor),
// //                     ),
// //                     const SizedBox(height: 16),
// //                     const Text(
// //                       'Loading schedules...',
// //                       style: TextStyle(
// //                         color: Colors.black54,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               )
// //                   : error != null
// //                   ? Center(
// //                 child: Container(
// //                   padding: const EdgeInsets.all(24),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.error_outline,
// //                         size: 64,
// //                         color: Colors.red[300],
// //                       ),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         'Something went wrong',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black87,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         error!,
// //                         textAlign: TextAlign.center,
// //                         style: const TextStyle(
// //                           color: Colors.black54,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 24),
// //                       ElevatedButton.icon(
// //                         onPressed: _loadMaintenanceSchedules,
// //                         icon: const Icon(Icons.refresh),
// //                         label: const Text('Try Again'),
// //                         style: ElevatedButton.styleFrom(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 24,
// //                             vertical: 12,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )
// //                   : ListView.builder(
// //                 padding: const EdgeInsets.symmetric(vertical: 16),
// //                 itemCount: filteredSchedules.length,
// //                 itemBuilder: (context, index) {
// //                   final schedule = filteredSchedules[index];
// //                   return Container(
// //                     margin: const EdgeInsets.symmetric(
// //                       horizontal: 5,
// //                       vertical: 3,
// //                     ),
// //                     child: Card(
// //                       elevation: 2,
// //                       color: TizaraaColors.Tizara,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       child: Container(
// //                         padding: const EdgeInsets.all(10),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Row(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 const Icon(Icons.warehouse, color: Colors.white),
// //                                 const SizedBox(width: 16),
// //                                 Expanded(
// //                                   child: Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       Text(
// //                                         schedule.project.projectName,
// //                                         style: const TextStyle(
// //                                           fontSize: 18,
// //                                           fontWeight: FontWeight.bold,
// //                                           color: Colors.white,
// //                                         ),
// //                                       ),
// //                                       Row(
// //                                         children: [
// //                                           const Icon(
// //                                             Icons.location_on_outlined,
// //                                             size: 16,
// //                                             color: Colors.white60,
// //                                           ),
// //                                           const SizedBox(width: 4),
// //                                           Expanded(
// //                                             child: Text(
// //                                               schedule.project.location,
// //                                               style: const TextStyle(
// //                                                 color: Colors.white,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 10),
// //                             Container(
// //                               padding: const EdgeInsets.all(8),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.grey[50],
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                               child: Column(
// //                                 children: [
// //                                   Row(
// //                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                                     children: [
// //                                       _buildInfoRow(
// //                                         'Maintenance Date and Time',
// //                                         schedule.maintenanceDate,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Project\nFrequency',
// //                                         schedule.frequency,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Next Maintenance Date and Time',
// //                                         schedule.nextMaintenanceDate,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   const SizedBox(height: 12),
// //                                   const Divider(),
// //                                   const SizedBox(height: 12),
// //                                   Row(
// //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       _buildInfoRow(
// //                                         'Project Code',
// //                                         schedule.project.pjCode,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Project Type',
// //                                         schedule.project.projectType,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Contract Status',
// //                                         schedule.project.projectStatus,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   const SizedBox(height: 12),
// //                                   Row(
// //                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                                     children: [
// //                                       _buildInfoRow(
// //                                         'Assigned Inspector',
// //                                         schedule.project.assignments,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Project Facility',
// //                                         schedule.project.projectFacilities,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Project Capacity',
// //                                         schedule.project.capacity,
// //                                       ),
// //                                       _buildInfoRow(
// //                                         'Maintenance Status',
// //                                         schedule.project.maintenanceStatus,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             const SizedBox(height: 10),
// //                             SizedBox(
// //                               width: double.infinity,
// //                               child: ElevatedButton.icon(
// //                                 onPressed: () {
// //                                   _navigateToQuizScreen(
// //                                     maintenanceScheduleId: schedule.id,
// //                                     projectId: schedule.projectId,
// //                                     projectName: schedule.project.projectName,
// //                                     nextMaintenanceDate: schedule.nextMaintenanceDate,
// //                                   );
// //                                 },
// //                                 icon: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF0074BA)),
// //                                 label: const Text('Perform Task', style: TextStyle(color: Colors.black)),
// //                                 style: ElevatedButton.styleFrom(
// //                                   padding: const EdgeInsets.symmetric(vertical: 12),
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(12),
// //                                   ),
// //                                   backgroundColor: Colors.white,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(String label, String value) {
// //     return Expanded(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: [
// //           Text(
// //             label,
// //             style: const TextStyle(
// //               color: Colors.black54,
// //               fontSize: 12,
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 2),
// //           Text(
// //             value.isEmpty ? '-' : value,
// //             style: const TextStyle(
// //               color: Colors.black87,
// //               fontWeight: FontWeight.w500,
// //             ),
// //             textAlign: TextAlign.center,
// //             overflow: TextOverflow.clip,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }