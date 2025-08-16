// import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_PT_view_album.dart';
// import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Maintenance_Response/Inspector_Home_maintenance_schedule.dart' hide MaintenanceSchedule;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:redis/redis.dart';
// import '../../../Core/Token-Manager/token_manager_screen.dart';
// import '../../../Core/Utils/api_service.dart';
// import '../../../Core/Utils/colors.dart';
// import '../../../Model/inspector_pending_task_model.dart';
// import '../Authentication/login_screen.dart';
// import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_questions.dart';
// import 'Inspector_Image_after_before_screen.dart' hide Category;
//
// class ApiService {
//   // Updated method to fetch all maintenance schedules with pagination
//   Future<List<MaintenanceSchedule>> fetchMaintenanceSchedules() async {
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication token is missing.');
//       }
//
//       List<MaintenanceSchedule> allSchedules = [];
//       int currentPage = 1;
//       bool hasMorePages = true;
//
//       while (hasMorePages) {
//         final response = await http.get(
//           Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules-pending-task?page=$currentPage'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//
//         print('API Response Status (Page $currentPage): ${response.statusCode}');
//         print('API Response Body (Page $currentPage): ${response.body}');
//
//         if (response.statusCode == 200) {
//           final Map<String, dynamic> data = json.decode(response.body);
//           if (data['status'] == true) {
//             if (data['data'] != null && data['data']['maintenance_schedule'] != null) {
//               final paginationData = data['data']['maintenance_schedule'];
//               final maintenanceSchedulesJson = paginationData['data'] as List?;
//
//               if (maintenanceSchedulesJson != null && maintenanceSchedulesJson.isNotEmpty) {
//                 final schedules = maintenanceSchedulesJson
//                     .map((json) => MaintenanceSchedule.fromJson(json))
//                     .toList();
//                 allSchedules.addAll(schedules);
//
//                 // Check pagination info
//                 final currentPageFromAPI = paginationData['current_page'] ?? currentPage;
//                 final lastPage = paginationData['last_page'] ?? currentPage;
//                 final hasNextPage = currentPageFromAPI < lastPage;
//
//                 print('Page $currentPage: Found ${schedules.length} schedules');
//                 print('Current page: $currentPageFromAPI, Last page: $lastPage');
//
//                 if (hasNextPage) {
//                   currentPage++;
//                 } else {
//                   hasMorePages = false;
//                 }
//               } else {
//                 // No more data on this page
//                 hasMorePages = false;
//               }
//             } else {
//               throw Exception('Maintenance schedules data structure is invalid on page $currentPage');
//             }
//           } else {
//             throw Exception('API returned false status on page $currentPage: ${data['message']}');
//           }
//         } else {
//           throw Exception('Failed to load maintenance schedules on page $currentPage. Status code: ${response.statusCode}');
//         }
//       }
//
//       print('Total schedules fetched: ${allSchedules.length}');
//       return allSchedules;
//
//     } catch (e) {
//       print('Error in fetchMaintenanceSchedules: $e');
//       throw Exception('Error fetching maintenance schedules: $e');
//     }
//   }
//
//   // Alternative method with better error handling and progress tracking
//   Future<List<MaintenanceSchedule>> fetchAllMaintenanceSchedulesWithProgress({
//     Function(int currentPage, int totalFetched)? onProgress,
//   }) async {
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication token is missing.');
//       }
//
//       List<MaintenanceSchedule> allSchedules = [];
//       int currentPage = 1;
//       int totalFetched = 0;
//
//       while (true) {
//         try {
//           final response = await http.get(
//             Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules-pending-task?page=$currentPage'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           ).timeout(Duration(seconds: 30)); // Add timeout
//
//           if (response.statusCode == 200) {
//             final Map<String, dynamic> data = json.decode(response.body);
//
//             if (data['status'] == true &&
//                 data['data'] != null &&
//                 data['data']['maintenance_schedule'] != null) {
//
//               final paginationData = data['data']['maintenance_schedule'];
//               final maintenanceSchedulesJson = paginationData['data'] as List?;
//
//               if (maintenanceSchedulesJson == null || maintenanceSchedulesJson.isEmpty) {
//                 // No more data available
//                 break;
//               }
//
//               final schedules = maintenanceSchedulesJson
//                   .map((json) => MaintenanceSchedule.fromJson(json))
//                   .toList();
//
//               allSchedules.addAll(schedules);
//               totalFetched += schedules.length;
//
//               // Call progress callback if provided
//               if (onProgress != null) {
//                 onProgress(currentPage, totalFetched);
//               }
//
//               // Check if there are more pages
//               final lastPage = paginationData['last_page'];
//               if (currentPage >= lastPage) {
//                 break;
//               }
//
//               currentPage++;
//
//               // Small delay to prevent overwhelming the server
//               await Future.delayed(Duration(milliseconds: 100));
//
//             } else {
//               print('Invalid data structure on page $currentPage');
//               break;
//             }
//           } else {
//             print('HTTP Error on page $currentPage: ${response.statusCode}');
//             break;
//           }
//         } catch (pageError) {
//           print('Error fetching page $currentPage: $pageError');
//           // Continue to next page or break based on error type
//           if (pageError.toString().contains('timeout')) {
//             // Retry current page once on timeout
//             await Future.delayed(Duration(seconds: 2));
//             continue;
//           } else {
//             break;
//           }
//         }
//       }
//
//       print('Successfully fetched $totalFetched maintenance schedules from $currentPage pages');
//       return allSchedules;
//
//     } catch (e) {
//       print('Error in fetchAllMaintenanceSchedulesWithProgress: $e');
//       throw Exception('Error fetching maintenance schedules: $e');
//     }
//   }
//
//   Future<List<Category>> fetchCategoriesWithQuestions(int johkasouModelId) async {
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication token is missing.');
//       }
//
//       final response = await http.get(
//         Uri.parse('${DaikiAPI.api_key}/api/v1/get-category-with-questions?johkasou_model_id=$johkasouModelId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       print('Categories API Response Status: ${response.statusCode}');
//       print('Categories API Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data['status'] == true) {
//           final categoriesJson = data['date'] as List?;
//           if (categoriesJson != null) {
//             return categoriesJson.map((json) => Category.fromJson(json)).toList();
//           } else {
//             throw Exception('Categories data is null');
//           }
//         } else {
//           throw Exception('API returned false status: ${data['message']}');
//         }
//       } else {
//         throw Exception('Failed to load categories. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in fetchCategoriesWithQuestions: $e');
//       throw Exception('Error fetching categories: $e');
//     }
//   }
// }
//
// class Inspector_PendingTaskScreen extends StatefulWidget {
//   final String title;
//   const Inspector_PendingTaskScreen({super.key, required this.title});
//
//   @override
//   _Inspector_PendingTaskScreenState createState() => _Inspector_PendingTaskScreenState();
// }
//
// class _Inspector_PendingTaskScreenState extends State<Inspector_PendingTaskScreen> {
//   final ApiService _apiService = ApiService();
//   final TextEditingController _searchController = TextEditingController();
//   List<MaintenanceSchedule> _maintenanceSchedules = [];
//   List<MaintenanceSchedule> _filteredSchedules = [];
//   List<bool> _isExpanded = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     try {
//       await _checkSessionValidity();
//       await _loadMaintenanceSchedules();
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       print('Error in _loadData: $e');
//     }
//   }
//
//   Future<void> _checkSessionValidity() async {
//     try {
//       final tokenExpired = await TokenManager.isTokenExpired();
//       if (tokenExpired) {
//         await TokenManager.clearToken();
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginPage()),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error in _checkSessionValidity: $e');
//     }
//   }
//
//   int _currentPage = 0;
//   int _totalFetched = 0;
//   bool _showProgress = false;
//
//   Future<void> _loadMaintenanceSchedules() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//       _showProgress = true;
//       _currentPage = 0;
//       _totalFetched = 0;
//     });
//
//     try {
//       final schedules = await _apiService.fetchAllMaintenanceSchedulesWithProgress(
//         onProgress: (currentPage, totalFetched) {
//           setState(() {
//             _currentPage = currentPage;
//             _totalFetched = totalFetched;
//           });
//         },
//       );
//
//       setState(() {
//         _maintenanceSchedules = schedules;
//         _filteredSchedules = schedules;
//         _isExpanded = List.generate(schedules.length, (_) => false);
//         _isLoading = false;
//         _showProgress = false;
//       });
//
//       print('Successfully loaded ${schedules.length} maintenance schedules');
//
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load data: $e';
//         _isLoading = false;
//         _showProgress = false;
//       });
//       print('Error in _loadMaintenanceSchedules: $e');
//     }
//   }
//   // Add the task completion checking method
//   Future<bool> _isTaskCompleted(int maintenanceScheduleId, int johkasouId) async {
//     final prefs = await SharedPreferences.getInstance();
//     bool isCompleted = prefs.getBool('completed_${maintenanceScheduleId}_$johkasouId') ?? false;
//
//     try {
//       final redisConnection = RedisConnection();
//       final redisCommand = await redisConnection.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
//       await redisCommand.send_object(['AUTH', 'password']).timeout(Duration(seconds: 2));
//       var redisData = await redisCommand.send_object(['GET', 'completed_${maintenanceScheduleId}_$johkasouId']).timeout(Duration(seconds: 2));
//       await redisCommand.send_object(['QUIT']);
//       await redisConnection.close();
//
//       if (redisData != null && redisData == 'true') {
//         isCompleted = true;
//         await prefs.setBool('completed_${maintenanceScheduleId}_$johkasouId', true);
//       }
//     } catch (e) {
//       print('Redis error checking completion for johkasouId $johkasouId: $e');
//     }
//
//     return isCompleted;
//   }
//
//   void _filterSchedules(String query) {
//     setState(() {
//       _filteredSchedules = _maintenanceSchedules.where((schedule) {
//         final projectName = schedule.project.projectName.toLowerCase();
//         final pjCode = schedule.project.pjCode.toLowerCase();
//         final maintenanceDate = schedule.maintenanceDate.toLowerCase();
//         final groupName = schedule.group.name.toLowerCase();
//         final moduleNames = schedule.johkasouModels.map((m) => m.module.toLowerCase()).join(' ');
//         return projectName.contains(query.toLowerCase()) ||
//             pjCode.contains(query.toLowerCase()) ||
//             maintenanceDate.contains(query.toLowerCase()) ||
//             groupName.contains(query.toLowerCase()) ||
//             moduleNames.contains(query.toLowerCase());
//       }).toList();
//       _isExpanded = List.generate(_filteredSchedules.length, (_) => false);
//     });
//   }
//
//   Widget _buildLoadingIndicator() {
//     return const Center(
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _errorMessage,
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadData,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoDataWidget() {
//     return const Center(
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Text(
//           'No maintenance schedules found',
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
//
//   // Modified to build a list of modules with individual action buttons
//   Widget _buildJohkasouModulesList(MaintenanceSchedule schedule) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(top: 6.0, bottom: 2.0),
//           child: Text(
//             'Johkasou Modules:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//               fontSize: 12,
//             ),
//           ),
//         ),
//         ...schedule.johkasouModels.map((model) {
//           return Container(
//             margin: const EdgeInsets.symmetric(vertical: 3.0),
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(6.0),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildCompactInfoRow('Module', model.module, Icons.hardware),
//                 if (model.serialNumber != null)
//                   _buildCompactInfoRow('Serial', model.serialNumber!, Icons.confirmation_number),
//                 const SizedBox(height: 8),
//                 // Combined buttons row
//                 Row(
//                   children: [
//                     // Album View Button
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorPtViewAlbum(
//                             johkasouModelID: model.id,
//                             ScheduleID: schedule.id,
//                             title: 'Categories for ${model.module}',
//                           )));
//                           print('Album view pressed for module ${model.id}');
//                         },
//                         icon: const Icon(Icons.photo_library, size: 16),
//                         label: const Text('View Album', style: TextStyle(fontSize: 11)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0074BA),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 3),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     // View Categories Button
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CategoryQuestionsScreen(
//                                 johkasouModelId: model.id,
//                                 title: 'Categories for ${model.module}',
//                                 projectId: schedule.project.projectId,
//                                 scheduleId: schedule.id,
//                               ),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.cloud_upload_rounded, size: 16),
//                         label: const Text('Upload Image', style: TextStyle(fontSize: 11)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0074BA),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 3),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     // Perform Task Button with completion status - ALWAYS CLICKABLE
//                     Expanded(
//                       child: FutureBuilder<bool>(
//                         future: _isTaskCompleted(schedule.id, model.id),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return Container(
//                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade200,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: const Center(
//                                 child: SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(strokeWidth: 2),
//                                 ),
//                               ),
//                             );
//                           }
//
//                           final isCompleted = snapshot.data ?? false;
//
//                           return TextButton(
//                             // ALWAYS CLICKABLE - removed the null condition
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => InspectorMaintenanceQuestionpage(
//                                     maintenanceScheduleId: schedule.id,
//                                     johkasouId: model.id,
//                                     project_name: schedule.project.projectName,
//                                     next_maintenance_date: schedule.nextMaintenanceDate ?? '',
//                                     projectId: schedule.project.projectId,
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               backgroundColor: isCompleted ? Colors.grey.shade300 : const Color(0xFF0074BA),
//                               foregroundColor: isCompleted ? Colors.grey.shade600 : Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   isCompleted ? "Completed" : "Perform Task",
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: isCompleted ? Colors.grey.shade600 : Colors.white,
//                                   ),
//                                 ),
//                                 if (isCompleted)
//                                   Text(
//                                     '✓',
//                                     style: TextStyle(
//                                       color: Colors.teal,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   // New compact info row method for mobile
//   Widget _buildCompactInfoRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: Colors.grey),
//           const SizedBox(width: 6),
//           Text(
//             '$label: ',
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//               color: Colors.grey,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.black87,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainContent() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               labelText: 'Search by Name, Code, Date',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             ),
//             onChanged: _filterSchedules,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0x0476BD).withOpacity(0.9),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//             ),
//             height: 35,
//             width: double.infinity,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 3),
//                   child: Padding(
//                     padding: EdgeInsets.all(6.0),
//                     child: Text(
//                       "SL",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 2,
//                   color: Colors.white,
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 9),
//                   child: Padding(
//                     padding: EdgeInsets.all(6.0),
//                     child: Text(
//                       "Project Name",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           child: _filteredSchedules.isEmpty
//               ? _buildNoDataWidget()
//               : ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             itemCount: _filteredSchedules.length,
//             itemBuilder: (context, index) {
//               final schedule = _filteredSchedules[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 2),
//                 child: ExpansionTile(
//                   backgroundColor: TizaraaColors.primaryColor,
//                   collapsedBackgroundColor: TizaraaColors.primaryColor2,
//                   leading: Text(
//                     (index + 1).toString().padLeft(2, '0'),
//                     style: const TextStyle(
//                       color: TizaraaColors.Tizara,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   initiallyExpanded: _isExpanded[index],
//                   onExpansionChanged: (expanded) {
//                     setState(() {
//                       _isExpanded[index] = expanded;
//                     });
//                   },
//                   title: Text(
//                     schedule.project.projectName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: TizaraaColors.Tizara,
//                       fontSize: 14,
//                     ),
//                   ),
//                   subtitle: Text(
//                     schedule.maintenanceDate,
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                   trailing: Icon(
//                     _isExpanded[index] ? Icons.visibility_off : Icons.visibility,
//                     color: const Color(0xFF0074BA),
//                     size: 20,
//                   ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(4),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: TizaraaColors.primaryColor2,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildCompactInfoRow('Location', schedule.project.location, Icons.location_on),
//                                 _buildCompactInfoRow('Group Name', schedule.group.name, Icons.group),
//                                 _buildCompactInfoRow('Maintenance Date', schedule.maintenanceDate, Icons.calendar_today),
//                                 _buildCompactInfoRow('M-Code', schedule.project.pjCode, Icons.code),
//                                 const Divider(height: 16),
//                                 // Display the list of Johkasou modules with their buttons
//                                 if (schedule.johkasouModels.isNotEmpty)
//                                   _buildJohkasouModulesList(schedule),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: TizaraaColors.Tizara,
//         title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white)),
//       ),
//       backgroundColor: Colors.white,
//       body: _isLoading
//           ? _buildLoadingIndicator()
//           : _errorMessage.isNotEmpty
//           ? _buildErrorWidget()
//           : _buildMainContent(),
//     );
//   }
// }
//
//
// ==========//
//
//


import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_PT_view_album.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Maintenance_Response/Inspector_Home_maintenance_schedule.dart' hide MaintenanceSchedule;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redis/redis.dart';
import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';
import '../../../Core/Utils/colors.dart';
import '../../../Model/inspector_pending_task_model.dart';
import '../Authentication/login_screen.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_questions.dart';
import 'Inspector_Image_after_before_screen.dart' hide Category;

class ApiService {
  Future<List<MaintenanceSchedule>> fetchMaintenanceSchedules() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      List<MaintenanceSchedule> allSchedules = [];
      int currentPage = 1;
      bool hasMorePages = true;

      while (hasMorePages) {
        final response = await http.get(
          Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules-pending-task?page=$currentPage'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print('API Response Status (Page $currentPage): ${response.statusCode}');
        print('API Response Body (Page $currentPage): ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == true) {
            if (data['data'] != null && data['data']['maintenance_schedule'] != null) {
              final paginationData = data['data']['maintenance_schedule'];
              final maintenanceSchedulesJson = paginationData['data'] as List?;

              if (maintenanceSchedulesJson != null && maintenanceSchedulesJson.isNotEmpty) {
                final schedules = maintenanceSchedulesJson
                    .map((json) => MaintenanceSchedule.fromJson(json))
                    .toList();
                allSchedules.addAll(schedules);

                final currentPageFromAPI = paginationData['current_page'] ?? currentPage;
                final lastPage = paginationData['last_page'] ?? currentPage;
                final hasNextPage = currentPageFromAPI < lastPage;

                print('Page $currentPage: Found ${schedules.length} schedules');
                print('Current page: $currentPageFromAPI, Last page: $lastPage');

                if (hasNextPage) {
                  currentPage++;
                } else {
                  hasMorePages = false;
                }
              } else {
                hasMorePages = false;
              }
            } else {
              throw Exception('Maintenance schedules data structure is invalid on page $currentPage');
            }
          } else {
            throw Exception('API returned false status on page $currentPage: ${data['message']}');
          }
        } else {
          throw Exception('Failed to load maintenance schedules on page $currentPage. Status code: ${response.statusCode}');
        }
      }

      print('Total schedules fetched: ${allSchedules.length}');
      return allSchedules;
    } catch (e) {
      print('Error in fetchMaintenanceSchedules: $e');
      throw Exception('Error fetching maintenance schedules: $e');
    }
  }

  Future<List<MaintenanceSchedule>> fetchAllMaintenanceSchedulesWithProgress({
    Function(int currentPage, int totalFetched)? onProgress,
  }) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      List<MaintenanceSchedule> allSchedules = [];
      int currentPage = 1;
      int totalFetched = 0;

      while (true) {
        try {
          final response = await http.get(
            Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance_schedules-pending-task?page=$currentPage'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(Duration(seconds: 30));

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);

            if (data['status'] == true &&
                data['data'] != null &&
                data['data']['maintenance_schedule'] != null) {
              final paginationData = data['data']['maintenance_schedule'];
              final maintenanceSchedulesJson = paginationData['data'] as List?;

              if (maintenanceSchedulesJson == null || maintenanceSchedulesJson.isEmpty) {
                break;
              }

              final schedules = maintenanceSchedulesJson
                  .map((json) => MaintenanceSchedule.fromJson(json))
                  .toList();

              allSchedules.addAll(schedules);
              totalFetched += schedules.length;

              if (onProgress != null) {
                onProgress(currentPage, totalFetched);
              }

              final lastPage = paginationData['last_page'];
              if (currentPage >= lastPage) {
                break;
              }

              currentPage++;
              await Future.delayed(Duration(milliseconds: 100));
            } else {
              print('Invalid data structure on page $currentPage');
              break;
            }
          } else {
            print('HTTP Error on page $currentPage: ${response.statusCode}');
            break;
          }
        } catch (pageError) {
          print('Error fetching page $currentPage: $pageError');
          if (pageError.toString().contains('timeout')) {
            await Future.delayed(Duration(seconds: 2));
            continue;
          } else {
            break;
          }
        }
      }

      print('Successfully fetched $totalFetched maintenance schedules from $currentPage pages');
      return allSchedules;
    } catch (e) {
      print('Error in fetchAllMaintenanceSchedulesWithProgress: $e');
      throw Exception('Error fetching maintenance schedules: $e');
    }
  }

  Future<List<Category>> fetchCategoriesWithQuestions(int johkasouModelId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/get-category-with-questions?johkasou_model_id=$johkasouModelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Categories API Response Status: ${response.statusCode}');
      print('Categories API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final categoriesJson = data['date'] as List?;
          if (categoriesJson != null) {
            return categoriesJson.map((json) => Category.fromJson(json)).toList();
          } else {
            throw Exception('Categories data is null');
          }
        } else {
          throw Exception('API returned false status: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchCategoriesWithQuestions: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  // New method to mark task as completed
  Future<bool> markTaskAsCompleted(int scheduleId, int johkasouModelId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/mark-task-completed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'schedule_id': scheduleId,
          'johkasou_model_id': johkasouModelId,
          'status': '1',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Update Redis
          final redisConnection = RedisConnection();
          final redisCommand = await redisConnection.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
          await redisCommand.send_object(['AUTH', 'password']).timeout(Duration(seconds: 2));
          await redisCommand.send_object(['SET', 'completed_${scheduleId}_$johkasouModelId', 'true']).timeout(Duration(seconds: 2));
          await redisCommand.send_object(['QUIT']);
          await redisConnection.close();

          // Update SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('completed_${scheduleId}_$johkasouModelId', true);

          return true;
        } else {
          throw Exception('Failed to mark task as completed: ${data['message']}');
        }
      } else {
        throw Exception('Failed to mark task as completed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in markTaskAsCompleted: $e');
      return false;
    }
  }
}

class Inspector_PendingTaskScreen extends StatefulWidget {
  final String title;
  const Inspector_PendingTaskScreen({super.key, required this.title});

  @override
  _Inspector_PendingTaskScreenState createState() => _Inspector_PendingTaskScreenState();
}

class _Inspector_PendingTaskScreenState extends State<Inspector_PendingTaskScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<MaintenanceSchedule> _maintenanceSchedules = [];
  List<MaintenanceSchedule> _filteredSchedules = [];
  List<bool> _isExpanded = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _checkSessionValidity();
      await _loadMaintenanceSchedules();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error in _loadData: $e');
    }
  }

  Future<void> _checkSessionValidity() async {
    try {
      final tokenExpired = await TokenManager.isTokenExpired();
      if (tokenExpired) {
        await TokenManager.clearToken();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print('Error in _checkSessionValidity: $e');
    }
  }

  int _currentPage = 0;
  int _totalFetched = 0;
  bool _showProgress = false;

  Future<void> _loadMaintenanceSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _showProgress = true;
      _currentPage = 0;
      _totalFetched = 0;
    });

    try {
      final schedules = await _apiService.fetchAllMaintenanceSchedulesWithProgress(
        onProgress: (currentPage, totalFetched) {
          setState(() {
            _currentPage = currentPage;
            _totalFetched = totalFetched;
          });
        },
      );

      setState(() {
        _maintenanceSchedules = schedules;
        _filteredSchedules = schedules;
        _isExpanded = List.generate(schedules.length, (_) => false);
        _isLoading = false;
        _showProgress = false;
      });

      print('Successfully loaded ${schedules.length} maintenance schedules');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
        _showProgress = false;
      });
      print('Error in _loadMaintenanceSchedules: $e');
    }
  }

  Future<bool> _isTaskCompleted(int maintenanceScheduleId, int johkasouId) async {
    final prefs = await SharedPreferences.getInstance();
    bool isCompleted = prefs.getBool('completed_${maintenanceScheduleId}_$johkasouId') ?? false;

    try {
      final redisConnection = RedisConnection();
      final redisCommand = await redisConnection.connect('145.223.88.141', 6379).timeout(Duration(seconds: 5));
      await redisCommand.send_object(['AUTH', 'password']).timeout(Duration(seconds: 2));
      var redisData = await redisCommand.send_object(['GET', 'completed_${maintenanceScheduleId}_$johkasouId']).timeout(Duration(seconds: 2));
      await redisCommand.send_object(['QUIT']);
      await redisConnection.close();

      if (redisData != null && redisData == 'true') {
        isCompleted = true;
        await prefs.setBool('completed_${maintenanceScheduleId}_$johkasouId', true);
      }
    } catch (e) {
      print('Redis error checking completion for johkasouId $johkasouId: $e');
    }

    return isCompleted;
  }

  void _filterSchedules(String query) {
    setState(() {
      _filteredSchedules = _maintenanceSchedules.where((schedule) {
        final projectName = schedule.project.projectName.toLowerCase();
        final pjCode = schedule.project.pjCode.toLowerCase();
        final maintenanceDate = schedule.maintenanceDate.toLowerCase();
        final groupName = schedule.group.name.toLowerCase();
        final moduleNames = schedule.johkasouModels.map((m) => m.module.toLowerCase()).join(' ');
        return projectName.contains(query.toLowerCase()) ||
            pjCode.contains(query.toLowerCase()) ||
            maintenanceDate.contains(query.toLowerCase()) ||
            groupName.contains(query.toLowerCase()) ||
            moduleNames.contains(query.toLowerCase());
      }).toList();
      _isExpanded = List.generate(_filteredSchedules.length, (_) => false);
    });
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No maintenance schedules found',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildJohkasouModulesList(MaintenanceSchedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, bottom: 2.0),
          child: Text(
            'Johkasou Modules:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        ...schedule.johkasouModels.map((model) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompactInfoRow('Module', model.module, Icons.hardware),
                if (model.serialNumber != null)
                  _buildCompactInfoRow('Serial', model.serialNumber!, Icons.confirmation_number),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorPtViewAlbum(
                            johkasouModelID: model.id,
                            ScheduleID: schedule.id,
                            title: 'Categories for ${model.module}',
                          )));
                          print('Album view pressed for module ${model.id}');
                        },
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: const Text('View Album', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0074BA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryQuestionsScreen(
                                johkasouModelId: model.id,
                                title: 'Categories for ${model.module}',
                                projectId: schedule.project.projectId,
                                scheduleId: schedule.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                        label: const Text('Upload Image', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0074BA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspectorMaintenanceQuestionpage(
                                maintenanceScheduleId: schedule.id,
                                johkasouId: model.id,
                                project_name: schedule.project.projectName,
                                next_maintenance_date: schedule.nextMaintenanceDate ?? '',
                                projectId: schedule.project.projectId,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: model.taskStatus == "1" ? Colors.grey.shade300 : const Color(0xFF0074BA),
                          foregroundColor: model.taskStatus == "1" ? Colors.grey.shade600 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              model.taskStatus == "1" ? "Completed" : "Perform Task",
                              style: TextStyle(
                                fontSize: 11,
                                color: model.taskStatus == "1" ? Colors.grey.shade600 : Colors.white,
                              ),
                            ),
                            if (model.taskStatus == "1")
                              Text(
                                '✓',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCompactInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Name, Code, Date',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _filterSchedules,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x0476BD).withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            height: 35,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "SL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      "Project Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _filteredSchedules.isEmpty
              ? _buildNoDataWidget()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filteredSchedules.length,
            itemBuilder: (context, index) {
              final schedule = _filteredSchedules[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ExpansionTile(
                  backgroundColor: TizaraaColors.primaryColor,
                  collapsedBackgroundColor: TizaraaColors.primaryColor2,
                  leading: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: TizaraaColors.Tizara,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  initiallyExpanded: _isExpanded[index],
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isExpanded[index] = expanded;
                    });
                  },
                  title: Text(
                    schedule.project.projectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TizaraaColors.Tizara,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    schedule.maintenanceDate,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    _isExpanded[index] ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF0074BA),
                    size: 20,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: TizaraaColors.primaryColor2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCompactInfoRow('Location', schedule.project.location, Icons.location_on),
                                _buildCompactInfoRow('Group Name', schedule.group.name, Icons.group),
                                _buildCompactInfoRow('Maintenance Date', schedule.maintenanceDate, Icons.calendar_today),
                                _buildCompactInfoRow('M-Code', schedule.project.pjCode, Icons.code),
                                const Divider(height: 16),
                                if (schedule.johkasouModels.isNotEmpty)
                                  _buildJohkasouModulesList(schedule),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TizaraaColors.Tizara,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildMainContent(),
    );
  }
}

