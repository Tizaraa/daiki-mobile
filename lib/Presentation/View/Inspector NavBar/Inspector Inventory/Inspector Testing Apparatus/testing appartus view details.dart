import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Core/Utils/colors.dart';
import 'Inspector_assign_inspector.dart';

class TestingAppartusViewDetails extends StatefulWidget {
  final int itemId;

  const TestingAppartusViewDetails({Key? key, required this.itemId}) : super(key: key);

  @override
  _TestingAppartusViewDetailsState createState() => _TestingAppartusViewDetailsState();
}

class _TestingAppartusViewDetailsState extends State<TestingAppartusViewDetails> {
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
    final String url = 'https://backend.johkasou-erp.com/api/v1/inventory/${widget.itemId}';

    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

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

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = json.decode(response.body) as Map<String, dynamic>?;

        if (responseData != null && responseData.containsKey('data') && responseData['data'] != null) {
          final Map<String, dynamic> itemData = responseData['data'] as Map<String, dynamic>;
          print("Debug - Item Data: $itemData");

          // Extract calibration history with null safety
          final List<dynamic> history = itemData['calibration_history'] as List<dynamic>? ?? [];
          final List<Map<String, dynamic>> calibrationHistory = history.map((entry) {
            if (entry == null) {
              return {
                'last_calibration_date': 'Unknown',
                'next_calibration_date': 'Unknown',
                'calibrated_by': 'Unknown',
                'status': 'Unknown',
                'remarks': 'No remarks',
              };
            }

            // Safely access nested user object
            Map<String, dynamic>? user = entry['user'] as Map<String, dynamic>?;

            return {
              'last_calibration_date': entry['last_calibration_date']?.toString() ?? 'Unknown',
              'next_calibration_date': entry['calibration_time']?.toString() ?? 'Unknown',
              'calibrated_by': user?['name']?.toString() ?? 'Unknown',
              'status': entry['status'] == 1 ? 'Completed' : 'Pending',
              'remarks': entry['remarks']?.toString() ?? 'No remarks',
            };
          }).toList();

          // Store fetched data in state
          setState(() {
            itemDetails = itemData;
            calibrationData = calibrationHistory;
            isLoading = false;
            hasError = false;
          });
        } else {
          print("Error: API response missing 'data' field or malformed");
          throw Exception("API response missing 'data' field or malformed");
        }
      } else {
        throw Exception('Failed to load item details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item details: $e');  // Debugging error
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
        // Initialize itemDetails as empty map to prevent null errors
        itemDetails = {};
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

          final headers = {
            'Authorization': token?.startsWith('Bearer ') ?? false
                ? token!
                : 'Bearer $token',
          };
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
              width: MediaQuery.of(context).size.width,
                color: TizaraaColors.Tizara,
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

  Widget buildTeamDetails() {
    // Safely check if teams exists and is not empty
    if (itemDetails == null ||
        !itemDetails!.containsKey('teams') ||
        itemDetails!['teams'] == null ||
        (itemDetails!['teams'] as List?)!.isEmpty ?? true) {
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
                    // Users Section
                    if (team?['users'] != null && (team['users'] as List?)!.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Users:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (team['users'] as List).map((user) {
                                return ListTile(
                                  title: Text(user?['name'] ?? 'Unknown User'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Email: ${user?['email'] ?? 'N/A'}'),
                                      Text('Phone: ${user?['phone'] ?? 'N/A'}'),
                                    ],
                                  ),
                                  leading: buildUserAvatar(user),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Projects Section
                    if (team?['projects'] != null && (team['projects'] as List?)!.isNotEmpty ?? false)
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
                              (team['projects'] as List).map((project) {
                                return ListTile(
                                  title: Text(project?['project_name'] ?? 'Unknown Project'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Location: ${project?['location'] ?? 'N/A'}'),
                                      Text('Status: ${project?['project_status'] ?? 'N/A'}'),
                                      Text('Capacity: ${project?['capacity'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Inspector History Section
                    if (team?['assign_inspector_history'] != null &&
                        (team['assign_inspector_history'] as List?)!.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assign Inspector History:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (team['assign_inspector_history'] as List).map((history) {
                                return ListTile(
                                  title: Text('Assigned To: ${history?['assigned_to']?['name'] ?? 'Unknown'}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Assigned By: ${history?['assigned_by']?['name'] ?? 'Unknown'}'),
                                      Text('Assigned At: ${history?['assigned_at'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Project History Section
                    if (team?['assign_project_history'] != null &&
                        (team['assign_project_history'] as List?)!.isNotEmpty ?? false)
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
                              (team['assign_project_history'] as List).map((history) {
                                return ListTile(
                                  title: Text('Project: ${history?['project']?['project_name'] ?? 'Unknown'}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Assigned By: ${history?['assigned_by']?['name'] ?? 'Unknown'}'),
                                      Text('Assigned At: ${history?['assigned_at'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Calibration History Section
                    if (itemDetails?['calibration_history'] != null &&
                        (itemDetails!['calibration_history'] as List?)!.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calibration History:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (itemDetails!['calibration_history'] as List).map((history) {
                                return ListTile(
                                  title: Text('Calibrated By: ${history?['user']?['name'] ?? 'Unknown'}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Last Calibrated Date: ${history?['last_calibration_date'] ?? 'N/A'}'),
                                      Text('Next Calibration Date: ${history?['calibration_time'] ?? 'N/A'}'),
                                      Text('Status: ${history?['status'] == 1 ? 'Completed' : 'Pending'}'),
                                      Text('Remarks: ${history?['remarks'] ?? 'No remarks'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Inspector Assignment Button
                    Row(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     children: [
                        //       SizedBox(
                        //         height: 50,
                        //         width: 165,
                        //         child: InspectorAssignment(teamId: teamId),
                        //       )
                        //     ],
                        //   ),
                        // ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 50,
                                width: 150,
                                child: AssignProject(teamId: teamId),
                              )
                            ],
                          ),
                        ),
                      ],
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


  Widget buildTeamHistory() {
    // Safe null check with multiple conditions
    if (itemDetails == null ||
        !itemDetails!.containsKey('inventory_assign_team_history') ||
        itemDetails!['inventory_assign_team_history'] == null ||
        (itemDetails!['inventory_assign_team_history'] as List?)!.isEmpty ?? true) {
      return Container();
    }

    return buildSection(
      'Inventory Assign Team History',
      [
        ...List<Widget>.from(
          (itemDetails!['inventory_assign_team_history'] as List).map((history) {
            return Card(
              child: ExpansionTile(
                title: Text('Team: ${history?['team']?['name'] ?? 'Unknown Team'}'),
                children: [
                  ListTile(
                    title: Text('Team: ${history?['team']?['name'] ?? 'Unknown Team'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned By: ${history?['assigned_by']?['name'] ?? 'Unknown'}'),
                        Text('Assigned At: ${formatDate(history?['assigned_at'] ?? '')}'),
                        Text('Stock: ${history?['main_stock'] ?? 'N/A'} (Distributed: ${history?['distribute_stock'] ?? 'N/A'})'),
                        Text('Inventory: ${history?['inventory_item']?['name'] ?? 'Unknown Item'}'),
                        Text('Description: ${history?['inventory_item']?['description'] ?? 'No Description'}'),
                        Text('Condition: ${history?['inventory_item']?['condition'] ?? 'Unknown Condition'}'),
                        Text('Date: ${formatDate(history?['created_at'] ?? '')}'),
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
    // Safe null check with multiple conditions
    if (itemDetails == null ||
        !itemDetails!.containsKey('assign_inspector_history') ||
        itemDetails!['assign_inspector_history'] == null ||
        (itemDetails!['assign_inspector_history'] as List?)!.isEmpty ?? true) {
      return Container();
    }

    return buildSection(
      'Inspector Assignment History',
      [
        ...List<Widget>.from(
          (itemDetails!['assign_inspector_history'] as List).map((history) {
            return Card(
              child: ListTile(
                title: Text('Inspector: ${history?['inspector']?['name'] ?? 'Unknown Inspector'}'),
                subtitle: Text('Date: ${formatDate(history?['created_at'] ?? '')}'),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildProjects() {
    // Safe null check with multiple conditions
    if (itemDetails == null ||
        !itemDetails!.containsKey('projects') ||
        itemDetails!['projects'] == null ||
        (itemDetails!['projects'] as List?)!.isEmpty ?? true) {
      return Container();
    }

    return buildSection(
      'Related Projects',
      [
        ...List<Widget>.from(
          (itemDetails!['projects'] as List).map((project) {
            return Card(
              child: ListTile(
                title: Text(project?['name'] ?? 'Unknown Project'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${project?['status'] ?? 'N/A'}'),
                    Text('Created: ${formatDate(project?['created_at'] ?? '')}'),
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
                  SizedBox(height: 20,),
                  buildTeamHistory(),
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