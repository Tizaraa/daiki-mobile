import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';
import '../../../../Model/inspector_cardlist_details_model.dart';

class TicketService {
  static Future<TicketResponse> fetchTicketDetails(String ticketId) async {
    // Parse ticketId to int to ensure correct API URL format
    final int parsedTicketId = int.tryParse(ticketId) ?? 0;
    if (parsedTicketId == 0) {
      throw Exception('Invalid ticket ID format');
    }
    final url = Uri.parse('${DaikiAPI.api_key}/api/v1/tickets/$parsedTicketId');

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return TicketResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to load ticket data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ticket data: $e');
    }
  }
}

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> with SingleTickerProviderStateMixin {
  late Future<TicketResponse> _ticketFuture;
  String? _selectedCarStatus;
  late TextEditingController _commentController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _ticketFuture = TicketService.fetchTicketDetails(widget.ticketId);
    _selectedCarStatus = null;
    _commentController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  void _showAddCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddCommentSection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('CAR Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'CAR Info'),
            Tab(text: 'Project'),
            Tab(text: 'Models'),
            Tab(text: 'Comments'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        backgroundColor: Colors.purple[600],
        child: const Icon(Icons.comment, color: Colors.white),
      ),
      body: FutureBuilder<TicketResponse>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[500]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _ticketFuture = TicketService.fetchTicketDetails(widget.ticketId);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available', style: TextStyle(fontSize: 16)));
          }

          final ticketData = snapshot.data!.data;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTicketInfoTab(ticketData),
              _buildProjectDetailsTab(ticketData.project),
              _buildJohkasouModelsTab(ticketData.johkasouModelForTicket),
              _buildCommentsTab(ticketData.comments),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketInfoTab(TicketData ticketData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTicketHeader(ticketData),
          const SizedBox(height: 16),
          _buildTicketDetails(ticketData),
          const SizedBox(height: 16),
          _buildResponsibilitySection(ticketData.responsibilities),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(TicketData ticketData) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticketData.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ticketData.status == 'Completed' ? Colors.green[700] : Colors.orange[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticketData.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Code', ticketData.code),
              _buildInfoRow('CAR Serial', ticketData.carSerial ?? 'N/A'),
              _buildInfoRow('Priority', ticketData.priority,
                  color: ticketData.priority.toLowerCase() == 'high' ? Colors.red[600] : Colors.black54),
              _buildInfoRow('Issue Type', ticketData.typeOfIssue.typeOfIssue),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Created by',
                        style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticketData.submittedByUser.name,
                        style: TextStyle(fontSize: 16, color: Colors.blue[800], fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Created at',
                        style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatDateTime(ticketData.createdAt),
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketDetails(TicketData ticketData) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              ticketData.description ?? 'No description provided',
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoItem('Expected Date', formatDate(ticketData.expectedDate)),
                ),
                Expanded(
                  child: _buildInfoItem('Last Updated', formatDateTime(ticketData.updatedAt)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoItem('Received By', ticketData.receivedBy ?? 'N/A'),
            _buildInfoItem('Complaint Brief', ticketData.complaintBrief ?? 'N/A'),
            _buildInfoItem('Response Date', formatDate(ticketData.responseDate)),
            _buildInfoItem('Root Cause', ticketData.rootCause ?? 'N/A'),
            _buildInfoItem('Target Completion Date', formatDate(ticketData.targetCompletionDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsibilitySection(List<Responsibility> responsibilities) {
    if (responsibilities.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Responsibilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: responsibilities.length,
              itemBuilder: (context, index) {
                final responsibility = responsibilities[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', responsibility.responsibilityName),
                      _buildInfoRow('Email', responsibility.responsibilityEmail),
                      _buildInfoRow('Phone', responsibility.responsibilityPhone),
                      if (index < responsibilities.length - 1) const Divider(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: color ?? Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildProjectInfoRow('Project Name', project.projectName),
              _buildProjectInfoRow('Project Code', project.pjCode),
              _buildProjectInfoRow('Location', project.location),
              _buildProjectInfoRow('Capacity', project.capacity),
              _buildProjectInfoRow('Branch', project.branches.name),
              _buildProjectInfoRow('Project Type', project.projectType),
              _buildProjectInfoRow('Project Facilities', project.projectFacilities),
              _buildProjectInfoRow('Project Status', project.projectStatus),
              _buildProjectInfoRow('Maintenance Status', project.maintenanceStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJohkasouModelsTab(List<JohkasouModelForTicket> models) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Johkasou Models',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Text(
                    'Model: ${model.johkasouModel.module}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  subtitle: Text(
                    'Serial Number: ${model.johkasouModel.slNumber}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.settings, color: Colors.blue[800], size: 24),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(List<Comment> comments) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          comments.isEmpty
              ? const Text(
            'No comments yet',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.commentedBy.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blue[800]),
                          ),
                          Text(
                            formatDateTime(comment.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        comment.message,
                        style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                      ),
                      if (comment.file != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.attach_file, size: 18, color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              comment.file!,
                              style: TextStyle(fontSize: 14, color: Colors.blue[800], decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ],
                      if (comment.carStatus != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getCarStatusColor(comment.carStatus!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CAR Status: ${comment.carStatus}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCarStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[700]!;
      case 'completed':
        return Colors.green[700]!;
      case 'closed':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildAddCommentSection() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Comment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write your comment here...',
                hintStyle: const TextStyle(color: Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            const Text(
              'CAR Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCarStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text('Select CAR Status', style: TextStyle(color: Colors.black38)),
              items: const [
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                DropdownMenuItem(value: 'Closed', child: Text('Closed')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCarStatus = newValue;
                });
              },
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_commentController.text.isNotEmpty || _selectedCarStatus != null) {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(child: CircularProgressIndicator());
                        },
                      );

                      final token = await TokenManager.getToken();
                      if (token == null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to add a comment')),
                        );
                        return;
                      }

                      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/comments/create');

                      final Map<String, dynamic> requestBody = {
                        'ticket_id': int.tryParse(widget.ticketId) ?? 0,
                      };

                      if (_commentController.text.isNotEmpty) {
                        requestBody['message'] = _commentController.text;
                      }

                      if (_selectedCarStatus != null) {
                        requestBody['status'] = _selectedCarStatus;
                      }

                      if (requestBody['ticket_id'] == 0) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid ticket ID')),
                        );
                        return;
                      }

                      print('Sending request: ${json.encode(requestBody)}');

                      final response = await http.post(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                        body: json.encode(requestBody),
                      );

                      print('Response status: ${response.statusCode}');
                      print('Response body: ${response.body}');

                      Navigator.of(context).pop();

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment and CAR status updated successfully')),
                        );
                        _commentController.clear();
                        setState(() {
                          _selectedCarStatus = null;
                          _ticketFuture = TicketService.fetchTicketDetails(widget.ticketId);
                        });
                        Navigator.pop(context);
                      } else {
                        String errorMessage = 'Failed to add comment: ${response.statusCode}';
                        try {
                          final errorData = json.decode(response.body);
                          if (errorData['message'] != null) {
                            errorMessage = errorData['message'];
                          }
                        } catch (e) {}
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      }
                    } catch (e) {
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a comment or select CAR status')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

