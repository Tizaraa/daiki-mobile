import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart'as http;

import '../Core/Token-Manager/token_manager_screen.dart';

// Ticket class (used in the calling context)
class Ticket {
  final int id;
  final String? title;
  final String? code;
  final String? description;
  final String? status;
  final String? projectName;
  final String? pjCode;
  final String? expectedDate;
  final List<JohkasouModel>? johkasouModels;
  final String? projectId;
  final String? priority;
  final String? typeOfIssueId;
  final List<String>? responsibilityIds;
  final String? receivedBy;
  final String? complaintBrief;
  final String? responseDate;
  final String? rootCause;
  final String? targetCompletionDate;

  Ticket({
    required this.id,
    this.title,
    this.code,
    this.description,
    this.status,
    this.projectName,
    this.pjCode,
    this.expectedDate,
    this.johkasouModels,
    this.projectId,
    this.priority,
    this.typeOfIssueId,
    this.responsibilityIds,
    this.receivedBy,
    this.complaintBrief,
    this.responseDate,
    this.rootCause,
    this.targetCompletionDate,
  });

  EditTicket toEditTicket() {
    return EditTicket(
      id: id.toString(),
      title: title,
      code: code,
      description: description,
      status: status,
      projectName: projectName,
      pjCode: pjCode,
      expectedDate: expectedDate,
      johkasouModels: johkasouModels?.map((m) => EditJohkasouModel(id: m.id, module: m.module, slNumber: m.slNumber)).toList(),
      projectId: projectId,
      priority: priority,
      typeOfIssueId: typeOfIssueId,
      responsibilityIds: responsibilityIds,
      receivedBy: receivedBy,
      complaintBrief: complaintBrief,
      responseDate: responseDate,
      rootCause: rootCause,
      targetCompletionDate: targetCompletionDate,
    );
  }
}

class JohkasouModel {
  final String? id;
  final String module;
  final String slNumber;

  JohkasouModel({this.id, required this.module, required this.slNumber});
}

class EditJohkasouModel {
  final String? id;
  final String module;
  final String slNumber;

  EditJohkasouModel({this.id, required this.module, required this.slNumber});
}

class EditTicket {
  final String id;
  final String? title;
  final String? code;
  final String? description;
  final String? status;
  final String? projectName;
  final String? pjCode;
  final String? expectedDate;
  final List<EditJohkasouModel>? johkasouModels;
  final String? projectId;
  final String? priority;
  final String? typeOfIssueId;
  final List<String>? responsibilityIds;
  final String? receivedBy;
  final String? complaintBrief;
  final String? responseDate;
  final String? rootCause;
  final String? targetCompletionDate;

  EditTicket({
    required this.id,
    this.title,
    this.code,
    this.description,
    this.status,
    this.projectName,
    this.pjCode,
    this.expectedDate,
    this.johkasouModels,
    this.projectId,
    this.priority,
    this.typeOfIssueId,
    this.responsibilityIds,
    this.receivedBy,
    this.complaintBrief,
    this.responseDate,
    this.rootCause,
    this.targetCompletionDate,
  });

  EditTicket copyWith({
    String? title,
    String? code,
    String? description,
    String? status,
    String? projectName,
    String? pjCode,
    String? expectedDate,
    List<EditJohkasouModel>? johkasouModels,
    String? projectId,
    String? priority,
    String? typeOfIssueId,
    List<String>? responsibilityIds,
    String? receivedBy,
    String? complaintBrief,
    String? responseDate,
    String? rootCause,
    String? targetCompletionDate,
  }) {
    return EditTicket(
      id: this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      description: description ?? this.description,
      status: status ?? this.status,
      projectName: projectName ?? this.projectName,
      pjCode: pjCode ?? this.pjCode,
      expectedDate: expectedDate ?? this.expectedDate,
      johkasouModels: johkasouModels ?? this.johkasouModels,
      projectId: projectId ?? this.projectId,
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
}

class EditTicketApiService {
  static Future<EditTicket> updateTicket(EditTicket ticket, {List<XFile>? newFiles}) async {
    String? token = await TokenManager.getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://uat-backend.tizaraa.shop/api/v1/tickets/${ticket.id}"),
    );

    request.headers.addAll({"Authorization": "Bearer $token"});

    request.fields['project_id'] = ticket.projectId ?? '';
    request.fields['title'] = ticket.title ?? '';
    request.fields['expected_date'] = ticket.expectedDate ?? '';
    request.fields['description'] = ticket.description ?? '';
    request.fields['status'] = ticket.status ?? 'open';
    request.fields['type_of_issue_id'] = ticket.typeOfIssueId ?? '';
    request.fields['priority'] = ticket.priority ?? 'Medium';
    request.fields['complaint_brief'] = ticket.complaintBrief ?? '';
    request.fields['response_date'] = ticket.responseDate ?? '';
    request.fields['root_cause'] = ticket.rootCause ?? '';
    request.fields['target_completion_date'] = ticket.targetCompletionDate ?? '';
    request.fields['received_by'] = ticket.receivedBy ?? '';

    if (ticket.johkasouModels != null && ticket.johkasouModels!.isNotEmpty) {
      for (int i = 0; i < ticket.johkasouModels!.length; i++) {
        request.fields['johkasou_model_ids[$i]'] = ticket.johkasouModels![i].id ?? '';
      }
    } else {
      request.fields['johkasou_model_ids'] = '[]';
    }

    if (ticket.responsibilityIds != null && ticket.responsibilityIds!.isNotEmpty) {
      for (int i = 0; i < ticket.responsibilityIds!.length; i++) {
        request.fields['responsibility_ids[$i]'] = ticket.responsibilityIds![i];
      }
    } else {
      request.fields['responsibility_ids'] = '[]';
    }

    if (newFiles != null && newFiles.isNotEmpty) {
      for (int i = 0; i < newFiles.length; i++) {
        var stream = http.ByteStream(newFiles[i].openRead());
        var length = await newFiles[i].length();
        request.files.add(http.MultipartFile('file[]', stream, length, filename: "inspection_image_$i.jpg"));
      }
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var jsonResponse = jsonDecode(responseBody);
      return EditTicket(
        id: ticket.id,
        title: jsonResponse['data']['title'],
        code: jsonResponse['data']['code'],
        description: jsonResponse['data']['description'],
        status: jsonResponse['data']['status'],
        projectName: jsonResponse['data']['project_name'],
        pjCode: jsonResponse['data']['pj_code'],
        expectedDate: jsonResponse['data']['expected_date'],
        johkasouModels: (jsonResponse['data']['johkasou_models'] as List<dynamic>?)
            ?.map((m) => EditJohkasouModel(id: m['id'].toString(), module: m['module'], slNumber: m['sl_number']))
            .toList(),
        projectId: jsonResponse['data']['project_id']?.toString(),
        priority: jsonResponse['data']['priority'],
        typeOfIssueId: jsonResponse['data']['type_of_issue_id']?.toString(),
        responsibilityIds: (jsonResponse['data']['responsibility_ids'] as List<dynamic>?)?.cast<String>(),
        receivedBy: jsonResponse['data']['received_by']?.toString(),
        complaintBrief: jsonResponse['data']['complaint_brief'],
        responseDate: jsonResponse['data']['response_date'],
        rootCause: jsonResponse['data']['root_cause'],
        targetCompletionDate: jsonResponse['data']['target_completion_date'],
      );
    } else {
      throw Exception("Failed to update ticket: $responseBody");
    }
  }
}