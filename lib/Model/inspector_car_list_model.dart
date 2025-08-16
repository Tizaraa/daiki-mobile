import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../Core/Token-Manager/token_manager_screen.dart';
import '../Core/Utils/api_service.dart';

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
    final idValue = json['id'];
    int? parsedId;
    if (idValue != null) {
      if (idValue is int) {
        parsedId = idValue;
      } else if (idValue is String) {
        parsedId = int.tryParse(idValue);
        if (parsedId == null) {
          print('Warning: Could not parse ID "$idValue" as an integer');
        }
      } else {
        print('Warning: Unexpected ID type: ${idValue.runtimeType}');
      }
    }
    return JohkasouModel(
      id: parsedId,
      module: json['module'] ?? 'N/A',
      slNumber: json['sl_number'] ?? 'N/A',
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

class Ticket {
  final int id;
  final String? code;
  final String? title;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? expected_date; // Changed to match API
  final int? projectId;
  final String? projectName;
  final String? pjCode;
  final List<JohkasouModel>? johkasouModels;
  final String? assignedToName;
  final String? assignedByName;
  final String? imageUrl;
  final List<String>? imageUrls;
  // New fields
  final String? priority;
  final int? typeOfIssueId;
  final List<int>? responsibilityIds;
  final String? receivedBy;
  final String? complaintBrief;
  final String? responseDate;
  final String? rootCause;
  final String? targetCompletionDate;

  Ticket({
    required this.id,
    this.code,
    this.title,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.expected_date, // Changed to match API
    this.projectId,
    this.projectName,
    this.pjCode,
    this.johkasouModels,
    this.assignedToName,
    this.assignedByName,
    this.imageUrl,
    this.imageUrls,
    // New fields
    this.priority,
    this.typeOfIssueId,
    this.responsibilityIds,
    this.receivedBy,
    this.complaintBrief,
    this.responseDate,
    this.rootCause,
    this.targetCompletionDate,
  });

  Ticket copyWith({
    int? id,
    String? code,
    String? title,
    String? description,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? expected_date, // Changed to match API
    int? projectId,
    String? projectName,
    String? pjCode,
    List<JohkasouModel>? johkasouModels,
    String? assignedToName,
    String? assignedByName,
    String? imageUrl,
    List<String>? imageUrls,
    // New fields
    String? priority,
    int? typeOfIssueId,
    List<int>? responsibilityIds,
    String? receivedBy,
    String? complaintBrief,
    String? responseDate,
    String? rootCause,
    String? targetCompletionDate,
  }) {
    return Ticket(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expected_date: expected_date ?? this.expected_date, // Changed to match API
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      pjCode: pjCode ?? this.pjCode,
      johkasouModels: johkasouModels ?? this.johkasouModels,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedByName: assignedByName ?? this.assignedByName,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      // New fields
      priority: priority ?? this.priority,
      typeOfIssueId: typeOfIssueId ?? this.typeOfIssueId,
      responsibilityIds: responsibilityIds ?? this.responsibilityIds,
      receivedBy: receivedBy ?? this.receivedBy,
      complaintBrief: complaintBrief ?? this.complaintBrief,
      responseDate: responseDate ?? this.responseDate,
      rootCause: rootCause ?? this.rootCause,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'expected_date': expected_date, // Changed to match API
      'project_id': projectId,
      'project_name': projectName,
      'pj_code': pjCode,
      'johkasou_models': johkasouModels?.map((model) => model.toJson()).toList(),
      'assignedToName': assignedToName,
      'assignedByName': assignedByName,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      // New fields
      'priority': priority,
      'type_of_issue_id': typeOfIssueId,
      'responsibility_ids': responsibilityIds,
      'received_by': receivedBy,
      'complaint_brief': complaintBrief,
      'response_date': responseDate,
      'root_cause': rootCause,
      'target_completion_date': targetCompletionDate,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
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
    if (json['project'] != null) {
      projectName = json['project']['project_name'];
      pjCode = json['project']['pj_code'];
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
          .map<String>((file) => 'https://daiki-minio.tizaraa.shop/daiki/image/${file['file']}')
          .toList();
      if (imageUrls.isNotEmpty) {
        mainImageUrl = imageUrls.first;
      }
    }

    List<int>? responsibilityIds;
    if (json['responsibility_ids'] != null && json['responsibility_ids'] is List) {
      responsibilityIds = (json['responsibility_ids'] as List).map((e) => e as int).toList();
    }

    return Ticket(
      id: json['id'] ?? 0,
      code: json['code'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expected_date: json['expected_date'] ?? json['expectedDate'], // Prioritize expected_date
      projectId: json['project_id'],
      projectName: projectName,
      pjCode: pjCode,
      johkasouModels: johkasouModels,
      assignedToName: assignedToName,
      assignedByName: assignedByName,
      imageUrl: mainImageUrl,
      imageUrls: imageUrls,
      // New fields
      priority: json['priority'],
      typeOfIssueId: json['type_of_issue_id'],
      responsibilityIds: responsibilityIds,
      receivedBy: json['received_by'],
      complaintBrief: json['complaint_brief'],
      responseDate: json['response_date'],
      rootCause: json['root_cause'],
      targetCompletionDate: json['target_completion_date'],
    );
  }
}

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

  static Future<List<Ticket>> fetchTickets() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['data'] != null) {
          List<dynamic> ticketData = data['data']['data'];
          return ticketData.map((json) => Ticket.fromJson(json)).toList();
        }
        throw Exception('Invalid data format');
      } else {
        throw Exception('Failed to fetch tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tickets: $e');
    }
  }

  static Future<Ticket> updateTicket(Ticket ticket, {List<XFile> newFiles = const []}) async {
    final url = Uri.parse('$baseUrl/tickets/update');
    final token = await getToken();

    try {
      final johkasouModelIds = ticket.johkasouModels
          ?.where((model) => model.id != null)
          .map((model) => model.id!)
          .toList() ?? [];

      final responsibilityIds = ticket.responsibilityIds ?? [];

      if (newFiles.isNotEmpty) {
        var request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['id'] = ticket.id.toString();
        request.fields['project_id'] = ticket.projectId.toString();
        request.fields['title'] = ticket.title ?? "";
        request.fields['description'] = ticket.description ?? "";
        request.fields['status'] = ticket.status ?? "Pending";
        request.fields['priority'] = ticket.priority ?? "";
        request.fields['expected_date'] = ticket.expected_date ?? ""; // Changed to expected_date
        request.fields['type_of_issue_id'] = ticket.typeOfIssueId?.toString() ?? "";
        request.fields['received_by'] = ticket.receivedBy ?? "";
        request.fields['complaint_brief'] = ticket.complaintBrief ?? "";
        request.fields['response_date'] = ticket.responseDate ?? "";
        request.fields['root_cause'] = ticket.rootCause ?? "";
        request.fields['target_completion_date'] = ticket.targetCompletionDate ?? "";

        request.fields['johkasou_model_ids'] = jsonEncode(
            johkasouModelIds.map((id) => id.toString()).toList()
        );
        request.fields['responsibility_ids'] = jsonEncode(
            responsibilityIds.map((id) => id.toString()).toList()
        );

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

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          throw Exception('Failed to update ticket with files: ${response.statusCode} - ${response.body}');
        }

        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return Ticket.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format: No ticket data returned');
        }
      } else {
        Map<String, dynamic> requestBody = {
          "id": ticket.id,
          "project_id": ticket.projectId,
          "title": ticket.title ?? "",
          "description": ticket.description ?? "",
          "status": ticket.status ?? "Pending",
          "priority": ticket.priority ?? "",
          "expected_date": ticket.expected_date ?? "", // Changed to expected_date
          "type_of_issue_id": ticket.typeOfIssueId,
          "responsibility_ids": responsibilityIds,
          "received_by": ticket.receivedBy ?? "",
          "complaint_brief": ticket.complaintBrief ?? "",
          "response_date": ticket.responseDate ?? "",
          "root_cause": ticket.rootCause ?? "",
          "target_completion_date": ticket.targetCompletionDate ?? "",
          "johkasou_model_ids": johkasouModelIds.map((id) => id.toString()).toList(),
        };

        print('Sending request body: ${jsonEncode(requestBody)}');

        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update ticket: ${response.statusCode} - ${response.body}');
        }

        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return Ticket.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format: No ticket data returned');
        }
      }
    } catch (e) {
      throw Exception('Error updating ticket: $e');
    }
  }
}
