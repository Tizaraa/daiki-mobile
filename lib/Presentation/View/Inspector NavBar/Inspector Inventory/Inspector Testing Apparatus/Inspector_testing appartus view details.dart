import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Core/Utils/api_service.dart';


class InspectorTestingAppartusViewDetails extends StatefulWidget {
  final int itemId;

  const InspectorTestingAppartusViewDetails({Key? key, required this.itemId}) : super(key: key);

  @override
  _InspectorTestingAppartusViewDetailsState createState() => _InspectorTestingAppartusViewDetailsState();
}

class _InspectorTestingAppartusViewDetailsState extends State<InspectorTestingAppartusViewDetails> {
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
          final List<dynamic> history = data['data']['calibration_history'] ?? [];

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
          '${DaikiAPI.api_key}/daiki/image/${user['inventory_image']}'
      );
      final String photoUrl2 = Uri.encodeFull(
          '${DaikiAPI.api_key}/daiki/image/${user['inventory_image']}'
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
        title: Text(itemDetails != null ? itemDetails!['name'] : 'Loading...'),
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