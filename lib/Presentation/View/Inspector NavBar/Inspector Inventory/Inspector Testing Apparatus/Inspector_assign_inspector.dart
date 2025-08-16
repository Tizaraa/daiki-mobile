import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../../Core/Utils/api_service.dart';


class InspectorTestingAssignInspector extends StatefulWidget {
  final String teamId;

  const InspectorTestingAssignInspector({Key? key, required this.teamId}) : super(key: key);

  @override
  _InspectorTestingAssignInspectorState createState() => _InspectorTestingAssignInspectorState();
}

class _InspectorTestingAssignInspectorState extends State<InspectorTestingAssignInspector> {
  int? selectedInspectorId;
  List<Map<String, dynamic>> inspectors = [];
  bool isLoading = false;
  final TextEditingController _typeAheadController = TextEditingController();
  List<Map<String, dynamic>> selectedInspectors = [];


  Future<void> fetchInspectors() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = await TokenManager.getToken();
      print('Fetching inspectors for team: ${widget.teamId}'); // Debug print

      final response = await http.get(
        Uri.parse('https://johkasou-erp.comapi/v1/inspector-assign-in-team'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true && mounted) {
          setState(() {
            inspectors = List<Map<String, dynamic>>.from(jsonData['data']['users']);
            isLoading = false;
          });
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load inspectors');
        }
      } else {
        throw Exception('Failed to load inspectors');
      }
    } catch (e) {
      print('Error fetching inspectors: $e'); // Debug print
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inspectors: $e')),
        );
      }
    }
  }


  Future<void> showAssignmentDialog() async {
    // Fetch inspectors before showing dialog
    await fetchInspectors();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Inspector'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300, // Fixed height for better layout
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : inspectors.isEmpty
                    ? const Text('No inspectors available')
                    : Column(
                  children: [
                    TypeAheadField<Map<String, dynamic>>(

                      suggestionsCallback: (pattern) async {
                        // Filter inspectors based on search input
                        return inspectors
                            .where((inspector) => inspector['name']
                            .toString()
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, inspector) {
                        final isSelected = selectedInspectors.any(
                                (selected) => selected['id'] == inspector['id']);
                        return ListTile(
                          title: Text(inspector['name'].toString()),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                              color: Colors.green)
                              : null,
                        );
                      },
                      onSelected: (inspector) {
                        setState(() {
                          if (selectedInspectors.any((selected) =>
                          selected['id'] == inspector['id'])) {
                            // Remove if already selected
                            selectedInspectors.removeWhere(
                                    (selected) => selected['id'] == inspector['id']);
                          } else {
                            // Add to selected list
                            selectedInspectors.add(inspector);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 200,
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                'Selected Inspectors',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: selectedInspectors.isEmpty
                                  ? const Center(
                                child: Text('No inspectors selected'),
                              )
                                  : ListView.builder(
                                itemCount: selectedInspectors.length,
                                itemBuilder: (context, index) {
                                  final inspector =
                                  selectedInspectors[index];
                                  return ListTile(
                                    title: Text(
                                        inspector['name'].toString()),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          selectedInspectors
                                              .removeAt(index);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    selectedInspectors.clear(); // Clear selections on cancel
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedInspectors.isEmpty
                      ? null
                      : () async {
                    // Call the assignInspector function with selected inspectors
                    await assignInspector(selectedInspectors);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  Future<void> assignInspector(List<Map<String, dynamic>> selectedInspectors) async {
    if (selectedInspectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one inspector')),
      );
      return;
    }

    try {
      final token = await TokenManager.getToken();
      print('Assigning inspectors to team: ${widget.teamId}'); // Debug print

      // Extract user IDs from selected inspectors
      final List<int> userIds = selectedInspectors.map((inspector) => inspector['id'] as int).toList();

      // Send the request to the API
      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/assign-users-to-team/${widget.teamId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_ids': userIds, // Send as an array
        }),
      );

      print('Assignment response status: ${response.statusCode}'); // Debug print
      print('Assignment response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inspectors assigned successfully')),
          );
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to assign inspectors');
        }
      } else {
        throw Exception('Failed to assign inspectors');
      }
    } catch (e) {
      print('Error assigning inspectors: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning inspectors: $e')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showAssignmentDialog();
      },
      icon: const Icon(Icons.person_add),
      label: const Text("Assign Inspector"),
    );
  }
}

//=======   project assign  ==============//



class AssignProject extends StatefulWidget {
  const AssignProject({super.key, required this.teamId});

  final String teamId;

  @override
  _AssignProjectState createState() => _AssignProjectState();
}

class _AssignProjectState extends State<AssignProject> {
  List<Project> _projects = [];
  List<Project> _selectedProjects = [];
  bool _isLoading = false;

  // Function to fetch data from the API
  Future<void> fetchProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception("Token is null. Please log in again.");
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/project-assign-in-team'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data']['project'] != null) {
          final projectList = (data['data']['project'] as List)
              .map((projectData) => Project.fromJson(projectData))
              .toList();

          setState(() {
            _projects = projectList;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected data structure from API')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch project data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to assign projects
  Future<void> assignProjects() async {
    if (_selectedProjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one project')),
      );
      return;
    }

    try {
      final String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception("Token is null. Please log in again.");
      }

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/assign-projects-to-team/${widget.teamId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "projects": _selectedProjects.map((project) => {
            "id": project.project_id,
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projects assigned successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign projects: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign projects')),
      );
    }
  }

  // Function to show the assignment dialog
  void _showAssignmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Project'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 1.2,
                width: MediaQuery.of(context).size.width / 1.2,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show loading while fetching data
                    : Column(
                  children: [
                    // Searchable multi-select dropdown using TypeAheadField
                    TypeAheadField<Project>(

                      suggestionsCallback: (pattern) {
                        return _projects
                            .where((project) =>
                        project.pj_code.toLowerCase().contains(pattern.toLowerCase()) ||
                            project.project_name.toLowerCase().contains(pattern.toLowerCase()))
                            .toList(); // Convert the Iterable to a List
                      },

                      itemBuilder: (context, Project suggestion) {
                        return ListTile(
                          title: Text(suggestion.project_name),
                          subtitle: Text(suggestion.pj_code),
                        );
                      },
                      onSelected: (Project suggestion) {
                        setState(() {
                          if (!_selectedProjects.contains(suggestion)) {
                            _selectedProjects.add(suggestion);
                          }
                        });
                      },
                    ),
                    // Display selected projects
                    const SizedBox(height: 10),
                    Text('Selected Projects:'),
                    Wrap(
                      children: _selectedProjects.map((project) {
                        return Chip(
                          label: Text(project.project_name),
                          deleteIcon: const Icon(Icons.cancel),
                          onDeleted: () {
                            setState(() {
                              _selectedProjects.remove(project);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: _selectedProjects.isEmpty
                      ? null
                      : () {
                    assignProjects();
                    Navigator.of(context).pop(); // Close dialog after assignment
                  },
                  child: const Text('Submit'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProjects(); // Fetch the projects when the screen is first loaded
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.factory),
      onPressed: _showAssignmentDialog,
      label: const Text('Assign Project'),
    );
  }
}



class Project {
  final int project_id;
  final String pj_code;
  final String project_name;

  Project({
    required this.project_id,
    required this.pj_code,
    required this.project_name,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      project_id: json['project_id'],
      pj_code: json['pj_code'],
      project_name: json['project_name'],
    );
  }
}

