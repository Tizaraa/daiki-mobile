import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';
import '../../../../Core/Utils/colors.dart';

class InspectorGroupMember extends StatefulWidget {
  @override
  _InspectorGroupMemberState createState() => _InspectorGroupMemberState();
}

class _InspectorGroupMemberState extends State<InspectorGroupMember> {
  List<dynamic> groupMembers = [];
  List<dynamic> filteredMembers = [];
  List<dynamic> skillLevels = [];
  bool isLoading = true;
  // MODIFIED: Added trailing slash to baseImageUrl
  final String baseImageUrl = "https://minio.johkasou-erp.com/daiki/profile/";
  TextEditingController searchController = TextEditingController();
  String statusFilter = 'All';
  static const int fallbackSkillLevelId = 12;

  @override
  void initState() {
    super.initState();
    fetchGroupMembers();
    searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchGroupMembers() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    final url = Uri.parse('${DaikiAPI.api_key}/api/v1/group-members');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.get(url, headers: headers);
      print('fetchGroupMembers response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            groupMembers = data['data']['groupMemberGet'] ?? [];
            filteredMembers = groupMembers;
            skillLevels = _extractSkillLevels(groupMembers);
            print('Extracted skill levels: $skillLevels');
            isLoading = false;
          });
        } else {
          throw Exception('API returned false status: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load group members: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching group members: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group members: $e')),
      );
    }
  }

  List<dynamic> _extractSkillLevels(List<dynamic> members) {
    final Map<int, dynamic> uniqueSkillLevels = {};
    for (var member in members) {
      if (member['skill_level'] != null) {
        final skillLevel = member['skill_level'];
        uniqueSkillLevels[skillLevel['id']] = skillLevel;
      }
    }
    return uniqueSkillLevels.values.toList();
  }

  Future<void> createGroupMember({
    required String name,
    required String designation,
    required String dob,
    required int status,
    required int skillLevelId,
    File? image,
    String? nid,
  }) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing')),
      );
      return;
    }
    final url = Uri.parse('${DaikiAPI.api_key}/api/v1/group-members');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['designation'] = designation
      ..fields['dob'] = dob
      ..fields['status'] = status.toString()
      ..fields['skill_level'] = skillLevelId.toString(); // Changed to skill_level
    if (nid != null && nid.isNotEmpty) {
      request.fields['nid'] = nid;
    }
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    try {
      print('Creating member with fields: ${request.fields}');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print('createGroupMember response: ${response.statusCode} - ${responseBody.body}');
      final responseData = json.decode(responseBody.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['status'] == true) {
          await fetchGroupMembers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member created successfully')),
          );
        } else {
          throw Exception('API returned false status: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
          'Failed to create member: ${response.statusCode} - '
              '${responseData['message'] ?? 'Unknown error'} '
              'Details: ${responseData['errors'] ?? ''}',
        );
      }
    } catch (e) {
      print('Create member error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating member: $e')),
      );
    }
  }

  void _filterMembers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredMembers = groupMembers.where((member) {
        final name = member['name'].toString().toLowerCase();
        final designation = member['designation'].toString().toLowerCase();
        final memberStatus = member['status'] == 1 ? 'Active' : 'Inactive';
        final skillLevelName = member['skill_level'] != null
            ? member['skill_level']['name'].toString().toLowerCase()
            : '';
        bool matchesSearch =
            name.contains(query) || designation.contains(query) || skillLevelName.contains(query);
        bool matchesStatus = statusFilter == 'All' || memberStatus == statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _showCreateMemberDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController designationController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    TextEditingController nidController = TextEditingController();
    int status = 1;
    int selectedSkillLevelId =
    skillLevels.isNotEmpty ? skillLevels[0]['id'] as int : fallbackSkillLevelId;
    File? selectedImage;
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter member name',
                  ),
                ),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    hintText: 'Enter designation',
                  ),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'DOB',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                TextField(
                  controller: nidController,
                  decoration: const InputDecoration(
                    labelText: 'NID (Optional)',
                    hintText: 'Enter NID if applicable',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedSkillLevelId,
                  decoration: const InputDecoration(labelText: 'Skill Level'),
                  hint: const Text('Select Skill Level'),
                  items: skillLevels.isEmpty
                      ? [
                    const DropdownMenuItem<int>(
                      value: fallbackSkillLevelId,
                      child: Text('Manager (Default)'),
                    ),
                  ]
                      : skillLevels.map<DropdownMenuItem<int>>((level) {
                    return DropdownMenuItem<int>(
                      value: level['id'] as int,
                      child: Text(level['name'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value != null) {
                        selectedSkillLevelId = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Available Skill Levels: ${skillLevels.isEmpty ? 'None (Using default)' : skillLevels.map((level) => level['name']).join(', ')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                DropdownButtonFormField<int>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Active')),
                    DropdownMenuItem(value: 0, child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      if (value != null) {
                        status = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: const Text('Pick Image'),
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                if (designationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Designation is required')),
                  );
                  return;
                }
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dobController.text) &&
                    dobController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DOB must be in YYYY-MM-DD format')),
                  );
                  return;
                }
                Navigator.pop(context);
                await createGroupMember(
                  name: nameController.text.trim(),
                  designation: designationController.text.trim(),
                  dob: dobController.text.isEmpty ? '1970-01-01' : dobController.text,
                  status: status,
                  skillLevelId: selectedSkillLevelId,
                  image: selectedImage,
                  nid: nidController.text.isEmpty ? null : nidController.text.trim(),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditMemberDialog(dynamic member) async {
    TextEditingController nameController = TextEditingController(text: member['name']);
    TextEditingController designationController = TextEditingController(text: member['designation']);
    TextEditingController dobController = TextEditingController(text: member['dob'] ?? '');
    TextEditingController nidController = TextEditingController(text: member['nid'] ?? '');
    int status = member['status'];
    int selectedSkillLevelId =
        member['skill_level_id'] as int? ?? (skillLevels.isNotEmpty ? skillLevels[0]['id'] as int : fallbackSkillLevelId);
    String? currentImageUrl = member['image'] != null ? '$baseImageUrl${member['image']}' : null;
    File? selectedImage;
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter member name',
                  ),
                ),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    hintText: 'Enter designation',
                  ),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'DOB',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                TextField(
                  controller: nidController,
                  decoration: const InputDecoration(
                    labelText: 'NID (Optional)',
                    hintText: 'Enter NID if applicable',
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: selectedSkillLevelId,
                  decoration: const InputDecoration(labelText: 'Skill Level'),
                  hint: const Text('Select Skill Level'),
                  items: skillLevels.isEmpty
                      ? [
                    const DropdownMenuItem<int>(
                      value: fallbackSkillLevelId,
                      child: Text('Manager (Default)'),
                    ),
                  ]
                      : skillLevels.map<DropdownMenuItem<int>>((level) {
                    return DropdownMenuItem<int>(
                      value: level['id'] as int,
                      child: Text(level['name'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value != null) {
                        selectedSkillLevelId = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Available Skill Levels: ${skillLevels.isEmpty ? 'None (Using default)' : skillLevels.map((level) => level['name']).join(', ')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                DropdownButtonFormField<int>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Active')),
                    DropdownMenuItem(value: 0, child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      if (value != null) {
                        status = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentImageUrl != null || selectedImage != null)
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: selectedImage != null
                                ? FileImage(selectedImage!) as ImageProvider
                                : NetworkImage(currentImageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setDialogState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: const Text('Change Image'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }
                if (designationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Designation is required')),
                  );
                  return;
                }
                if (dobController.text.isNotEmpty &&
                    !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dobController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DOB must be in YYYY-MM-DD format')),
                  );
                  return;
                }
                Navigator.pop(context);
                await updateGroupMember(
                  id: member['id'],
                  name: nameController.text.trim(),
                  designation: designationController.text.trim(),
                  dob: dobController.text,
                  status: status,
                  skillLevelId: selectedSkillLevelId,
                  image: selectedImage,
                  nid: nidController.text.isEmpty ? null : nidController.text.trim(),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateGroupMember({
    required int id,
    required String name,
    required String designation,
    required String dob,
    required int status,
    required int skillLevelId,
    File? image,
    String? nid,
  }) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing')),
      );
      return;
    }
    final url = Uri.parse('${DaikiAPI.api_key}/api/v1/group-members/$id');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['_method'] = 'PUT'
      ..fields['name'] = name
      ..fields['designation'] = designation
      ..fields['status'] = status.toString()
      ..fields['skill_level'] = skillLevelId.toString(); // Changed to skill_level
    if (dob.isNotEmpty) {
      request.fields['dob'] = dob;
    }
    if (nid != null) {
      request.fields['nid'] = nid;
    }
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    try {
      print('Updating member with fields: ${request.fields}');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print('updateGroupMember response: ${response.statusCode} - ${responseBody.body}');
      final responseData = json.decode(responseBody.body);
      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          await fetchGroupMembers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member updated successfully')),
          );
        } else {
          throw Exception('API returned false status: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
          'Failed to update member: ${response.statusCode} - '
              '${responseData['message'] ?? 'Unknown error'} '
              'Details: ${responseData['errors'] ?? ''}',
        );
      }
    } catch (e) {
      print('Update member error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating member: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name,designation,skill level',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: statusFilter == 'All',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            statusFilter = 'All';
                            _filterMembers();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Active'),
                      selected: statusFilter == 'Active',
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green[100],
                      labelStyle: TextStyle(
                        color: statusFilter == 'Active' ? Colors.green[700] : Colors.black,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            statusFilter = 'Active';
                            _filterMembers();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Inactive'),
                      selected: statusFilter == 'Inactive',
                      backgroundColor: Colors.white,
                      selectedColor: Colors.orange[100],
                      labelStyle: TextStyle(
                        color: statusFilter == 'Inactive' ? Colors.orange[700] : Colors.black,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            statusFilter = 'Inactive';
                            _filterMembers();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMembers.isEmpty
                ? const Center(
              child: Text(
                'No members found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredMembers.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                // MODIFIED: Ensure imageUrl is correctly formed with the trailing slash
                final imageUrl = member['image'] != null && member['image'].isNotEmpty
                    ? (member['image'].startsWith('http') ? member['image'] : '$baseImageUrl${member['image']}')
                    : null;

                final bool isActive = member['status'] == 1;
                final String skillLevelName = member['skill_level'] != null
                    ? member['skill_level']['name'] ?? 'Not assigned'
                    : 'Not assigned';

                // ADDED: Print the constructed URL for debugging
                if (imageUrl != null) {
                  print('Attempting to load CircleAvatar image URL: $imageUrl');
                }

                return Card(
                  elevation: 1,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _showEditMemberDialog(member),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // MODIFIED: Use Image.network as child for better error handling
                          CircleAvatar(
                            radius: 30,

                            child: ClipOval(
                              child: imageUrl != null
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: 60, // Match radius * 2
                                height: 60, // Match radius * 2
                                errorBuilder: (context, error, stackTrace) {
                                  print('CircleAvatar NetworkImage Error: $error'); // Specific error for this image
                                  return const Icon(Icons.person, size: 30, color: Colors.grey);
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              )
                                  : const Icon(Icons.person, size: 30, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      member['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive ? Colors.green : Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Designation: ${member['designation'] ?? 'Not assigned'}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Skill Level: $skillLevelName',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Email: ${member['email'] ?? 'nazim@gmail.com'}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Phone: ${member['phone'] ?? '01719273222'}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMemberDialog,
        backgroundColor: TizaraaColors.Tizara,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create Group Member",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}