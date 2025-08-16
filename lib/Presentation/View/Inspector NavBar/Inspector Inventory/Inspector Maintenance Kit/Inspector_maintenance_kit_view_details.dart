// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'Inspector_assign_inspector.dart';
//
// class Inspector_MaintenanceKitViewDetails extends StatefulWidget {
//   final int itemId;
//
//   const Inspector_MaintenanceKitViewDetails({Key? key, required this.itemId}) : super(key: key);
//
//   @override
//   _Inspector_MaintenanceKitViewDetailsState createState() => _Inspector_MaintenanceKitViewDetailsState();
// }
//
// class _Inspector_MaintenanceKitViewDetailsState extends State<Inspector_MaintenanceKitViewDetails> {
//   bool isLoading = true;
//   bool hasError = false;
//   String errorMessage = '';
//   Map<String, dynamic>? itemDetails;
//
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchItemDetails();
//   }
//
//   String formatDate(dynamic dateString) {
//     if (dateString == null) return 'N/A';
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }
//
//   Future<void> fetchItemDetails() async {
//     final String url = 'https://backend.johkasou-erp.com/api/v1/inventory/${widget.itemId}';
//
//     try {
//       final token = await getToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['status'] == true && data['data'] != null) {
//           setState(() {
//             itemDetails = data['data'];
//             isLoading = false;
//             hasError = false;
//           });
//         } else {
//           throw Exception(data['message'] ?? 'Invalid response format');
//         }
//       } else {
//         throw Exception('Failed to load item details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching item details: $e');
//       setState(() {
//         isLoading = false;
//         hasError = true;
//         errorMessage = e.toString();
//       });
//     }
//   }
//
//
//
//   Widget buildImage(String? token) {
//     if (itemDetails?['inventory_image'] == null) {
//       return const Icon(Icons.image, size: 200, color: Colors.grey);
//     }
//
//     final String encodedImageUrl = Uri.encodeFull('https://minio.johkasou-erp.com/daiki/image/${itemDetails!['inventory_image']}');
//     print('Encoded Image URL: $encodedImageUrl');
//
//     return Container(
//       height: 200,
//       width: double.infinity,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: CachedNetworkImage(
//           imageUrl: encodedImageUrl,
//           fit: BoxFit.cover,
//           httpHeaders: {
//             'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',
//           },
//           placeholder: (context, url) => Center(
//             child: CircularProgressIndicator(),
//           ),
//           errorWidget: (context, url, error) {
//             print('Image Error: $error');
//             return Container(
//               height: 200,
//               color: Colors.grey[200],
//               child: const Center(
//                 child: Icon(Icons.error_outline, color: Colors.red, size: 40),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget buildSection(String title, List<Widget> children) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildDetailRow(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(value ?? 'N/A'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildBasicDetails() {
//     // Check if itemDetails is null and return a placeholder if it is
//     if (itemDetails == null) {
//       return const Center(child: Text('No item details available'));
//     }
//
//     return buildSection(
//       'Basic Details',
//       [
//         buildDetailRow('Name', itemDetails?['name']),
//         buildDetailRow('Description', itemDetails?['description']),
//         buildDetailRow('Condition', itemDetails?['condition']),
//         buildDetailRow('Unit', itemDetails?['unit']),
//         buildDetailRow('Created At', formatDate(itemDetails?['created_at'])),
//         buildDetailRow('Updated At', formatDate(itemDetails?['updated_at'])),
//
//         // Use null-aware operators to avoid null pointer exceptions
//         buildDetailRow('Type', itemDetails?['type'] == 1 ? 'Type 1' : 'Type 2'),
//         buildDetailRow('Status', itemDetails?['status'] == 1 ? 'Active' : 'Inactive'),
//         buildDetailRow('Calibration Time', formatDate(itemDetails?['calibration_time'])),
//         buildDetailRow('Last Calibration Date', formatDate(itemDetails?['last_calibration_date'])),
//         buildDetailRow('SKU', itemDetails?['sku']),
//
//         // Use null-aware operators for nested properties
//         buildDetailRow('Lifting Price', itemDetails?['lifting_price']?.toString() ?? 'N/A'),
//         buildDetailRow('Remarks', itemDetails?['remarks'] ?? 'N/A'),
//
//         // Use null checks for nested objects
//         if (itemDetails?['stock'] != null) ...[
//           buildDetailRow('Stock Quantity', itemDetails?['stock']['quantity']?.toString() ?? 'N/A'),
//           buildDetailRow('Stock Minimum Quantity', itemDetails?['stock']['minimum_quantity']?.toString() ?? 'N/A'),
//           buildDetailRow('Stock Created At', formatDate(itemDetails?['stock']['created_at'])),
//           buildDetailRow('Stock Updated At', formatDate(itemDetails?['stock']['updated_at'])),
//         ] else
//           buildDetailRow('Stock Information', 'Not available'),
//
//         // If you have a project_name field that's causing the error, ensure it's properly checked
//         if (itemDetails?['project_name'] != null)
//           buildDetailRow('Project Name', itemDetails?['project_name']),
//       ],
//     );
//   }
//
//
//
//   //  ======== team details    =========//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Inspector Maintenance Kit Details'),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : hasError
//           ? Center(child: Text('Error: $errorMessage'))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             FutureBuilder<String?>(
//               future: getToken(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else {
//                   final token = snapshot.data;
//                   return buildImage(token);
//                 }
//               },
//             ),
//             const SizedBox(height: 16),
//             buildBasicDetails(),
//             const SizedBox(height: 16),
//             buildTeamDetails(),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget buildTeamDetails() {
//     if (itemDetails?['teams'] == null || (itemDetails!['teams'] as List).isEmpty) {
//       return Container();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Team Details',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         ...List<Widget>.from(
//           (itemDetails!['teams'] as List).map((team) {
//             final String teamId = team['id']?.toString() ?? '';
//
//             return Card(
//               margin: const EdgeInsets.only(bottom: 16),
//               child: ExpansionTile(
//                 title: Text(team['name'] ?? 'Unknown Team'),
//                 subtitle: Text('Stock: ${team['pivot']?['stock'] ?? 'N/A'}'),
//                 children: [
//                   // Display Users
//                   if (team['users'] != null && (team['users'] as List).isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Users:',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           ...List<Widget>.from(
//                             (team['users'] as List).map((user) {
//                               return ListTile(
//                                 title: Text(user['name'] ?? 'Unknown User'),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Email: ${user['email'] ?? 'N/A'}'),
//                                     Text('Phone: ${user['phone'] ?? 'N/A'}'),
//                                   ],
//                                 ),
//                                 leading: user['photo'] != null
//                                     ? CircleAvatar(
//                                   backgroundImage: NetworkImage(
//                                     'https://minio.johkasou-erp.com/daiki/image/${user['photo']}',
//                                   ),
//                                 )
//                                     : const CircleAvatar(
//                                   child: Icon(Icons.person),
//                                 ),
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // Display Projects
//                   if (team['projects'] != null && (team['projects'] as List).isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Projects:',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           ...List<Widget>.from(
//                             (team['projects'] as List).map((project) {
//                               return ListTile(
//                                 title: Text(project['project_name'] ?? 'Unknown Project'),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Location: ${project['location'] ?? 'N/A'}'),
//                                     Text('Status: ${project['project_status'] ?? 'N/A'}'),
//                                     Text('Capacity: ${project['capacity'] ?? 'N/A'}'),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//
//
//                   // Display Assign Inspector History
//                   if (team['assign_inspector_history'] != null && (team['assign_inspector_history'] as List).isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Assign Inspector History:',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           ...List<Widget>.from(
//                             (team['assign_inspector_history'] as List).map((history) {
//                               return ListTile(
//                                 title: Text('Assigned To: ${history['assigned_to']['name'] ?? 'Unknown'}'),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Assigned By: ${history['assigned_by']['name'] ?? 'Unknown'}'),
//                                     Text('Assigned At: ${history['assigned_at'] ?? 'N/A'}'),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // Display Assign Project History
//                   if (team['assign_project_history'] != null && (team['assign_project_history'] as List).isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Assign Project History:',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           ...List<Widget>.from(
//                             (team['assign_project_history'] as List).map((history) {
//                               return ListTile(
//                                 title: Text('Project: ${history['project']['project_name'] ?? 'Unknown'}'),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Assigned By: ${history['assigned_by']['name'] ?? 'Unknown'}'),
//                                     Text('Assigned At: ${history['assigned_at'] ?? 'N/A'}'),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // Inspector Assignment Button
//                   Row(
//                     children: [
//
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               height: 50,
//                               width: 165,
//                               child: Inspector_MaintenanceInspectorAssignment(teamId: teamId,),
//                             )
//                           ],
//                         ),
//                       ),
//                       //=============//
//
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               height: 50,
//                               width: 150,
//                               child: MaintenanceAssignProject(teamId: teamId,),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//
//
//                 ],
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
//
//   Widget buildTeamHistory() {
//     if (itemDetails?['inventory_assign_team_history'] == null ||
//         (itemDetails!['inventory_assign_team_history'] as List).isEmpty) {
//       return Container();
//     }
//
//     return buildSection(
//       'Inventory Assign Team History',
//       [
//         ...List<Widget>.from(
//           (itemDetails!['inventory_assign_team_history'] as List).map((history) {
//             return Card(
//               child: ExpansionTile(
//                   title: Text('Team: ${history['team']?['name'] ?? 'Unknown Team'}'),
//                   children:[ ListTile(
//                     title: Text('Team: ${history['team']?['name'] ?? 'Unknown Team'}'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Assigned By: ${history['assigned_by']?['name'] ?? 'Unknown'}'),
//                         Text('Assigned At: ${formatDate(history['assigned_at'] ?? '')}'),
//                         Text('Stock: ${history['main_stock']} (Distributed: ${history['distribute_stock']})'),
//                         Text('Inventory: ${history['inventory_item']?['name'] ?? 'Unknown Item'}'),
//                         Text('Description: ${history['inventory_item']?['description'] ?? 'No Description'}'),
//                         Text('Condition: ${history['inventory_item']?['condition'] ?? 'Unknown Condition'}'),
//                         Text('Date: ${formatDate(history['created_at'] ?? '')}'),
//                       ],
//                     ),
//                   ),
//                   ]
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
//
//
//   Widget buildInspectorHistory() {
//     if (itemDetails?['assign_inspector_history'] == null ||
//         (itemDetails!['assign_inspector_history'] as List).isEmpty) {
//       return Container();
//     }
//
//     return buildSection(
//       'Inspector Assignment History',
//       [
//         ...List<Widget>.from(
//           (itemDetails!['assign_inspector_history'] as List).map((history) {
//             return Card(
//               child: ListTile(
//                 title: Text('Inspector: ${history['inspector']?['name'] ?? 'Unknown Inspector'}'),
//                 subtitle: Text('Date: ${formatDate(history['created_at'])}'),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
//
//   Widget buildProjects() {
//     if (itemDetails?['projects'] == null ||
//         (itemDetails!['projects'] as List).isEmpty) {
//       return Container();
//     }
//
//     return buildSection(
//       'Related Projects',
//       [
//         ...List<Widget>.from(
//           (itemDetails!['projects'] as List).map((project) {
//             return Card(
//               child: ListTile(
//                 title: Text(project['name'] ?? 'Unknown Project'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Status: ${project['status'] ?? 'N/A'}'),
//                     Text('Created: ${formatDate(project['created_at'])}'),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }

  //  ============  //


import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Core/Utils/api_service.dart';
import '../../../../../Core/Utils/colors.dart';

class Inspector_MaintenanceKitViewDetails extends StatefulWidget {
  final int itemId;

  const Inspector_MaintenanceKitViewDetails({Key? key, required this.itemId}) : super(key: key);

  @override
  _Inspector_MaintenanceKitViewDetailsState createState() => _Inspector_MaintenanceKitViewDetailsState();
}

class _Inspector_MaintenanceKitViewDetailsState extends State<Inspector_MaintenanceKitViewDetails> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic>? itemDetails;
  List<Map<String, dynamic>> calibrationData = [];


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
    testImageUrl();
  }

  void testImageUrl() async {
    final token = await getToken();
    final url = Uri.parse('https://minio.johkasou-erp.com/daiki/image');
    final response = await http.get(
      url,
      headers: {
        'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',
        'Accept': '*/*',
      },
    );
    print('Test image response status: ${response.statusCode}');
    print('Test image response headers: ${response.headers}');
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Not available';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> fetchItemDetails() async {
    final String url = '${DaikiAPI.api_key}/api/v1/inventory/${widget.itemId}';

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> history = data['data']['maintenanceKitList'] ?? [];

          final List<Map<String, dynamic>> calibrationHistory = history.map((entry) {
            return {
              'last_calibration_date': entry['last_calibration_date'],
              'next_calibration_date': entry['calibration_time'],
              'calibrated_by': entry['user']?['name'] ?? 'Unknown',
              'status': entry['status'] == 1 ? 'Completed' : 'Pending',
              'remarks': entry['remarks'] ?? 'No remarks',
            };
          }).toList();

          setState(() {
            itemDetails = data['data'];
            calibrationData = calibrationHistory;
            isLoading = false;
            hasError = false;
          });
        } else {
          throw Exception('Invalid response: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load item details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }



  Widget buildUserAvatar(Map<String, dynamic> user) {
    if (user['photo'] != null) {
      // Try both potential URL formats
      final String photoUrl1 = Uri.encodeFull(
          'https://minio.johkasou-erp.com/daiki/image/${user['inventory_image']}'
      );
      final String photoUrl2 = Uri.encodeFull(
          'https://minio.johkasou-erp.com/daiki/image/${user['inventory_image']}'
      );

      print('Debug - Photo URL 1: $photoUrl1');
      print('Debug - Photo URL 2: $photoUrl2');

      return FutureBuilder<String?>(
        future: getToken(),
        builder: (context, tokenSnapshot) {
          if (!tokenSnapshot.hasData) {
            print('Debug - No token available');
            return CircleAvatar(child: Icon(Icons.person));
          }

          final token = tokenSnapshot.data;
          print('Debug - Token: $token');

          final headers = {'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',};
          print('Debug - Headers: $headers');

          // Try making a direct HTTP request to check the URL
          http.get(Uri.parse(photoUrl1), headers: headers).then((response) {
            print('Debug - HTTP Response status for URL1: ${response.statusCode}');
          });

          return CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              photoUrl1,  // Try with the first URL format
              headers: headers,
            ),
            onBackgroundImageError: (exception, stackTrace) {
              print('Debug - Avatar Error: $exception');
              print('Debug - Stack trace: $stackTrace');
              return null;  // Return null to show the child
            },
            child: Icon(Icons.person),  // Fallback icon
          );
        },
      );
    }
    return CircleAvatar(child: Icon(Icons.person));
  }

  Widget buildImage(String? token) {
    if (itemDetails?['inventory_image'] == null) {
      return const Icon(Icons.image, size: 200, color: Colors.grey);
    }

    final String encodedImageUrl = Uri.encodeFull('https://minio.johkasou-erp.com/daiki/image/${itemDetails!['inventory_image']}');

    return Container(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: encodedImageUrl,
          fit: BoxFit.cover,
          httpHeaders: {
            'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',
          },
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) {
            print('Image Error: $error');
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red, size: 40),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: TizaraaColors.Tizara,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),),
                )),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildBasicDetails() {
    return buildSection(
      'Basic Details',
      [
        buildDetailRow('Name', itemDetails?['name']),
        buildDetailRow('Description', itemDetails?['description']),
        buildDetailRow('Condition', itemDetails?['condition']),
        buildDetailRow('Unit', itemDetails?['unit']),
        buildDetailRow('Created At', formatDate(itemDetails?['created_at'])),
        buildDetailRow('Updated At', formatDate(itemDetails?['updated_at'])),
        buildDetailRow('Type', itemDetails!['type'] == 1 ? 'Type 1' : 'Type 2'),
        buildDetailRow('Status', itemDetails!['status'] == 1 ? 'Active' : 'Inactive'),
        buildDetailRow('Calibration Time', formatDate(itemDetails!['calibration_time'])),
        buildDetailRow('Last Calibration Date', formatDate(itemDetails!['last_calibration_date'])),
        buildDetailRow('SKU', itemDetails!['sku']),
        buildDetailRow('Lifting Price', '${itemDetails!['lifting_price']}'),
        buildDetailRow('Remarks', itemDetails!['remarks']),
        buildDetailRow('Stock Quantity', itemDetails!['stock']?['quantity']?.toString() ?? 'N/A'),
        buildDetailRow('Stock Minimum Quantity', itemDetails!['stock']?['minimum_quantity']?.toString() ?? 'N/A'),
        buildDetailRow('Stock Created At', formatDate(itemDetails!['stock']?['created_at'])),
        buildDetailRow('Stock Updated At', formatDate(itemDetails!['stock']?['updated_at'])),
      ],
    );
  }

// Build Team Details
  Widget buildTeamDetails() {
    if (itemDetails?['teams'] == null || (itemDetails!['teams'] as List).isEmpty) {
      return Container();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width/1.2,
              color: TizaraaColors.Tizara,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Team Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),),
              )),
          const SizedBox(height: 8),
          ...List<Widget>.from(
            (itemDetails!['teams'] as List).map((team) {
              final String teamId = team?['id']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(team?['name'] ?? 'Unknown Team'),
                  subtitle: Text('Stock: ${team?['pivot']?['stock'] ?? 'N/A'}'),
                  children: [

                    // Projects Section
                    if (team?['projects'] != null && (team!['projects'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Projects:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (team!['projects'] as List).map((project) {
                                final safeProject = project ?? {}; // Prevent null errors
                                return ListTile(
                                  title: Text(safeProject['project_name'] ?? 'Unknown Project'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Location: ${safeProject['location'] ?? 'N/A'}'),
                                      Text('Status: ${safeProject['project_status'] ?? 'N/A'}'),
                                      Text('Capacity: ${safeProject['capacity'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Assign Project History
                    if (team?['assign_project_history'] != null && (team!['assign_project_history'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assign Project History:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (team!['assign_project_history'] as List).map((history) {
                                final project = history?['project'] ?? {}; // Prevent null errors
                                final assignedBy = history?['assigned_by'] ?? {}; // Prevent null errors
                                return ListTile(
                                  title: Text('Project: ${project['project_name'] ?? 'Unknown'}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Assigned By: ${assignedBy['name'] ?? 'Unknown'}'),
                                      Text('Assigned At: ${history?['assigned_at'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget buildInspectorHistory() {
    if (itemDetails?['assign_inspector_history'] == null ||
        (itemDetails!['assign_inspector_history'] as List).isEmpty) {
      return Container();
    }

    return buildSection(
      'Inspector Assignment History',
      [
        ...List<Widget>.from(
          (itemDetails!['assign_inspector_history'] as List).map((history) {
            final inspector = history['inspector'] ?? {}; // Prevent null errors

            return Card(
              child: ListTile(
                title: Text('Inspector: ${inspector['name'] ?? 'Unknown Inspector'}'),
                subtitle: Text('Date: ${formatDate(history['created_at'] ?? '')}'),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildProjects() {
    if (itemDetails?['projects'] == null ||
        (itemDetails!['projects'] as List).isEmpty) {
      return Container();
    }

    return buildSection(
      'Related Projects',
      [
        ...List<Widget>.from(
          (itemDetails!['projects'] as List).map((project) {
            final safeProject = project ?? {}; // Prevent null errors

            return Card(
              child: ListTile(
                title: Text(safeProject['name'] ?? 'Unknown Project'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${safeProject['status'] ?? 'N/A'}'),
                    Text('Created: ${formatDate(safeProject['created_at'] ?? '')}'),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }


  Widget buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'Not available'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TizaraaColors.Tizara,
        title: Text(itemDetails != null ? itemDetails!['name'] : 'Loading...',style: TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<String?>(
        future: getToken(),
        builder: (context, tokenSnapshot) {
          if (tokenSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text('Failed to load item details'),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        hasError = false;
                        errorMessage = '';
                      });
                      fetchItemDetails();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: fetchItemDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildImage(tokenSnapshot.data),
                  const SizedBox(height: 16),
                  buildBasicDetails(),
                  buildTeamDetails(),
                  buildInspectorHistory(),
                  buildProjects(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}