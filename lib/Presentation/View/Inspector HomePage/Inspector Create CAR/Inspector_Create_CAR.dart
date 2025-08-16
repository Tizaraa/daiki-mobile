import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';

class InspectorCreateCAR extends StatefulWidget {
  const InspectorCreateCAR({super.key});

  @override
  _InspectorCreateCARState createState() => _InspectorCreateCARState();
}

class _InspectorCreateCARState extends State<InspectorCreateCAR> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> typeOfIssues = [];
  // This will now hold flattened responsibility persons with their type_name
  List<Map<String, dynamic>> responsibilities = [];
  bool isLoading = true;
  String errorMessage = '';

  Map<String, dynamic>? selectedProject;
  String? selectedFrequency;
  String? selectedTypeOfIssue;
  List<String> selectedJohkasouModels = [];
  // To store selected responsibility IDs
  List<String> selectedResponsibilityIds = [];
  DateTime? selectedExpectedDate;
  DateTime? selectedResponseDate;
  DateTime? selectedTargetCompletionDate;
  String? selectedPriority;
  String? carSerial;
  List<File> _images = [];
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
  // For responsibility display
  final TextEditingController responsibilityDisplayController = TextEditingController();
  // For received_by field
  final TextEditingController receivedByController = TextEditingController();
  String status = 'open';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Centralized function to fetch all initial data
  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      await fetchProjects();
      await fetchTypeOfIssues();
      await fetchResponsibilities(); // Fetch responsibilities on init
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load initial data: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
      if (token == null) {
        throw Exception("Token not found!");
      }
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
        print('Projects fetched successfully: ${projects.length} items');
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
          typeOfIssues = issueList.map<Map<String, dynamic>>((issue) {
            return {
              "id": issue["id"],
              "type_of_issue": issue["type_of_issue"]?.toString() ?? "-",
            };
          }).toList();
        });
        print('Type of Issues fetched successfully: ${typeOfIssues.length} items');
      } else {
        throw Exception("Failed to load type of issues. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching type of issues: $e");
    }
  }

  // New: Function to fetch responsibilities from API
  Future<void> fetchResponsibilities() async {
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
          responsibilities = flattenedResponsibilities;
        });
        print('Responsibilities fetched successfully: ${responsibilities.length} items');
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
        // Added 'status' field as per your backend body example
        body: jsonEncode({"type_of_issue": newIssueController.text, "status": "active"}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Type of issue created successfully!'), backgroundColor: Colors.green),
        );
        newIssueController.clear();
        await fetchTypeOfIssues(); // Refresh the list
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
          _images.add(File(pickedFile.path));
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
            _images.add(File(file.path));
          }
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error picking images from gallery: $e";
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> submitMaintenanceSchedule() async {
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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${DaikiAPI.api_key}/api/v1/tickets/create"),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      request.fields['project_id'] = selectedProject!["project_id"].toString();
      request.fields['title'] = titleController.text.trim();
      // Format dates to YYYY-MM-DD
      request.fields['expected_date'] = selectedExpectedDate?.toLocal().toIso8601String().split('T')[0] ?? '';
      request.fields['description'] = description;
      request.fields['status'] = 'open';
      request.fields['type_of_issue_id'] = selectedTypeOfIssue ?? '';
      request.fields['priority'] = selectedPriority ?? 'Medium';
      request.fields['complaint_brief'] = complaintBriefController.text.trim();
      // Format dates to YYYY-MM-DD
      request.fields['response_date'] = selectedResponseDate?.toLocal().toIso8601String().split('T')[0] ?? '';
      request.fields['root_cause'] = rootCauseController.text.trim();
      // Format dates to YYYY-MM-DD
      request.fields['target_completion_date'] = selectedTargetCompletionDate?.toLocal().toIso8601String().split('T')[0] ?? '';
      request.fields['car_serial'] = carSerialController.text.trim();
      request.fields['received_by'] = receivedByController.text.trim();

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

      if (_images.isNotEmpty) {
        for (int i = 0; i < _images.length; i++) {
          var stream = http.ByteStream(_images[i].openRead());
          var length = await _images[i].length();
          request.files.add(http.MultipartFile('file[]', stream, length, filename: "inspection_image_$i.jpg"));
        }
      }

      print('Request fields: ${request.fields}'); // Debugging print
      print('Request files: ${request.files.map((f) => f.field + ': ' + f.filename!).join(', ')}'); // Debugging print

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Server response: $responseBody'); // Debugging print

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Report created successfully!'), backgroundColor: Colors.green),
        );
        _clearAllFields();
      } else {
        var errors;
        try {
          var jsonResponse = jsonDecode(responseBody);
          errors = jsonResponse['errors'] ?? {'unknown': ['Unknown error']};
          String errorMessages = errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          setState(() {
            errorMessage = "Failed to create report:\n$errorMessages";
          });
        } catch (e) {
          setState(() {
            errorMessage = "Failed to create report. Status: ${response.statusCode}\nResponse: $responseBody";
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
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

  void _clearAllFields() {
    setState(() {
      _images = [];
      selectedFrequency = null;
      selectedTypeOfIssue = null;
      selectedJohkasouModels = [];
      selectedResponsibilityIds = []; // Clear selected responsibility IDs
      selectedExpectedDate = null;
      selectedResponseDate = null;
      selectedTargetCompletionDate = null;
      selectedPriority = null;
      carSerial = null;
      selectedProject = null;
      titleController.clear();
      descriptionController.clear();
      complaintBriefController.clear();
      rootCauseController.clear();
      carSerialController.clear();
      projectSearchController.clear();
      johkasouModelsDisplayController.clear();
      expectedDateController.clear();
      responseDateController.clear();
      targetCompletionDateController.clear();
      responsibilityDisplayController.clear();
      receivedByController.clear();
    });
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
                      johkasouModelsDisplayController.text = selectedJohkasouModels
                          .map((id) => selectedProject!['project_module']
                          .firstWhere((m) => m['id'].toString() == id)['module'])
                          .join(', ');
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

  // New: Function to select responsibilities
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
                      // Display type_name and name for clarity
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
                      // Update display controller with selected names
                      responsibilityDisplayController.text = selectedResponsibilityIds
                          .map((id) {
                        try {
                          return responsibilities.firstWhere((r) => r['id'].toString() == id)['name'];
                        } catch (e) {
                          print("Error finding responsibility name for ID $id: $e");
                          return "Unknown Responsibility"; // Fallback for missing ID
                        }
                      })
                          .join(', ');
                      print('Selected Responsibility IDs after dialog: $selectedResponsibilityIds'); // Debugging print
                      print('Responsibility Display Text after dialog: ${responsibilityDisplayController.text}'); // Debugging print
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
          "Create CAR",
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
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
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
                              const SizedBox(height: 8),
                              Text(
                                "Johkasou Models:",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[800]),
                              ),
                              const SizedBox(height: 4),
                              if (selectedProject!["project_module"].isNotEmpty)
                                ...selectedProject!["project_module"].map<Widget>((module) {
                                  return Text(
                                    "${module["module"]} (SL: ${module["sl_number"]})",
                                    style: TextStyle(color: Colors.grey[600]),
                                  );
                                }).toList()
                              else
                                Text(
                                  "No Johkasou Models available",
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
                            if (selectedProject!['project_module'].isNotEmpty && selectedJohkasouModels.isEmpty) {
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
                      // const SizedBox(height: 12),
                      // DropdownButtonFormField<String>(
                      //   decoration: InputDecoration(
                      //     labelText: "Priority *",
                      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //   ),
                      //   value: selectedPriority,
                      //   items: ['High', 'Medium', 'Low']
                      //       .map((priority) => DropdownMenuItem(
                      //     value: priority,
                      //     child: Text(priority),
                      //   ))
                      //       .toList(),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       selectedPriority = value;
                      //     });
                      //   },
                      //   validator: (value) => value == null ? "Priority is required" : null,
                      // ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        // For responsibility selection
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
                        // For received_by
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
                      // const SizedBox(height: 12),
                      // TextFormField(
                      //   controller: carSerialController,
                      //   decoration: InputDecoration(
                      //     labelText: "CAR Serial *",
                      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //   ),
                      //   validator: (value) {
                      //     final trimmed = value?.trim() ?? '';
                      //     if (trimmed.isEmpty) return "CAR serial is required";
                      //     return null;
                      //   },
                      // ),
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
                  title: "Inspection Images",
                  child: Column(
                    children: [
                      if (_images.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
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
                  onPressed: submitMaintenanceSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TizaraaColors.Tizara,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                  ),
                  child: const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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