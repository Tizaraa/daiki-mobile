import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';

class InspectorGroupsApi {
  static Future<dynamic> fetchGroups() async {
    http.Response? response;
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Failed to get authentication token');
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/groups');
      print('Request URL: $url');
      response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body Preview: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      if (response.statusCode == 200) {
        return {'type': 'raw_response', 'data': response.body};
      } else {
        return {
          'type': 'error',
          'statusCode': response.statusCode,
          'message': 'Server error ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'type': 'exception',
        'message': 'Error fetching groups: $e',
        'response': response?.body,
      };
    }
  }

  static Future<dynamic> createGroup(String name, String status) async {
    http.Response? response;
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Failed to get authentication token');
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/groups');
      final body = json.encode({'name': name, 'status': status});
      print('Create Group Request URL: $url');
      print('Request Body: $body');
      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );
      print('Create Response Status Code: ${response.statusCode}');
      print('Create Response Body Preview: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      if (response.statusCode == 201) {
        return {'type': 'success', 'data': json.decode(response.body)};
      } else {
        return {
          'type': 'error',
          'statusCode': response.statusCode,
          'message': 'Group Create Successfully!!',
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'type': 'exception',
        'message': 'Error creating group: $e',
        'response': response?.body,
      };
    }
  }

  static Future<dynamic> updateGroup(String groupId, String name, int status) async {
    http.Response? response;
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Failed to get authentication token');
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/groups/$groupId');
      final body = json.encode({
        'name': name,
        'status': status,
      });
      print('Update Group Request URL: $url');
      print('Request Body: $body');
      response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );
      print('Update Response Status Code: ${response.statusCode}');
      print('Update Response Body: ${response.body}');
      return response.statusCode == 200
          ? {'type': 'success', 'data': json.decode(response.body)}
          : {
        'type': 'error',
        'statusCode': response.statusCode,
        'message': 'Failed to update group: ${response.statusCode}',
        'body': response.body,
      };
    } catch (e) {
      return {
        'type': 'exception',
        'message': 'Error updating group: $e',
        'response': response?.body,
      };
    }
  }

  static Future<dynamic> deleteGroup(String groupId) async {
    http.Response? response;
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Failed to get authentication token');
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/groups/$groupId');
      print('Delete Group Request URL: $url');
      response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('Delete Response Status Code: ${response.statusCode}');
      print('Delete Response Body Preview: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'type': 'success', 'message': 'Group deleted successfully'};
      } else {
        return {
          'type': 'error',
          'statusCode': response.statusCode,
          'message': 'Failed to delete group: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'type': 'exception',
        'message': 'Error deleting group: $e',
        'response': response?.body,
      };
    }
  }
}

class InspectorGroup extends StatefulWidget {
  @override
  _InspectorGroupState createState() => _InspectorGroupState();
}

class _InspectorGroupState extends State<InspectorGroup> {
  late Future<dynamic> _apiFuture;
  Map<String, dynamic>? _parsedJson;
  List<dynamic> _groupList = [];
  List<dynamic> _filteredGroupList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'active';
  bool _isSearching = false;
  List<int> _selectedMemberIds = [];
  List<Map<String, dynamic>> _availableMembers = [];
  bool _isLoadingMembers = false;
  List<int> selectedInspectorIds = [];
  bool isLoading = true;
  List<Map<String, dynamic>> availableInspectors = [];

  static Future<List<Map<String, dynamic>>> fetchAvailableMembers() async {
    http.Response? response;
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Failed to get authentication token');
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/group-members');
      print('Fetch Members Request URL: $url');
      response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('Fetch Members Response Status Code: ${response.statusCode}');
      print('Fetch Members Response Body: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data']['groupMemberGet'];
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch members: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAvailableInspectors() async {
    http.Response? response;
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Failed to get authentication token');
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/inspector-assign-in-group');
      print('Fetch Inspectors Request URL: $url');
      response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('Fetch Inspectors Response Status Code: ${response.statusCode}');
      print('Fetch Inspectors Response Body: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response Data: $responseData');
        if (responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else if (responseData['data'] is Map && responseData['data']['inspectorList'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']['inspectorList']);
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to fetch inspectors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching inspectors: $e');
      return [];
    }
  }

  Future<void> _showAssignMemberDialog(String groupId) async {
    List<int> selectedMemberIds = [];
    bool isLoading = true;
    List<Map<String, dynamic>> availableMembers = [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setState) {
              void loadMembers() async {
                try {
                  final token = await TokenManager.getToken();
                  final response = await http.get(
                    Uri.parse('${DaikiAPI.api_key}/api/v1/group-members'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    setState(() {
                      availableMembers = List<Map<String, dynamic>>.from(data['data']['groupMemberGet'] ?? []);
                      isLoading = false;
                    });
                  } else {
                    print('Failed to load members: ${response.statusCode}');
                    print('Response: ${response.body}');
                    setState(() {
                      isLoading = false;
                    });
                  }
                } catch (e) {
                  print('Error fetching members: $e');
                  setState(() {
                    isLoading = false;
                  });
                }
              }
              if (isLoading && availableMembers.isEmpty) {
                loadMembers();
              }
              return AlertDialog(
                title: Text('Assign Members to Group'),
                content: Container(
                  width: double.maxFinite,
                  height: 400,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : availableMembers.isEmpty
                      ? Center(child: Text('No members found'))
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableMembers.length,
                    itemBuilder: (context, index) {
                      final member = availableMembers[index];
                      final memberId = member['id'];
                      final memberName = member['name'] ?? 'Unknown';
                      final memberDesignation = member['designation'] ?? 'Unknown';
                      return CheckboxListTile(
                        title: Text('$memberName ($memberDesignation)'),
                        value: selectedMemberIds.contains(memberId),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedMemberIds.add(memberId);
                            } else {
                              selectedMemberIds.remove(memberId);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  MaterialButton(
                    color: Colors.red[200],
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  MaterialButton(
                    color: Colors.green[200],
                    onPressed: isLoading
                        ? null
                        : () async {
                      if (selectedMemberIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text('Please select at least one member'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      final token = await TokenManager.getToken();
                      final payload = {
                        'group_id': int.parse(groupId),
                        'memberIds': selectedMemberIds,
                      };
                      try {
                        final response = await http.post(
                          Uri.parse('${DaikiAPI.api_key}/api/v1/groups/assign-members/$groupId'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          },
                          body: json.encode(payload),
                        );
                        Navigator.pop(context);
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Members assigned successfully'),
                            ),
                          );
                        } else {
                          final errorData = json.decode(response.body);
                          final errorMessage = errorData['message'] ?? 'Failed to assign members';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Error: $errorMessage'),
                            ),
                          );
                          print('Failed to assign members: ${response.statusCode}');
                          print('Response: ${response.body}');
                        }
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error: $e'),
                          ),
                        );
                        print('Error assigning members: $e');
                      }
                    },
                    child: Text('Assign'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Future<void> _showAssignInspectorDialog(BuildContext context, String groupId) async {
    List<int> selectedInspectorIds = [];
    bool isLoading = true;
    List<Map<String, dynamic>> availableInspectors = [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void loadInspectors() async {
              try {
                final token = await TokenManager.getToken();
                if (token == null) {
                  throw Exception('Failed to get authentication token');
                }
                final response = await http.get(
                  Uri.parse('${DaikiAPI.api_key}/api/v1/inspector-assign-in-group'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                );
                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  setState(() {
                    availableInspectors = data['data']?['users'] is List
                        ? List<Map<String, dynamic>>.from(data['data']['users'])
                        : [];
                    isLoading = false;
                  });
                } else {
                  setState(() {
                    isLoading = false;
                  });
                }
              } catch (e) {
                setState(() {
                  isLoading = false;
                });
              }
            }
            if (isLoading && availableInspectors.isEmpty) {
              loadInspectors();
            }
            return AlertDialog(
              title: Text('Assign Inspectors to Group'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : availableInspectors.isEmpty
                    ? Center(child: Text('No inspectors found'))
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableInspectors.length,
                  itemBuilder: (context, index) {
                    final inspector = availableInspectors[index];
                    final inspectorId = inspector['id'];
                    final inspectorName = inspector['name'] ?? 'Unknown';
                    final inspectorEmail = inspector['email'] ?? 'Unknown';
                    return CheckboxListTile(
                      title: Text('$inspectorName ($inspectorEmail)'),
                      value: selectedInspectorIds.contains(inspectorId),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedInspectorIds.add(inspectorId);
                          } else {
                            selectedInspectorIds.remove(inspectorId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                MaterialButton(
                  color: Colors.red[200],
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel'),
                ),
                MaterialButton(
                  color: Colors.green[200],
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (selectedInspectorIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orange,
                          content: Text('Please select at least one inspector'),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final token = await TokenManager.getToken();
                      if (token == null) {
                        throw Exception('Failed to get authentication token');
                      }
                      var request = http.MultipartRequest(
                        'POST',
                        Uri.parse('${DaikiAPI.api_key}/api/v1/groups/$groupId/assign-inspector'),
                      );
                      request.headers['Authorization'] = 'Bearer $token';
                      for (var inspectorId in selectedInspectorIds) {
                        request.fields['inspector_id'] = inspectorId.toString();
                      }
                      print('Sending payload: ${request.fields}');
                      var response = await request.send();
                      var responseBody = await response.stream.bytesToString();
                      print('Response status: ${response.statusCode}');
                      print('Response body: $responseBody');
                      if (response.statusCode == 200 || response.statusCode == 201) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Inspectors assigned successfully'),
                          ),
                        );
                        InspectorGroupsApi();
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error: Failed to assign inspectors'),
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Error: $e'),
                        ),
                      );
                    }
                  },
                  child: Text('Assign'),
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
    _loadData();
    _searchController.addListener(_filterGroups);
    _showAssignMemberDialog;
    fetchAvailableInspectors;
    fetchAvailableMembers;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _parsedJson = null;
      _groupList = [];
      _filteredGroupList = [];
      _apiFuture = InspectorGroupsApi.fetchGroups().then((response) {
        if (response['type'] == 'raw_response') {
          _tryParseJson(response['data']);
        }
        return response;
      });
    });
  }

  void _tryParseJson(String jsonString) {
    try {
      final parsed = json.decode(jsonString);
      setState(() {
        _parsedJson = parsed;
        if (_parsedJson != null &&
            _parsedJson!['data'] != null &&
            _parsedJson!['data']['groupMemberGet'] != null &&
            _parsedJson!['data']['groupMemberGet'] is List) {
          _groupList = _parsedJson!['data']['groupMemberGet'];
          _filteredGroupList = List.from(_groupList);
        } else {
          _groupList = [];
          _filteredGroupList = [];
        }
      });
    } catch (e) {
      setState(() {
        _parsedJson = null;
        _groupList = [];
        _filteredGroupList = [];
      });
    }
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGroupList = List.from(_groupList);
      } else {
        _filteredGroupList = _groupList.where((group) {
          final groupName = group['name']?.toString().toLowerCase() ?? '';
          if (groupName.contains(query)) return true;
          final inspectorName = group['inspector']?['name']?.toString().toLowerCase() ?? '';
          if (inspectorName.contains(query)) return true;
          final members = group['inspector']?['members'] as List? ?? [];
          for (var member in members) {
            final memberName = member['name']?.toString().toLowerCase() ?? '';
            if (memberName.contains(query)) return true;
          }
          return false;
        }).toList();
      }
    });
  }

  Future<void> _showEditGroupDialog(dynamic group) {
    print('Editing group: ${json.encode(group)}');
    if (group == null) {
      print('Warning: group is null');
      return Future.value();
    }
    final groupId = group['id']?.toString() ?? '';
    if (groupId.isEmpty) {
      print('Warning: group ID is empty or null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Cannot edit group: ID not found')),
      );
      return Future.value();
    }
    _nameController.text = group['name']?.toString() ?? '';
    String initialStatus;
    if (group['status'] == null) {
      initialStatus = 'active';
    } else if (group['status'] is int) {
      initialStatus = group['status'] == 0 ? 'inactive' : 'active';
    } else {
      String statusStr = group['status'].toString().toLowerCase();
      initialStatus = (statusStr == 'inactive' || statusStr == 'Inactive') ? 'inactive' : 'active';
    }
    String dialogStatus = initialStatus;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Group Name', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: dialogStatus,
                decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['active', 'inactive']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  dialogStatus = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  print('Updating group with ID: $groupId');
                  print('New name: ${_nameController.text}');
                  print('New status (string): $dialogStatus');
                  final int statusValue = dialogStatus == 'inactive' ? 0 : 1;
                  print('New status (int): $statusValue');
                  final response = await InspectorGroupsApi.updateGroup(groupId, _nameController.text, statusValue);
                  Navigator.pop(context);
                  if (response['type'] == 'success') {
                    _loadData();
                    setState(() {
                      _selectedStatus = dialogStatus;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Colors.green, content: Text('Group updated successfully')),
                    );
                  } else {
                    print('Update error: ${response['message']}');
                    print('Error details: ${response['body']}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Failed to update group: ${response['message']}'),
                      ),
                    );
                  }
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteGroup(dynamic group) {
    final groupId = group['id']?.toString();
    final groupName = group['name'] ?? 'this group';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete $groupName?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (groupId == null || groupId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.red, content: Text('Cannot delete group: ID not found')),
                  );
                  return;
                }
                final response = await InspectorGroupsApi.deleteGroup(groupId);
                if (response['type'] == 'success') {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.green, content: Text('Group deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.red, content: Text('Failed to delete group')),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xF0E5F4F4),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  hintStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  _filterGroups();
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                  await _apiFuture;
                },
                child: FutureBuilder<dynamic>(
                  future: _apiFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return _buildErrorView('Future Error', snapshot.error.toString());
                    } else if (!snapshot.hasData) {
                      return _buildErrorView('No Data', 'API response is empty');
                    } else {
                      final response = snapshot.data!;
                      if (response['type'] == 'error') {
                        return _buildErrorView('API Error (${response['statusCode']})', response['message'], details: response['body']);
                      } else if (response['type'] == 'exception') {
                        return _buildErrorView('Exception', response['message'], details: response['response']);
                      } else if (response['type'] == 'raw_response') {
                        return _buildGroupListView();
                      }
                      return _buildErrorView('Unknown Response', 'Response format not recognized');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItem(dynamic group) {
    const String baseImageUrl = '${ImageAPI.test_img_key}/profile/';

    // Fixed image loading function with better error handling
    Widget buildProfileImage(String? imagePath, double size, String fallbackText) {
      // Debug print to see what image path we're getting
      print('Building profile image for: $fallbackText');
      print('Image path received: $imagePath');

      String? fullImageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        fullImageUrl = '$baseImageUrl$imagePath';
        print('Full image URL: $fullImageUrl');
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          color: Colors.grey.shade200,
        ),
        child: ClipOval(
          child: fullImageUrl != null
              ? Image.network(
            fullImageUrl,
            fit: BoxFit.cover,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading image: $fullImageUrl');
              print('Error details: $error');
              print('Stack trace: $stackTrace');
              return Container(
                color: Colors.blue.shade100,
                child: Center(
                  child: Text(
                    _getInitials(fallbackText),
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                print('✅ Image loaded successfully: $fullImageUrl');
                return child;
              }
              return Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: SizedBox(
                    width: size * 0.5,
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
              );
            },
          )
              : Container(
            color: Colors.grey.shade300,
            child: Center(
              child: Text(
                _getInitials(fallbackText),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    List<dynamic> members = (group['inspector']?['members'] as List?) ?? [];
    int memberCount = members.length;

    return Card(
      color: TizaraaColors.primaryColor2,
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          '${group['name'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Leader: ${group['inspector']?['name'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$memberCount members',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 30,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    for (int i = 0; i < (memberCount > 3 ? 3 : memberCount); i++)
                      Positioned(
                        right: i * 20.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 1.5),
                          ),
                          child: ClipOval(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: () {
                                String? memberImagePath = members[i]['image']?.toString();
                                print('Member ${i} image path: $memberImagePath');

                                if (memberImagePath != null && memberImagePath.isNotEmpty) {
                                  String fullUrl = '$baseImageUrl$memberImagePath';
                                  print('Member ${i} full URL: $fullUrl');

                                  return Image.network(
                                    fullUrl,
                                    fit: BoxFit.cover,
                                    headers: {
                                      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('❌ Error loading member image: $fullUrl');
                                      print('Error: $error');
                                      return Container(
                                        color: Colors.orange.shade100,
                                        child: Center(
                                          child: Text(
                                            _getInitials(members[i]['name'] ?? 'U'),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        print('✅ Member image loaded: $fullUrl');
                                        return child;
                                      }
                                      return Container(
                                        color: Colors.grey.shade100,
                                        child: Center(
                                          child: SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(strokeWidth: 1),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Text(
                                        _getInitials(members[i]['name'] ?? 'U'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inspector Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileImage(
                          group['inspector']?['photo'],
                          60.0,
                          group['inspector']?['name'] ?? 'Inspector',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${group['inspector']?['name'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Email: ${group['inspector']?['email'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Phone: ${group['inspector']?['phone'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Members:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...members.isNotEmpty
                    ? members.map<Widget>((member) => Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileImage(
                          member['image'],
                          50.0,
                          member['name'] ?? 'Member',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${member['name'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Designation: ${member['designation'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'DOB: ${member['dob'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'NID: ${member['nid'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList()
                    : [
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('No members'),
                    ),
                  )
                ],
                const SizedBox(height: 16),
                const Divider(),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    MaterialButton(
                      color: Colors.teal,
                      child: const Text("Edit", style: TextStyle(color: Colors.white)),
                      onPressed: () => _showEditGroupDialog(group),
                    ),
                    MaterialButton(
                      color: Colors.red,
                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      onPressed: () => _confirmDeleteGroup(group),
                    ),
                    MaterialButton(
                      color: Colors.deepPurple[300],
                      child: const Text("Assign Member", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        final currentGroupId = group['id'].toString();
                        _showAssignMemberDialog(currentGroupId);
                      },
                    ),
                    MaterialButton(
                      color: Colors.indigoAccent[400],
                      child: const Text("Assign Inspector", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        final currentGroupId = group['id'].toString();
                        _showAssignInspectorDialog(context, currentGroupId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get initials from a name
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name[0].toUpperCase();
    }
  }

  Widget _buildGroupListView() {
    if (_filteredGroupList.isEmpty) {
      return Center(child: Text('No groups to display.'));
    }
    return ListView.builder(
      itemCount: _filteredGroupList.length,
      itemBuilder: (context, index) => _buildGroupItem(_filteredGroupList[index]),
    );
  }

  Widget _buildErrorView(String title, String message, {String? details}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (details != null) ...[
              SizedBox(height: 16),
              Container(
                height: 200,
                color: Colors.grey[200],
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: SelectableText(details, style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                ),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text('Retry')),
          ],
        ),
      ),
    );
  }
}