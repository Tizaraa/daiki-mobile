import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';

// JohkasouModel Class
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
    int? _safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return JohkasouModel(
      id: _safeParseInt(json['id']),
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

// Ticket Class
class Ticket {
  final int id;
  final String? code;
  final String? title;
  final String? description;
  final String? status;
  final String? carSerial;
  final String? createdAt;
  final String? updatedAt;
  final String? expectedDate;
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

  Ticket({
    required this.id,
    this.code,
    this.title,
    this.description,
    this.status,
    this.carSerial,
    this.createdAt,
    this.updatedAt,
    this.expectedDate,
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
  });

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
      carSerial: json['car_serial'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expectedDate: json['expected_date'] ?? json['expectedDate'],
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
    );
  }
}

class InspectorEditCAR extends StatefulWidget {
  final int ticketId;
  final Ticket? existingTicket;

  const InspectorEditCAR({
    super.key,
    required this.ticketId,
    this.existingTicket,
  });

  @override
  _InspectorEditCARState createState() => _InspectorEditCARState();
}

class _InspectorEditCARState extends State<InspectorEditCAR> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> typeOfIssues = [];
  List<Map<String, dynamic>> responsibilities = [];
  bool isLoading = true;
  String errorMessage = '';

  // Current ticket data
  Ticket? currentTicket;

  Map<String, dynamic>? selectedProject;
  String? selectedTypeOfIssue;
  List<String> selectedJohkasouModels = [];
  List<String> selectedResponsibilityIds = [];
  DateTime? selectedExpectedDate;
  DateTime? selectedResponseDate;
  DateTime? selectedTargetCompletionDate;
  List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController newIssueController = TextEditingController();
  final TextEditingController complaintBriefController = TextEditingController();
  final TextEditingController rootCauseController = TextEditingController();
  final TextEditingController carSerialController = TextEditingController();
  final TextEditingController projectSearchController = TextEditingController();
  final TextEditingController johkasouModelsDisplayController = TextEditingController();
  final TextEditingController expectedDateController = TextEditingController();
  final TextEditingController responseDateController = TextEditingController();
  final TextEditingController targetCompletionDateController = TextEditingController();
  final TextEditingController responsibilityDisplayController = TextEditingController();
  final TextEditingController receivedByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      await fetchProjects();
      await fetchTypeOfIssues();
      await fetchResponsibilities();

      if (widget.existingTicket != null) {
        _populateFormWithTicket(widget.existingTicket!);
      } else {
        await _fetchTicketDetails();
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTicketDetails() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception("Token not found!");

      final response = await http.get(
        Uri.parse("${DaikiAPI.api_key}/api/v1/tickets/${widget.ticketId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ticket = Ticket.fromJson(data['data']);
        setState(() {
          currentTicket = ticket;
        });
        _populateFormWithTicket(ticket);
      } else {
        throw Exception("Failed to load ticket details. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching ticket details: $e");
    }
  }

  void _populateFormWithTicket(Ticket ticket) {
    setState(() {
      currentTicket = ticket;

      // Populate basic fields
      titleController.text = ticket.title ?? '';
      descriptionController.text = ticket.description ?? '';
      complaintBriefController.text = ticket.complaintBrief ?? '';
      rootCauseController.text = ticket.rootCause ?? '';
      carSerialController.text = ticket.carSerial ?? '';
      receivedByController.text = ticket.receivedBy ?? '';

      // Set dates
      if (ticket.expectedDate != null) {
        selectedExpectedDate = DateTime.tryParse(ticket.expectedDate!);
        expectedDateController.text = selectedExpectedDate?.toLocal().toIso8601String().split('T')[0] ?? '';
      }

      if (ticket.responseDate != null) {
        selectedResponseDate = DateTime.tryParse(ticket.responseDate!);
        responseDateController.text = selectedResponseDate?.toLocal().toIso8601String().split('T')[0] ?? '';
      }

      if (ticket.targetCompletionDate != null) {
        selectedTargetCompletionDate = DateTime.tryParse(ticket.targetCompletionDate!);
        targetCompletionDateController.text = selectedTargetCompletionDate?.toLocal().toIso8601String().split('T')[0] ?? '';
      }

      // Set type of issue
      selectedTypeOfIssue = ticket.typeOfIssueId?.toString();

      // Set responsibility IDs
      selectedResponsibilityIds = ticket.responsibilityIds?.map((id) => id.toString()).toList() ?? [];
      _updateResponsibilityDisplay();

      // Set project
      if (ticket.projectId != null) {
        final project = projects.firstWhere(
              (p) => p['project_id'] == ticket.projectId,
          orElse: () => {},
        );
        if (project.isNotEmpty) {
          selectedProject = project;
          projectSearchController.text = project['project_name'] ?? '';
        }
      }

      // Set Johkasou models
      if (ticket.johkasouModels != null && ticket.johkasouModels!.isNotEmpty) {
        selectedJohkasouModels = ticket.johkasouModels!
            .where((model) => model.id != null)
            .map((model) => model.id.toString())
            .toList();
        _updateJohkasouModelsDisplay();
      }
    });
  }

  void _updateResponsibilityDisplay() {
    responsibilityDisplayController.text = selectedResponsibilityIds
        .map((id) {
      try {
        return responsibilities.firstWhere((r) => r['id'].toString() == id)['name'];
      } catch (e) {
        return "Unknown Responsibility";
      }
    })
        .where((name) => name != "Unknown Responsibility")
        .join(', ');
  }

  void _updateJohkasouModelsDisplay() {
    if (selectedProject != null && selectedJohkasouModels.isNotEmpty) {
      johkasouModelsDisplayController.text = selectedJohkasouModels
          .map((id) {
        try {
          return selectedProject!['project_module']
              .firstWhere((m) => m['id'].toString() == id)['module'];
        } catch (e) {
          return null;
        }
      })
          .where((name) => name != null)
          .join(', ');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    newIssueController.dispose();
    complaintBriefController.dispose();
    rootCauseController.dispose();
    carSerialController.dispose();
    projectSearchController.dispose();
    johkasouModelsDisplayController.dispose();
    expectedDateController.dispose();
    responseDateController.dispose();
    targetCompletionDateController.dispose();
    responsibilityDisplayController.dispose();
    receivedByController.dispose();
    super.dispose();
  }

  Future<void> fetchProjects() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception("Token not found!");

      final response = await http.get(
        Uri.parse("${DaikiAPI.api_key}/api/v1/project"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List projectList = data['data']['projects']['data'];
        setState(() {
          projects = projectList.map<Map<String, dynamic>>((project) {
            return {
              "pj_code": project["pj_code"]?.toString() ?? "-",
              "project_name": project["project_name"]?.toString() ?? "-",
              "location": project["location"]?.toString() ?? "-",
              "project_id": project["project_id"],
              "project_module": project["project_module"] ?? [],
            };
          }).toList();
        });
      } else {
        throw Exception("Failed to load projects. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching projects: $e");
    }
  }

  Future<void> fetchTypeOfIssues() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception("Token not found!");

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
          typeOfIssues = issueList.map<Map<String, dynamic>>((issue) {
            return {
              "id": issue["id"],
              "type_of_issue": issue["type_of_issue"]?.toString() ?? "-",
            };
          }).toList();
        });
      } else {
        throw Exception("Failed to load type of issues. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching type of issues: $e");
    }
  }

  Future<void> fetchResponsibilities() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception("Token not found!");

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
              "type_name": typeName,
            });
          }
        }

        setState(() {
          responsibilities = flattenedResponsibilities;
        });
      } else {
        throw Exception("Failed to load responsibilities. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching responsibilities: $e");
    }
  }

  Future<void> createTypeOfIssue() async {
    if (newIssueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a type of issue'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception("Token not found!");

      final response = await http.post(
        Uri.parse("${DaikiAPI.api_key}/api/v1/type-of-issues"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"type_of_issue": newIssueController.text, "status": "active"}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Type of issue created successfully!'), backgroundColor: Colors.green),
        );
        newIssueController.clear();
        await fetchTypeOfIssues();
      } else {
        String errorMsg = "Failed to create type of issue. Status: ${response.statusCode}";
        try {
          var jsonResponse = jsonDecode(response.body);
          errorMsg += "\n${jsonResponse['message'] ?? ''}";
        } catch (_) {}
        setState(() {
          errorMessage = errorMsg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error creating type of issue: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _captureImages() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _newImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error picking image: $e";
      });
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 60,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            _newImages.add(File(file.path));
          }
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error picking images from gallery: $e";
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> updateCAR() async {
    if (!_formKey.currentState!.validate()) return;

    final description = descriptionController.text.trim();
    if (description.length < 5 || description.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Description must be between 5 and 500 characters'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception("Token not found!");

      // Helper to format dates to YYYY-MM-DD
      String formatDateForApi(DateTime? date) {
        if (date == null) return '';
        return DateFormat('yyyy-MM-dd').format(date);
      }

      if (_newImages.isNotEmpty) {
        // Update with new files (multipart/form-data)
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${DaikiAPI.api_key}/api/v1/tickets/update"),
        );
        request.headers.addAll({
          "Authorization": "Bearer $token",
        });

        request.fields['id'] = widget.ticketId.toString();
        request.fields['project_id'] = selectedProject!["project_id"].toString();
        request.fields['title'] = titleController.text.trim();
        request.fields['expected_date'] = formatDateForApi(selectedExpectedDate);
        request.fields['description'] = description;
        request.fields['status'] = currentTicket?.status ?? 'open';
        request.fields['type_of_issue_id'] = selectedTypeOfIssue ?? '';

        request.fields['complaint_brief'] = complaintBriefController.text.trim();
        request.fields['response_date'] = formatDateForApi(selectedResponseDate);
        request.fields['root_cause'] = rootCauseController.text.trim();
        request.fields['target_completion_date'] = formatDateForApi(selectedTargetCompletionDate);
        request.fields['car_serial'] = carSerialController.text.trim();
        request.fields['received_by'] = receivedByController.text.trim();

        // Add johkasou_model_ids
        if (selectedJohkasouModels.isNotEmpty) {
          for (int i = 0; i < selectedJohkasouModels.length; i++) {
            request.fields['johkasou_model_ids[$i]'] = selectedJohkasouModels[i];
          }
        } else {
          request.fields['johkasou_model_ids'] = '[]';
        }

        // Add responsibility_ids
        if (selectedResponsibilityIds.isNotEmpty) {
          for (int i = 0; i < selectedResponsibilityIds.length; i++) {
            request.fields['responsibility_ids[$i]'] = selectedResponsibilityIds[i];
          }
        } else {
          request.fields['responsibility_ids'] = '[]';
        }

        // Add new images
        for (int i = 0; i < _newImages.length; i++) {
          var stream = http.ByteStream(_newImages[i].openRead());
          var length = await _newImages[i].length();
          request.files.add(http.MultipartFile('file[]', stream, length, filename: "inspection_image_$i.jpg"));
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('CAR updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true to indicate successful update
        } else {
          throw Exception('Failed to update CAR: ${response.statusCode} - $responseBody');
        }
      } else {
        // Update without new files (application/json)
        Map<String, dynamic> requestBody = {
          "id": widget.ticketId,
          "project_id": selectedProject!["project_id"],
          "title": titleController.text.trim(),
          "description": description,
          "status": currentTicket?.status ?? 'open',
          "expected_date": formatDateForApi(selectedExpectedDate),
          "type_of_issue_id": int.tryParse(selectedTypeOfIssue ?? '0') ?? 0,
          "responsibility_ids": selectedResponsibilityIds.map((id) => int.tryParse(id) ?? 0).toList(),
          "received_by": receivedByController.text.trim(),
          "complaint_brief": complaintBriefController.text.trim(),
          "response_date": formatDateForApi(selectedResponseDate),
          "root_cause": rootCauseController.text.trim(),
          "target_completion_date": formatDateForApi(selectedTargetCompletionDate),
          "car_serial": carSerialController.text.trim(),
          "johkasou_model_ids": selectedJohkasouModels.map((id) => int.tryParse(id) ?? 0).toList(),
        };

        final response = await http.post(
          Uri.parse("${DaikiAPI.api_key}/api/v1/tickets/update"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('CAR updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true to indicate successful update
        } else {
          throw Exception('Failed to update CAR: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDateTime(BuildContext context, String field) async {
    DateTime initialDate;
    if (field == 'expected') {
      initialDate = selectedExpectedDate ?? DateTime.now();
    } else if (field == 'response') {
      initialDate = selectedResponseDate ?? DateTime.now();
    } else {
      initialDate = selectedTargetCompletionDate ?? DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (field == 'expected') {
          selectedExpectedDate = pickedDate;
          expectedDateController.text = pickedDate.toLocal().toIso8601String().split('T')[0];
        } else if (field == 'response') {
          selectedResponseDate = pickedDate;
          responseDateController.text = pickedDate.toLocal().toIso8601String().split('T')[0];
        } else {
          selectedTargetCompletionDate = pickedDate;
          targetCompletionDateController.text = pickedDate.toLocal().toIso8601String().split('T')[0];
        }
      });
    }
  }

  Future<void> _selectJohkasouModels() async {
    if (selectedProject == null || selectedProject!['project_module'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select a project first'), backgroundColor: Colors.orange),
      );
      return;
    }

    List<String> tempSelectedModels = List.from(selectedJohkasouModels);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Johkasou Models'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: selectedProject!['project_module'].map<Widget>((module) {
                    return CheckboxListTile(
                      title: Text("${module['module']} (SL: ${module['sl_number']})"),
                      value: tempSelectedModels.contains(module['id'].toString()),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedModels.add(module['id'].toString());
                          } else {
                            tempSelectedModels.remove(module['id'].toString());
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedJohkasouModels = tempSelectedModels;
                      _updateJohkasouModelsDisplay();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectResponsibilities() async {
    List<String> tempSelectedResponsibilities = List.from(selectedResponsibilityIds);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Responsibilities'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: responsibilities.map<Widget>((resp) {
                    return CheckboxListTile(
                      title: Text("${resp['type_name']} - ${resp['name']}"),
                      value: tempSelectedResponsibilities.contains(resp['id'].toString()),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedResponsibilities.add(resp['id'].toString());
                          } else {
                            tempSelectedResponsibilities.remove(resp['id'].toString());
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedResponsibilityIds = tempSelectedResponsibilities;
                      _updateResponsibilityDisplay();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit CAR",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.grey[100]!],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : errorMessage.isNotEmpty
            ? Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionCard(
                  title: "Project Selection",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TypeAheadField<Map<String, dynamic>>(
                        builder: (context, controller, focusNode) {
                          return TextField(
                            controller: projectSearchController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: selectedProject == null ? "Search Project" : "",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: selectedProject != null
                                  ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.red[600]),
                                onPressed: () {
                                  setState(() {
                                    selectedProject = null;
                                    selectedJohkasouModels = [];
                                    projectSearchController.clear();
                                    johkasouModelsDisplayController.clear();
                                  });
                                },
                              )
                                  : null,
                            ),
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          final filteredProjects = projects
                              .where((project) =>
                          project["project_name"]!.toLowerCase().contains(pattern.toLowerCase()) ||
                              project["pj_code"]!.toLowerCase().contains(pattern.toLowerCase()))
                              .toList();
                          if (filteredProjects.isEmpty && pattern.isNotEmpty) {
                            return [
                              {"project_name": "Project not found", "pj_code": "", "isNotFound": true}
                            ];
                          }
                          return filteredProjects;
                        },
                        itemBuilder: (context, suggestion) {
                          if (suggestion["isNotFound"] == true) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.search_off, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Project not found",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListTile(
                            leading: Icon(Icons.business, color: Colors.blue[600]),
                            title: Text(suggestion["project_name"]!),
                            subtitle: Text("Code: ${suggestion["pj_code"]}"),
                          );
                        },
                        onSelected: (suggestion) {
                          if (suggestion["isNotFound"] == true) {
                            return;
                          }
                          setState(() {
                            selectedProject = suggestion;
                            selectedJohkasouModels = [];
                            projectSearchController.text = suggestion["project_name"]!;
                            johkasouModelsDisplayController.clear();
                          });
                        },
                      ),
                      if (selectedProject != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedProject!["project_name"]!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Code: ${selectedProject!["pj_code"]}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                "Location: ${selectedProject!["location"]}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          readOnly: true,
                          controller: johkasouModelsDisplayController,
                          decoration: InputDecoration(
                            labelText: "Selected Johkasou Models *",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Icon(Icons.list, color: Colors.blue[600]),
                          ),
                          onTap: selectedProject!['project_module'].isNotEmpty ? _selectJohkasouModels : null,
                          validator: (value) {
                            if (selectedProject != null && selectedProject!['project_module'].isNotEmpty && selectedJohkasouModels.isEmpty) {
                              return "At least one Johkasou Model is required";
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                _buildSectionCard(
                  title: "Report Details",
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Enter Type of Issue *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: selectedTypeOfIssue,
                        items: typeOfIssues
                            .map((issue) => DropdownMenuItem(
                          value: issue["id"].toString(),
                          child: Text(issue["type_of_issue"]),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTypeOfIssue = value;
                          });
                        },
                        validator: (value) => value == null ? "Type of issue is required" : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: newIssueController,
                              decoration: InputDecoration(
                                labelText: "Create Type of Issue",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: createTypeOfIssue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TizaraaColors.Tizara,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Title *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return "Title is required";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Description *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return "Description is required";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        controller: responsibilityDisplayController,
                        decoration: InputDecoration(
                          labelText: "Selected Responsibilities *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.people, color: Colors.blue[600]),
                        ),
                        onTap: responsibilities.isNotEmpty ? _selectResponsibilities : null,
                        validator: (value) {
                          if (selectedResponsibilityIds.isEmpty) {
                            return "At least one Responsibility is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: receivedByController,
                        decoration: InputDecoration(
                          labelText: "Received By *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return "Received By is required";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: complaintBriefController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Complaint Brief *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return "Complaint brief is required";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: rootCauseController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Root Cause *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return "Root cause is required";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: carSerialController,
                        decoration: InputDecoration(
                          labelText: "CAR Serial",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  title: "Schedule Details",
                  child: Column(
                    children: [
                      TextFormField(
                        readOnly: true,
                        controller: expectedDateController,
                        decoration: InputDecoration(
                          labelText: "Expected Date *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[600]),
                        ),
                        onTap: () => _selectDateTime(context, 'expected'),
                        validator: (value) => selectedExpectedDate == null ? "Expected date is required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        controller: responseDateController,
                        decoration: InputDecoration(
                          labelText: "Response Date *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[600]),
                        ),
                        onTap: () => _selectDateTime(context, 'response'),
                        validator: (value) => selectedResponseDate == null ? "Response date is required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        controller: targetCompletionDateController,
                        decoration: InputDecoration(
                          labelText: "Target Completion Date *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[600]),
                        ),
                        onTap: () => _selectDateTime(context, 'target'),
                        validator: (value) => selectedTargetCompletionDate == null ? "Target completion date is required" : null,
                      ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  title: "Current Images",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentTicket?.imageUrls != null && currentTicket!.imageUrls!.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: currentTicket!.imageUrls!.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                currentTicket!.imageUrls![index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'No existing images',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildSectionCard(
                  title: "Add New Images",
                  child: Column(
                    children: [
                      if (_newImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: _newImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _newImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeNewImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _captureImages,
                              icon: const Icon(Icons.camera_alt, color: Colors.white70),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TizaraaColors.Tizara,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImagesFromGallery,
                              icon: const Icon(Icons.photo_library, color: Colors.white70),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : updateCAR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TizaraaColors.Tizara,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update CAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}