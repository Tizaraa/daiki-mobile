import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import '../../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../../Core/Utils/api_service.dart';
import '../../../../../Core/Utils/colors.dart';
import 'Inspector_maintenance_kit_model.dart';
import 'Inspector_maintenance_kit_view_details.dart';


class Inspector_MaintenanceKitListScreen extends StatefulWidget {
  @override
  _Inspector_MaintenanceKitListScreenState createState() => _Inspector_MaintenanceKitListScreenState();
}

class _Inspector_MaintenanceKitListScreenState extends State<Inspector_MaintenanceKitListScreen> {
  List<dynamic> maintenanceKitList = [];
  List<dynamic> filteredMaintenanceKitList = [];
  bool isLoading = true;
  final TokenManager tokenManager = TokenManager();
  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchMaintenanceKitList();
    searchController.addListener(() {
      filterSearchResults();
    });
  }

  //==== fetch maintenance kit data  =============//

  Future<void> fetchMaintenanceKitList() async {
    const String url = '${DaikiAPI.api_key}/api/v1/inventory';

    try {
      final String? token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            maintenanceKitList = data['data']['maintenanceKitList'] ?? [];
            filteredMaintenanceKitList = List.from(maintenanceKitList);
            isLoading = false;
          });
        } else {
          throw Exception("API returned false status.");
        }
      } else {
        throw Exception("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching maintenanceKitList: $e");
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchMaintenanceKitList();
  }

  // Filter the list of maintenance kits based on the search query
  void filterSearchResults() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredMaintenanceKitList = maintenanceKitList
          .where((kit) =>
      kit['name']?.toLowerCase().contains(query) ?? false ||
          kit['description']?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  // Update the maintenance kit

  Future<void> updateMaintenanceKit(int id, Map<String, dynamic> updateData) async {
    final String url = '${DaikiAPI.api_key}/api/v1/inventory/$id';
    try {
      final String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception("Token not found.");
      }

      // Safely access nested values with null checks
      final stock = updateData['stock'] as Map<String, dynamic>?;

      // Construct request body with null safety
      final Map<String, dynamic> requestBody = {
        'name': updateData['name'],
        'description': updateData['description'],
        'unit': updateData['unit'],
        'type': int.tryParse(updateData['type']?.toString() ?? '') ?? 2,
        'status': updateData['status'],
        'condition': updateData['condition'],
        'quantity': stock?['quantity'] ?? 0,
        'minimum_quantity': stock?['minimum_quantity'] ?? 0,
      };

      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            final index = maintenanceKitList.indexWhere((kit) => kit['id'] == id);
            if (index != -1) {
              // Safely update the list with null check
              final updatedData = responseData['data'] as Map<String, dynamic>?;
              if (updatedData != null) {
                maintenanceKitList[index] = {
                  ...maintenanceKitList[index],
                  ...updatedData,
                  'stock': updatedData['stock'] ?? {},
                };
                filterSearchResults(); // Re-filter after update
              }
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inspector Maintenance Kit updated successfully')),
          );
        } else {
          throw Exception("Update failed: ${responseData['message']}");
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception("Failed to update. Error: ${errorResponse['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Error updating maintenance kit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update maintenance kit: $e')),
      );
    }
  }

// Show dialog to edit a maintenance kit
  void showEditDialog(dynamic kit) {
    TextEditingController nameController = TextEditingController(text: kit['name']);
    TextEditingController descriptionController = TextEditingController(text: kit['description']);
    TextEditingController unitController = TextEditingController(text: kit['unit']);
    TextEditingController typeController = TextEditingController(text: kit['type']?.toString());
    TextEditingController quantityController = TextEditingController(
        text: kit['stock']?['quantity']?.toString() ?? '0');
    TextEditingController minQuantityController = TextEditingController(
        text: kit['stock']?['minimum_quantity']?.toString() ?? '0');
    TextEditingController conditionController = TextEditingController(text: kit['condition']);
    bool statusValue = kit['status'] == 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Inspector Maintenance Kit"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: unitController,
                      decoration: InputDecoration(labelText: 'Unit'),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(labelText: 'Type'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: minQuantityController,
                      decoration: InputDecoration(labelText: 'Minimum Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: conditionController,
                      decoration: InputDecoration(labelText: 'Condition'),
                    ),
                    SwitchListTile(
                      title: Text('Status'),
                      value: statusValue,
                      onChanged: (bool value) {
                        setState(() {
                          statusValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await updateMaintenanceKit(
                      kit['id'],
                      {
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'unit': unitController.text,
                        'type': typeController.text,
                        'status': statusValue ? 1 : 0,
                        'condition': conditionController.text,
                        'stock': {
                          'quantity': int.tryParse(quantityController.text) ?? 0,
                          'minimum_quantity': int.tryParse(minQuantityController.text) ?? 0,
                        }
                      },
                    );
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }



  // Delete maintenance kit
  Future<void> deleteMaintenanceKit(int id) async {
    final String url = '${DaikiAPI.api_key}/api/v1/inventory/$id';
    try {
      final String? token = await TokenManager.getToken();
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            maintenanceKitList.removeWhere((kit) => kit['id'] == id);
            filterSearchResults(); // Re-filter after delete
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inspector Maintenance Kit deleted successfully')),
          );
        } else {
          throw Exception("Delete failed: ${data['message']}");
        }
      } else {
        throw Exception("Failed to delete. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting maintenance kit: $e");
    }
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maintenance Kit", style: TextStyle(color: Colors.white)),
        backgroundColor: TizaraaColors.Tizara,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Project Name...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: filteredMaintenanceKitList.isEmpty
                  ? Center(child: Text('No Maintenance Kits Found'))
                  : ListView.builder(
                itemCount: filteredMaintenanceKitList.length,
                itemBuilder: (context, index) {
                  final kit = filteredMaintenanceKitList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 7),

                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: TizaraaColors.primaryColor2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Code: ${kit['sku'] ?? 'Unknown'}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Name: ${kit['name'] ?? 'Unknown'}'),
                                    ],
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        showEditDialog(kit);
                                        break;
                                      case 'delete':
                                        deleteMaintenanceKit(kit['id']);
                                        break;
                                      case 'assign':
                                        _showTeamAssignDialog(context, kit);
                                        break;
                                      case 'view':
                                        setState(() {
                                          print(kit);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Inspector_MaintenanceKitViewDetails(itemId: kit['id'] ?? 0),
                                            ),
                                          );
                                        });
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'assign',
                                      child: Row(
                                        children: [
                                          Icon(Icons.group_add, color: Colors.blueAccent),
                                          SizedBox(width: 8),
                                          Text('Assign Team'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.remove_red_eye, color: Colors.teal),
                                          SizedBox(width: 8),
                                          Text('View Details'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text('Description: ${kit['description'] ?? 'Unknown'}'),
                          Text('Unit: ${kit['unit'] ?? 'Unknown'}'),
                          Text('Type: ${kit['type']?.toString() ?? 'Unknown'}'),
                          Text('Stock: ${kit['stock']['quantity']?.toString() ?? 'Unknown'}'),
                          Text('Minimum Quantity: ${kit['stock']['minimum_quantity']?.toString() ?? 'Unknown'}'),
                          Text('Condition: ${kit['condition'] ?? 'Unknown'}'),
                          Text('Calibration Time: ${kit['calibration_time'] ?? 'Unknown'}'),
                          Text('Last Calibration Date: ${kit['last_calibration_date'] ?? 'Unknown'}'),
                          Text(
                            'Status: ${kit['status'] == 1 ? 'Active' : 'Inactive'}',
                            style: TextStyle(
                              color: kit['status'] == 1 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  // Show dialog for Team Assign
  Future<void> _showTeamAssignDialog(BuildContext context, dynamic item) async {
    showDialog(
      context: context,
      builder: (context) => AssignTeamDialog(itemId: item['id']),
    );
  }

}


class AssignTeamDialog extends StatefulWidget {
  final int itemId;

  const AssignTeamDialog({Key? key, required this.itemId}) : super(key: key);

  @override
  _AssignTeamDialogState createState() => _AssignTeamDialogState();
}

class _AssignTeamDialogState extends State<AssignTeamDialog> {
  List<Team> teams = [];
  List<String> selectedTeams = [];
  List<String> selectedTeamNames = [];
  String stock = '';
  bool isLoading = true;
  TextEditingController teamController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/team-list/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            teams = (responseData['data']['team'] as List)
                .map((teamData) => Team.fromJson(teamData))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load teams: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching teams: ${e.toString()}')),
      );
    }
  }

  Future<void> assignTeamToItem() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      print('Sending request with team IDs: $selectedTeams and stock: $stock'); // Debug print

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/assign-teams-to-inventoryItem/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'teams': selectedTeams.map((teamId) => {
            'id': teamId,
            'stock': stock,
          }).toList(),
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team & Stock Updated Successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to assign team');
      }
    } catch (e) {
      print('Error in assignTeamToItem: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning team: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Team to Item'),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF03106C)),
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: TypeAheadField(
                controller: teamController,
                itemBuilder: (context, suggestion) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              suggestion.toString()[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          suggestion.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (String suggestion) {
                  try {
                    final selectedTeamObj = teams.firstWhere(
                          (team) => team.name == suggestion,
                    );
                    setState(() {
                      selectedTeams.add(selectedTeamObj.id.toString());
                      selectedTeamNames.add(suggestion);
                      teamController.text = '';  // Clear the text field for next input
                      print('Selected Team IDs: $selectedTeams'); // Debug print
                    });
                  } catch (e) {
                    print('Error in team selection: $e'); // Debug print
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error selecting team')),
                    );
                  }
                },
                suggestionsCallback: (pattern) {
                  return teams
                      .where((team) => team.name.toLowerCase().contains(pattern.toLowerCase()))
                      .map((team) => team.name)
                      .toList();
                },
                hideOnEmpty: true,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: selectedTeamNames.map((name) {
                return Chip(
                  label: Text(name),
                  onDeleted: () {
                    setState(() {
                      int index = selectedTeamNames.indexOf(name);
                      selectedTeamNames.removeAt(index);
                      selectedTeams.removeAt(index);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Stock',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  stock = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Assign'),
          onPressed: () {
            if (selectedTeams.isEmpty || stock.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select at least one team and enter stock')),
              );
              return;
            }

            if (int.tryParse(stock) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a valid stock number')),
              );
              return;
            }

            assignTeamToItem();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    teamController.dispose();
    super.dispose();
  }
}


