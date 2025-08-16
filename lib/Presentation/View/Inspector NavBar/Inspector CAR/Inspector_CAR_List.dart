import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';
import '../../Inspector HomePage/Inspector Create CAR/Inspector Car List Details.dart';
import '../../Inspector HomePage/Inspector Create CAR/Inspector_Create_CAR.dart';
import '../../Inspector HomePage/Inspector Project/Inspector_Project Details Screen.dart';
import 'Inspector_CAR_list_Edit.dart';

// --- JohkasouModel Class (from your provided code) ---

class JohkasouModel {
  final int? id;
  final String module;
  final String slNumber;

  JohkasouModel({
    this.id,
    required this.module,
    required this.slNumber,
  });

  factory JohkasouModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int from dynamic value
    int? _safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return JohkasouModel(
      id: _safeParseInt(json['id']), // Use safe parsing for ID
      module: json['module'] ?? '-',
      slNumber: json['sl_number'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'sl_number': slNumber,
    };
  }
}
// ------ branch class-------//

class Branch {
  final int id;
  final String name;
  Branch({
    required this.id,
    required this.name,

  });
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],

    );
  }
}


// --- Ticket Class (from your provided code, with minor adjustments for consistency) ---
class Ticket {
  final int id;
  final String? code;
  final String? title;
  final String? description;
  final String? status;
  final String? car_serial;
  final String? createdAt;
  final String? updatedAt;
  final String? expected_date;
  final int? projectId;
  final String? projectName;
  final String? pjCode;
  final List<JohkasouModel>? johkasouModels;
  final String? assignedToName;
  final String? assignedByName;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String? priority;
  final int? typeOfIssueId;
  final List<int>? responsibilityIds;
  final String? receivedBy;
  final String? complaintBrief;
  final String? responseDate;
  final String? rootCause;
  final String? targetCompletionDate;
  final String? branchName; // Added branchName field

  Ticket({
    required this.id,
    this.code,
    this.title,
    this.description,
    this.status,
    this.car_serial,
    this.createdAt,
    this.updatedAt,
    this.expected_date,
    this.projectId,
    this.projectName,
    this.pjCode,
    this.johkasouModels,
    this.assignedToName,
    this.assignedByName,
    this.imageUrl,
    this.imageUrls,
    this.priority,
    this.typeOfIssueId,
    this.responsibilityIds,
    this.receivedBy,
    this.complaintBrief,
    this.responseDate,
    this.rootCause,
    this.targetCompletionDate,
    this.branchName, // Initialize branchName
  });

  Ticket copyWith({
    int? id,
    String? code,
    String? title,
    String? description,
    String? status,
    String? car_serial,
    String? createdAt,
    String? updatedAt,
    String? expected_date,
    int? projectId,
    String? projectName,
    String? pjCode,
    List<JohkasouModel>? johkasouModels,
    String? assignedToName,
    String? assignedByName,
    String? imageUrl,
    List<String>? imageUrls,
    String? priority,
    int? typeOfIssueId,
    List<int>? responsibilityIds,
    String? receivedBy,
    String? complaintBrief,
    String? responseDate,
    String? rootCause,
    String? targetCompletionDate,
    String? branchName, // Add to copyWith
  }) {
    return Ticket(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      car_serial: car_serial ?? this.car_serial,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expected_date: expected_date ?? this.expected_date,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      pjCode: pjCode ?? this.pjCode,
      johkasouModels: johkasouModels ?? this.johkasouModels,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedByName: assignedByName ?? this.assignedByName,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      priority: priority ?? this.priority,
      typeOfIssueId: typeOfIssueId ?? this.typeOfIssueId,
      responsibilityIds: responsibilityIds ?? this.responsibilityIds,
      receivedBy: receivedBy ?? this.receivedBy,
      complaintBrief: complaintBrief ?? this.complaintBrief,
      responseDate: responseDate ?? this.responseDate,
      rootCause: rootCause ?? this.rootCause,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      branchName: branchName ?? this.branchName, // Include in copyWith
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'status': status,
      'car_serial': car_serial,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'expected_date': expected_date,
      'project_id': projectId,
      'project_name': projectName,
      'pj_code': pjCode,
      'johkasou_models': johkasouModels?.map((model) => model.toJson()).toList(),
      'assignedToName': assignedToName,
      'assignedByName': assignedByName,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'priority': priority,
      'type_of_issue_id': typeOfIssueId,
      'responsibility_ids': responsibilityIds,
      'received_by': receivedBy,
      'complaint_brief': complaintBrief,
      'response_date': responseDate,
      'root_cause': rootCause,
      'target_completion_date': targetCompletionDate,
      'branch_name': branchName, // Include in toJson
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    int? _safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    String? assignedToName;
    String? assignedByName;
    if (json['assigned'] != null) {
      if (json['assigned']['assigned_to'] != null) {
        assignedToName = json['assigned']['assigned_to']['name'];
      }
      if (json['assigned']['assigned_by'] != null) {
        assignedByName = json['assigned']['assigned_by']['name'];
      }
    }

    String? projectName;
    String? pjCode;
    String? branchName; // Parse branch name
    if (json['project'] != null) {
      projectName = json['project']['project_name'];
      pjCode = json['project']['pj_code'];
      // Assuming the branch name is nested under project -> branches -> name
      if (json['project']['branches'] != null && json['project']['branches']['name'] != null) {
        branchName = json['project']['branches']['name'];
      }
    }

    List<JohkasouModel>? johkasouModels;
    if (json['johkasou_model_for_ticket'] != null &&
        json['johkasou_model_for_ticket'] is List &&
        json['johkasou_model_for_ticket'].isNotEmpty) {
      johkasouModels = (json['johkasou_model_for_ticket'] as List)
          .map((model) => JohkasouModel.fromJson(model['johkasou_model']))
          .toList();
    }

    List<String>? imageUrls;
    String? mainImageUrl;
    if (json['files'] != null && json['files'] is List && json['files'].isNotEmpty) {
      imageUrls = (json['files'] as List)
          .where((file) => file['file'] != null)
          .map<String>((file) => '${ImageAPI.test_img_key}/daiki/image/${file['file']}')
          .toList();
      if (imageUrls.isNotEmpty) {
        mainImageUrl = imageUrls.first;
      }
    }

    List<int>? responsibilityIds;
    if (json['responsibility_ids'] != null && json['responsibility_ids'] is List) {
      responsibilityIds = (json['responsibility_ids'] as List)
          .map((e) => _safeParseInt(e))
          .whereType<int>()
          .toList();
    }

    return Ticket(
      id: _safeParseInt(json['id']) ?? 0,
      code: json['code'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      car_serial: json['car_serial'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expected_date: json['expected_date'] ?? json['expectedDate'],
      projectId: _safeParseInt(json['project_id']),
      projectName: projectName,
      pjCode: pjCode,
      johkasouModels: johkasouModels,
      assignedToName: assignedToName,
      assignedByName: assignedByName,
      imageUrl: mainImageUrl,
      imageUrls: imageUrls,
      priority: json['priority'],
      typeOfIssueId: _safeParseInt(json['type_of_issue_id']),
      responsibilityIds: responsibilityIds,
      receivedBy: json['received_by'],
      complaintBrief: json['complaint_brief'],
      responseDate: json['response_date'],
      rootCause: json['root_cause'],
      targetCompletionDate: json['target_completion_date'],
      branchName: branchName, // Initialize branchName
    );
  }
}

// --- TicketApiService Class (Updated for correct multipart array handling and date formatting) ---

class TicketApiService {
  static const String baseUrl = '${DaikiAPI.api_key}/api/v1';

  static Future<String?> getToken() async {
    return await TokenManager.getToken();
  }

  static Future<Map<String, String>> getHeaders() async {
    String? token = await getToken();
    if (token == null) throw Exception('No auth token found');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Updated method to fetch all tickets with pagination
  static Future<List<Ticket>> fetchTickets() async {
    try {
      final headers = await getHeaders();
      List<Ticket> allTickets = [];
      int currentPage = 1;
      bool hasMorePages = true;

      while (hasMorePages) {
        print('Fetching page $currentPage...');

        final response = await http.get(
          Uri.parse('$baseUrl/tickets?page=$currentPage'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['data'] != null && data['data']['data'] != null) {
            List<dynamic> ticketData = data['data']['data'];

            // Convert tickets from current page
            List<Ticket> currentPageTickets = ticketData.map((json) => Ticket.fromJson(json)).toList();
            allTickets.addAll(currentPageTickets);

            // Check pagination info
            final paginationInfo = data['data'];
            final int? currentPageNum = paginationInfo['current_page'];
            final int? lastPage = paginationInfo['last_page'];
            final int? total = paginationInfo['total'];
            final int? perPage = paginationInfo['per_page'];

            print('Page $currentPage: Got ${currentPageTickets.length} tickets');
            print('Total tickets so far: ${allTickets.length}');
            print('Pagination info - Current: $currentPageNum, Last: $lastPage, Total: $total, Per Page: $perPage');

            // Check if there are more pages
            if (lastPage != null && currentPageNum != null) {
              hasMorePages = currentPageNum < lastPage;
            } else {
              // Fallback: if no pagination info, check if current page returned data
              hasMorePages = currentPageTickets.isNotEmpty;
              // But limit to prevent infinite loop
              if (currentPage > 100) hasMorePages = false;
            }

            currentPage++;
          } else {
            print('No data found on page $currentPage');
            hasMorePages = false;
          }
        } else {
          print('Failed to fetch tickets page $currentPage: ${response.statusCode} - ${response.body}');
          throw Exception('Failed to fetch tickets page $currentPage: ${response.statusCode}');
        }

        // Add a small delay to avoid overwhelming the server
        await Future.delayed(Duration(milliseconds: 100));
      }

      print('Total tickets fetched: ${allTickets.length}');
      return allTickets;

    } catch (e) {
      print('Error fetching tickets: $e');
      throw Exception('Error fetching tickets: $e');
    }
  }

  // Alternative method to fetch tickets with a high per_page limit (if API supports it)
  static Future<List<Ticket>> fetchTicketsWithLargeLimit() async {
    try {
      final headers = await getHeaders();

      // Try to fetch with a very high per_page limit
      final response = await http.get(
        Uri.parse('$baseUrl/tickets?per_page=1000'), // Adjust this number based on your API's maximum
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['data'] != null) {
          List<dynamic> ticketData = data['data']['data'];
          List<Ticket> tickets = ticketData.map((json) => Ticket.fromJson(json)).toList();

          final paginationInfo = data['data'];
          final int? total = paginationInfo['total'];
          final int? currentCount = tickets.length;

          print('Fetched $currentCount tickets out of $total total tickets');

          // If we didn't get all tickets, fall back to pagination method
          if (total != null && currentCount != null && currentCount < total) {
            print('Not all tickets fetched with large limit, falling back to pagination...');
            return await fetchTickets();
          }

          return tickets;
        }
        throw Exception('Invalid data format: ${response.body}');
      } else {
        print('Failed to fetch tickets with large limit: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tickets with large limit, trying pagination: $e');
      // Fall back to pagination method
      return await fetchTickets();
    }
  }

  // Keep the existing updateTicket method unchanged
  static Future<Ticket> updateTicket(Ticket ticket, {List<XFile> newFiles = const []}) async {
    final url = Uri.parse('$baseUrl/tickets/update');
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final johkasouModelIds = ticket.johkasouModels
          ?.where((model) => model.id != null)
          .map((model) => model.id!)
          .toList() ?? [];
      final responsibilityIds = ticket.responsibilityIds ?? [];

      // Helper to format dates to YYYY-MM-DD
      String formatDateForApi(String? dateString) {
        if (dateString == null || dateString.isEmpty) return '';
        try {
          // Assuming dateString might be YYYY-MM-DD HH:mm:ss or YYYY-MM-DD
          final DateTime date = DateTime.parse(dateString);
          return DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print('Error formatting date "$dateString": $e');
          return ''; // Return empty string on error
        }
      }

      if (newFiles.isNotEmpty) {
        // Case 1: Update with new files (multipart/form-data)
        var request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';

        // Add all fields as string
        request.fields['id'] = ticket.id.toString();
        request.fields['project_id'] = ticket.projectId?.toString() ?? "";
        request.fields['title'] = ticket.title ?? "";
        request.fields['description'] = ticket.description ?? "";
        request.fields['status'] = ticket.status ?? "Pending";
        request.fields['car_serial'] = ticket.status?? "";
        request.fields['priority'] = ticket.priority ?? "";
        request.fields['expected_date'] = formatDateForApi(ticket.expected_date);
        request.fields['type_of_issue_id'] = ticket.typeOfIssueId?.toString() ?? "";
        request.fields['received_by'] = ticket.receivedBy ?? "";
        request.fields['complaint_brief'] = ticket.complaintBrief ?? "";
        request.fields['response_date'] = formatDateForApi(ticket.responseDate);
        request.fields['root_cause'] = ticket.rootCause ?? "";
        request.fields['target_completion_date'] = formatDateForApi(ticket.targetCompletionDate);

        // Corrected: Add array fields as multiple entries with '[]' suffix for multipart
        for (var id in johkasouModelIds) {
          request.fields['johkasou_model_ids[]'] = id.toString();
        }
        for (var id in responsibilityIds) {
          request.fields['responsibility_ids[]'] = id.toString();
        }

        // Add files
        for (var file in newFiles) {
          final fileObj = File(file.path);
          final fileName = path.basename(fileObj.path);
          final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';
          final multipartFile = await http.MultipartFile.fromPath(
            'file[]',
            fileObj.path,
            contentType: MediaType.parse(mimeType),
            filename: fileName,
          );
          request.files.add(multipartFile);
        }

        print('Sending Multipart request to: $url');
        print('Multipart fields: ${request.fields}');
        print('Multipart files: ${request.files.map((f) => f.filename).toList()}');

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}'); // <-- CRUCIAL FOR DEBUGGING

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = json.decode(response.body);
          if (responseData['data'] != null) {
            return Ticket.fromJson(responseData['data']);
          } else {
            throw Exception('Invalid response format: No ticket data returned in multipart update');
          }
        } else {
          print('Multipart Update Error: ${response.statusCode} - ${response.body}');
          throw Exception('Failed to update ticket with files: ${response.statusCode} - ${response.body}');
        }
      } else {
        // Case 2: Update without new files (application/json)
        Map<String, dynamic> requestBody = {
          "id": ticket.id,
          "project_id": ticket.projectId,
          "title": ticket.title ?? "",
          "description": ticket.description ?? "",
          "status": ticket.status ?? "Pending",
          "car_serial": ticket.car_serial?? "",
          "priority": ticket.priority ?? "",
          "expected_date": formatDateForApi(ticket.expected_date),
          "type_of_issue_id": ticket.typeOfIssueId,
          "responsibility_ids": responsibilityIds, // Send as List<int>
          "received_by": ticket.receivedBy ?? "",
          "complaint_brief": ticket.complaintBrief ?? "",
          "response_date": formatDateForApi(ticket.responseDate),
          "root_cause": ticket.rootCause ?? "",
          "target_completion_date": formatDateForApi(ticket.targetCompletionDate),
          // Send johkasou_model_ids as List<int> directly for JSON body
          "johkasou_model_ids": johkasouModelIds,
        };

        print('Sending JSON request body to: $url');
        print('JSON request body: ${jsonEncode(requestBody)}');

        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}'); // <-- CRUCIAL FOR DEBUGGING

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = json.decode(response.body);
          if (responseData['data'] != null) {
            return Ticket.fromJson(responseData['data']);
          } else {
            throw Exception('Invalid response format: No ticket data returned in JSON update');
          }
        } else {
          print('JSON Update Error: ${response.statusCode} - ${response.body}');
          throw Exception('Failed to update ticket: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error updating ticket: $e');
    }
  }
}

// --- TicketsScreen Class (Updated with data fetching for edit dialog and improved dialog logic) ---
class TicketsScreen extends StatefulWidget {
  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  bool _isLoading = false;
  List<Ticket> _tickets = [];
  List<Ticket> _filteredTickets = [];
  Map<int, bool> _visibilityMap = {};
  String? _selectedStatusFilter;
  TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _typeOfIssues = []; // Fetched from API
  List<Map<String, dynamic>> _responsibilities = []; // Fetched from API

  final List<String> _statusOptions = [
    'Open',
    'Pending',
    'Closed',
    'Completed',
  ];
  final List<String> _priorityOptions = ['Low', 'Medium', 'High',];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await _fetchTypeOfIssues();
      await _fetchResponsibilities();
      await _loadTickets();
    } catch (e) {
      _showErrorMessage("Failed to load initial data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTypeOfIssues() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception("Token not found!");
      }
      final response = await http.get(
        Uri.parse("${DaikiAPI.api_key}/api/v1/type-of-issues"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List issueList = data['data']['typeOfIssueGet'];
        setState(() {
          _typeOfIssues = issueList.map<Map<String, dynamic>>((issue) {
            return {
              "id": issue["id"],
              "type_of_issue": issue["type_of_issue"]?.toString() ?? "-",
            };
          }).toList();
        });
        print('Type of Issues fetched successfully: ${_typeOfIssues.length} items');
      } else {
        throw Exception("Failed to load type of issues. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching type of issues: $e");
    }
  }

  Future<void> _fetchResponsibilities() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception("Token not found!");
      }
      final response = await http.get(
        Uri.parse("${DaikiAPI.api_key}/api/v1/tickets/responsibilities"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> responsibilityGroups = data['data'];
        List<Map<String, dynamic>> flattenedResponsibilities = [];
        for (var group in responsibilityGroups) {
          String typeName = group['type_name'] ?? 'Unknown Type';
          List<dynamic> responsiblePersons = group['responsibile_person'] ?? [];
          for (var person in responsiblePersons) {
            flattenedResponsibilities.add({
              "id": person["id"],
              "name": person["name"]?.toString() ?? "-",
              "type_name": typeName, // Add type_name for display in the picker
            });
          }
        }
        setState(() {
          _responsibilities = flattenedResponsibilities;
        });
        print('Responsibilities fetched successfully: ${_responsibilities.length} items');
      } else {
        throw Exception("Failed to load responsibilities. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching responsibilities: $e");
    }
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await TicketApiService.fetchTickets();
      setState(() {
        _tickets = tickets;
        _filteredTickets = List.from(tickets);
        _visibilityMap = {for (var ticket in tickets) ticket.id: false};
      });
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchTickets(String query) {
    setState(() {
      _filteredTickets = _tickets.where((ticket) {
        final matchesQuery =
            (ticket.code?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (ticket.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (ticket.projectName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (ticket.pjCode?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (ticket.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        final matchesStatus = _selectedStatusFilter == null || ticket.status == _selectedStatusFilter;
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }


  void _toggleVisibility(int ticketId) {
    setState(() {
      _visibilityMap[ticketId] = !(_visibilityMap[ticketId] ?? false);
    });
  }


  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // String _getIssueTypeName(int? id) {
  //   if (id == null) return '-';
  //   return _typeOfIssues.firstWhere(
  //         (element) => element['id'] == id,
  //     orElse: () => {'type_of_issue': 'Unknown'},
  //   )['type_of_issue'];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('CAR List', style: TextStyle(color: Colors.white)),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by code,title',
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                _searchController.clear();
                                _searchTickets('');
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: _searchTickets,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatusFilter,
                        hint: Text('Status', style: TextStyle(color: Colors.grey[600])),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All'),
                          ),
                          ..._statusOptions.map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          )).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatusFilter = value;
                            _searchTickets(_searchController.text);
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: TizaraaColors.Tizara,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 40,
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "SL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: Colors.white),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Project",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: TizaraaColors.Tizara))
                : _filteredTickets.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No tickets found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadTickets,
              color: TizaraaColors.Tizara,
              child: ListView.builder(
                itemCount: _filteredTickets.length,
                padding: EdgeInsets.symmetric(horizontal: 9),
                itemBuilder: (context, index) {
                  final ticket = _filteredTickets[index];
                  final isVisible = _visibilityMap[ticket.id] ?? false;
                  final serialNumber = (index + 1).toString().padLeft(2, '0');
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    child: Card(
                      child: InkWell(
                        onTap: () => _toggleVisibility(ticket.id),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [TizaraaColors.primaryColor2, TizaraaColors.primaryColor2],
                              begin: Alignment.topLeft,
                              end: Alignment.center,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Center(
                                      child: Text(
                                        serialNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: TizaraaColors.Tizara,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ticket.projectName ?? '-',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            ticket.pjCode ?? '-',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isVisible ? 0.5 : 0,
                                      duration: Duration(milliseconds: 200),
                                      child: Icon(
                                        isVisible ? Icons.visibility_off : Icons.remove_red_eye,
                                        color: TizaraaColors.Tizara,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isVisible)
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTicketImages(ticket),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: TizaraaColors.primaryColor2.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: MaterialButton(
                                          color: TizaraaColors.Tizara,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TicketDetailScreen(ticketId: ticket.id.toString()),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.code, color: Colors.white, size: 18),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Type of Issue',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),

                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: TizaraaColors.primaryColor2.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: MaterialButton(
                                          color: TizaraaColors.Tizara,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => InspectorProjectDetailScreen(projectId: ticket.projectId!),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.build_circle, color: Colors.white, size: 18),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Project Name',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      ticket.projectName ?? '-',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.9),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),

                                      _buildListTile(
                                        icon: Icons.title,
                                        title: 'Title',
                                        subtitle: ticket.title ?? '-',
                                      ),
                                      _buildListTile(
                                        icon: Icons.title,
                                        title: 'Site Name',
                                        subtitle: ticket.branchName ?? '-',
                                      ),
                                      _buildListTile(
                                        icon: Icons.description,
                                        title: 'Description',
                                        subtitle: ticket.description ?? '-',
                                      ),
                                      _buildListTile(
                                        icon: Icons.info,
                                        title: 'Status',
                                        subtitleWidget: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(ticket.status),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            ticket.status ?? '-',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      _buildListTile(
                                        icon: Icons.person_outline,
                                        title: 'CAR Serial',
                                        subtitle: ticket.car_serial ?? '-',
                                      ),
                                      _buildListTile(
                                        icon: Icons.person_outline,
                                        title: 'Received By',
                                        subtitle: ticket.receivedBy ?? '-',
                                      ),
                                      _buildListTile(
                                        icon: Icons.calendar_today,
                                        title: 'Created Date',
                                        subtitle: _formatDate(ticket.createdAt),
                                      ),
                                      _buildListTile(
                                        icon: Icons.event,
                                        title: 'Expected Date',
                                        subtitle: _formatDate(ticket.expected_date),
                                      ),
                                      _buildListTile(
                                        icon: Icons.date_range,
                                        title: 'Response Date',
                                        subtitle: _formatDate(ticket.responseDate),
                                      ),
                                      _buildListTile(
                                        icon: Icons.healing,
                                        title: 'Root Cause',
                                        subtitle: ticket.rootCause ?? '-',
                                      ),
                                      _buildListTile(
                                        icon: Icons.check_circle_outline,
                                        title: 'Target Completion Date',
                                        subtitle: _formatDate(ticket.targetCompletionDate),
                                      ),
                                      _buildListTile(
                                        icon: Icons.person,
                                        title: 'Assigned To',
                                        subtitle: ticket.assignedToName ?? '-',
                                      ),

                                      // _buildListTile(
                                      //   icon: Icons.person,
                                      //   title: 'Assigned By',
                                      //   subtitle: ticket.assignedByName ?? '-',
                                      // ),

                                      Container(
                                        margin: EdgeInsets.only(top: 16, bottom: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: TizaraaColors.Tizara.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: TizaraaColors.Tizara.withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          'Johkasou Models',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: TizaraaColors.Tizara,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (ticket.johkasouModels != null && ticket.johkasouModels!.isNotEmpty)
                                        ...ticket.johkasouModels!.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final model = entry.value;
                                          return _buildListTile(
                                            icon: Icons.build,
                                            title: 'Model ${index + 1}',
                                            subtitle: '${model.module} (${model.slNumber})',
                                          );
                                        }).toList()
                                      else
                                        _buildListTile(
                                          icon: Icons.build,
                                          title: 'Johkasou Models',
                                          subtitle: '-',
                                        ),


                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0, right: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [


                                            MaterialButton( onPressed: () {
                                              // Navigate to edit screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => InspectorEditCAR(ticketId: ticket.id),
                                                ),
                                              );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => InspectorEditCAR(
                                                    ticketId: ticket.id,
                                                  ),
                                                ),
                                              );

                                            },
                                                color: Colors.blue, // <-- Background color
                                                textColor: Colors.white, // Optional: sets text color
                                                child: Text("Edit CAR"))


                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InspectorCreateCAR()),
          );
        },
        label: Text("Create CAR", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 6,
      ),
    );
  }

  Widget _buildTicketImages(Ticket ticket) {
    if (ticket.imageUrls == null || ticket.imageUrls!.isEmpty) {
      return SizedBox.shrink();
    }
    if (ticket.imageUrls!.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            ticket.imageUrls!.first,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    color: TizaraaColors.Tizara,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      ticket.imageUrls!.first,
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 200,
        margin: EdgeInsets.only(bottom: 16.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ticket.imageUrls!.length,
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              margin: EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ticket.imageUrls![index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: TizaraaColors.Tizara,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Image Error',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: TizaraaColors.Tizara.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TizaraaColors.Tizara, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  subtitleWidget ??
                      Text(
                        subtitle ?? '-',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Closed':
        return Colors.purple;
      case 'Pending':
        return Colors.amber[700]!;
      default:
        return Colors.grey;
    }
  }
}