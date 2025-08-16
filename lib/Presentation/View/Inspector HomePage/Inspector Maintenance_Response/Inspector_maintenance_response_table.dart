import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';
import '../../../../Model/inspector_MR_model.dart';
import 'Inspector_maintenance_details_screen.dart';


class Inspector_MaintenanceScreenOutput extends StatefulWidget {
  const Inspector_MaintenanceScreenOutput({super.key});

  @override
  _Inspector_MaintenanceScreenOutputState createState() => _Inspector_MaintenanceScreenOutputState();
}

class _Inspector_MaintenanceScreenOutputState extends State<Inspector_MaintenanceScreenOutput> {
  late Future<List<MaintenanceResponse>> _maintenanceData;
  List<MaintenanceResponse> filteredData = [];
  String searchQuery = '';
  Map<int, bool> expandedItems = {};
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 6,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _maintenanceData = fetchMaintenanceData();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<List<MaintenanceResponse>> fetchMaintenanceData() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || await TokenManager.isTokenExpired()) {
        throw Exception('Token is missing or expired');
      }

      List<MaintenanceResponse> allMaintenanceData = [];
      int currentPage = 1;
      bool hasMoreData = true;

      while (hasMoreData) {
        final response = await http.get(
          Uri.parse('${DaikiAPI.api_key}/api/v1/maintenance/responses?page=$currentPage'),
          headers: {'Authorization': 'Bearer $token'},
        );

        print('Maintenance API Response Status (Page $currentPage): ${response.statusCode}');
        print('Maintenance API Response Body (Page $currentPage): ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['data'] != null && jsonResponse['data']['data'] != null) {
            final List<dynamic> data = jsonResponse['data']['data'];

            if (data.isNotEmpty) {
              List<MaintenanceResponse> pageMaintenanceList = data
                  .map((json) => MaintenanceResponse.fromJson(json))
                  .toList();

              allMaintenanceData.addAll(pageMaintenanceList);

              // Check pagination - try different common pagination patterns
              bool shouldContinue = false;
              final paginationData = jsonResponse['data'];

              // Pattern 1: Check current_page vs last_page
              if (paginationData.containsKey('current_page') &&
                  paginationData.containsKey('last_page')) {
                final currentPageNum = paginationData['current_page'];
                final lastPage = paginationData['last_page'];
                shouldContinue = currentPageNum < lastPage;
              }
              // Pattern 2: Check if has_more_pages exists
              else if (paginationData.containsKey('has_more_pages')) {
                shouldContinue = paginationData['has_more_pages'] == true;
              }
              // Pattern 3: Check next_page_url
              else if (paginationData.containsKey('next_page_url')) {
                shouldContinue = paginationData['next_page_url'] != null;
              }
              // Pattern 4: If less than expected per page (assuming 20 per page)
              else {
                shouldContinue = data.length >= 20;
              }

              if (shouldContinue) {
                currentPage++;
              } else {
                hasMoreData = false;
              }

              print('Fetched ${pageMaintenanceList.length} maintenance responses from page $currentPage. Total so far: ${allMaintenanceData.length}');
            } else {
              hasMoreData = false; // No more data
              print('No data found on page $currentPage, stopping pagination');
            }
          } else {
            throw Exception('Invalid response format');
          }
        } else {
          throw Exception('Failed to load maintenance data. Status code: ${response.statusCode}');
        }
      }

      print('Total maintenance responses fetched: ${allMaintenanceData.length}');
      return allMaintenanceData;

    } catch (e) {
      print('Error in fetchMaintenanceData: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> _showSignatureDialog(BuildContext context, String responseMasterId, String johkasouModelId) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Signature',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TizaraaColors.Tizara,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      icon: Icon(Icons.clear, color: Colors.white),
                      label: Text(
                        'Clear',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _uploadSignature(context, responseMasterId, johkasouModelId);
                      },
                      icon: Icon(Icons.upload, color: Colors.white),
                      label: Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TizaraaColors.Tizara,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _signatureController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadSignature(BuildContext context, String responseMasterId, String johkasouModelId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading signature...'),
                ],
              ),
            ),
          );
        },
      );

      // Check if signature is empty
      if (_signatureController.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add a signature before uploading'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get signature as bytes
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate signature'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get token
      final token = await TokenManager.getToken();
      if (token == null || await TokenManager.isTokenExpired()) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication token is missing or expired'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${DaikiAPI.api_key}/api/v1/upload-customer-signature'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add form data
      request.fields['johkasou_model_id'] = johkasouModelId;
      request.fields['response_master_id'] = responseMasterId;

      // Add signature file
      request.files.add(
        http.MultipartFile.fromBytes(
          'signature',
          signatureBytes,
          filename: 'signature.png',
        ),
      );

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      Navigator.of(context).pop(); // Close loading dialog

      if (response.statusCode == 200) {
        // Success
        _signatureController.clear();
        Navigator.of(context).pop(); // Close signature dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signature uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Error
        final errorData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload signature: ${errorData['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading signature: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maintenance Report", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: TizaraaColors.Tizara,
      ),
      body: Column(
        children: [
          // Search bar and filter dropdown
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          // Refresh the filtered data when search query changes
                          _maintenanceData = fetchMaintenanceData();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by project name',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Header
          SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0x0476BD).withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 40,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "SL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Project Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List of maintenance reports
          Expanded(
            child: FutureBuilder<List<MaintenanceResponse>>(
              future: _maintenanceData,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // No data state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No maintenance data available'),
                  );
                }

                // Filter data based on search and status
                List<MaintenanceResponse> displayData = snapshot.data!;
                displayData = displayData.where((item) {
                  bool matchesSearch = searchQuery.isEmpty ||
                      item.projectName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      item.userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      item.createdAt.split('T')[0].toLowerCase().contains(searchQuery.toLowerCase()) ||
                      item.groupName.toLowerCase().contains(searchQuery.toLowerCase());

                  return matchesSearch;
                }).toList();

                // Display filtered data
                if (displayData.isEmpty) {
                  return Center(
                    child: Text('No matching maintenance data found'),
                  );
                }

                // Data available state
                return ListView.builder(
                  itemCount: displayData.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemBuilder: (context, index) {
                    final report = displayData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: ExpansionTile(
                        key: Key(report.id),
                        onExpansionChanged: (isExpanded) {
                          setState(() {
                            expandedItems[index] = isExpanded;
                          });
                        },
                        collapsedBackgroundColor: TizaraaColors.primaryColor2,
                        backgroundColor: TizaraaColors.primaryColor.withOpacity(0.05),
                        leading: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: TizaraaColors.Tizara,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        title: Text(
                          report.projectName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.2,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                        subtitle: Text(
                          report.pj_code,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                          ),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: expandedItems[index] == true
                                ? TizaraaColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            expandedItems[index] == true ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            color: TizaraaColors.Tizara,
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: TizaraaColors.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoColumn(
                                  'Site Name  ',
                                  report.projectName,
                                  Icons.title,
                                ),
                                _buildInfoColumn(
                                  'Group Name  ',
                                  report.groupName,
                                  Icons.groups,
                                ),
                                _buildInfoColumn(
                                  'Remarks  ',
                                  report.remarks,
                                  Icons.edit,
                                ),
                                _buildInfoColumn(
                                  'Date  ',
                                  report.scheduleDate.split('T')[0],
                                  Icons.play_circle_outline,
                                ),

                                // Johkasou Models Section
                                if (report.johkasouModels.isNotEmpty) ...[
                                  SizedBox(height: 12),
                                  Text(
                                    "Johkasou Models",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: TizaraaColors.Tizara,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: TizaraaColors.primaryColor.withOpacity(0.3)),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: report.johkasouModels.length,
                                      separatorBuilder: (context, index) => Divider(height: 1),
                                      itemBuilder: (context, modelIndex) {
                                        final model = report.johkasouModels[modelIndex];
                                        return ListTile(
                                          leading: Icon(
                                            Icons.settings_applications,
                                            color: TizaraaColors.Tizara,
                                          ),
                                          title: Text(
                                            model.module,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Model ID: ${model.johkasouModelId}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: TizaraaColors.Tizara,
                                          ),
                                          onTap: () => _showJohkasouModelDetails(context, model, report.id),
                                        );
                                      },
                                    ),
                                  ),
                                ],

                                const Divider(
                                  color: Colors.grey,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Signature Button
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Show signature dialog for the first johkasou model
                                        if (report.johkasouModels.isNotEmpty) {
                                          _showSignatureDialog(context, report.id, report.johkasouModels.first.johkasouModelId);
                                        }
                                      },
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      label: Text(
                                        "Signature",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // View Report Button
                                    // ElevatedButton.icon(
                                    //   onPressed: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (context) => Inspector_MaintenanceDetailScreen(id: report.id),
                                    //       ),
                                    //     );
                                    //   },
                                    //   icon: Icon(Icons.info_outline, color: Colors.white),
                                    //   label: Text(
                                    //     "View Report",
                                    //     style: TextStyle(
                                    //       color: Colors.white,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontSize: 14,
                                    //       letterSpacing: 0.5,
                                    //     ),
                                    //   ),
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: const Color(0xFF0F4C81),
                                    //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(8),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

void _showJohkasouModelDetails(BuildContext context, JohkasouModel model, String maintenanceResponseId) {
  print('Navigating to Inspector_MaintenanceDetailScreen:');
  print('  Maintenance Response ID: $maintenanceResponseId');
  print('  Johkasou Model ID: ${model.johkasouModelId}');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Inspector_MaintenanceDetailScreen(
        id: maintenanceResponseId,
        johkasouModelId: model.johkasouModelId, // Use johkasouModelId instead of model.id
      ),
    ),
  );
}

Widget _buildInfoColumn(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Color(0xFF0F4C81)),
            SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}