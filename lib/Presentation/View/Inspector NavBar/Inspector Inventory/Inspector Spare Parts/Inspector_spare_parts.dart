import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import '../../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../../Core/Utils/api_service.dart';
import '../../../../../Core/Utils/colors.dart';
import 'Inspector_spare_parts_model.dart';
import 'Inspector_spare_parts_view_details.dart';


class InspectorSparePartsScreen extends StatefulWidget {
  @override
  _InspectorSparePartsScreenState createState() => _InspectorSparePartsScreenState();
}

class _InspectorSparePartsScreenState extends State<InspectorSparePartsScreen> {
  late Future<List<InspectorSpareParts>> sparePartsFuture;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    sparePartsFuture = fetchSpareParts();
  }

  Future<List<InspectorSpareParts>> fetchSpareParts() async {
    final String apiUrl = '${DaikiAPI.api_key}/api/v1/inventory';
    final token = await TokenManager.getToken();

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true &&

            jsonResponse['data']['spareParts'] != null) {
          final sparePartsList = jsonResponse['data']['spareParts'] as List;
          return sparePartsList.map((item) => InspectorSpareParts.fromJson(item)).toList();
        } else {
          throw Exception('Invalid data structure');
        }
      } else {
        throw Exception('Failed to load spare parts. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching spare parts: $e');
    }
  }

  Future<void> deleteSparePart(int id) async {
    final String apiUrl = '${DaikiAPI.api_key}/api/v1/inventory/$id';
    final token = await TokenManager.getToken();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          sparePartsFuture = fetchSpareParts();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Spare part deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete spare part');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting spare part: $e')),
      );
    }
  }

  // Search functionality
  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      sparePartsFuture = fetchSpareParts();
    });
    await sparePartsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spare Parts', style: TextStyle(color: Colors.white)),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
            children: [
        Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by project name...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: FutureBuilder<List<InspectorSpareParts>>(
          future: sparePartsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No spare parts available'),
                  ],
                ),
              );
            }

            var spareParts = snapshot.data!;
            if (searchQuery.isNotEmpty) {
              spareParts = spareParts.where((part) =>
              (part.name?.toLowerCase().contains(searchQuery) ?? false) ||
                  (part.description?.toLowerCase().contains(searchQuery) ?? false)
              ).toList();
            }

            return ListView.builder(
              itemCount: spareParts.length,
              itemBuilder: (context, index) {
                final part = spareParts[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: TizaraaColors.primaryColor2,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      part.sku ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      part.name ?? 'Unnamed',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditSparePartScreen(
                                            part: part,
                                            onUpdated: () {
                                              setState(() {
                                                sparePartsFuture = fetchSpareParts();
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                      break;
                                    case 'delete':
                                      _showDeleteConfirmationDialog(part.id ?? 0);
                                      break;
                                    case 'assign':
                                      _showTeamAssignDialog(context, part);
                                      break;
                                    case 'view':
                                      setState(() {
                                        print(part);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => InspectorSparePartsViewDetails(itemId: part.id ?? 0),
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
                                        Icon(Icons.edit, color: Theme.of(context).primaryColor),
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
                        SizedBox(height: 8),
                        Text("${part.description}" ?? 'No description available',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),

                        Wrap(
                          spacing: 6.0, // Horizontal spacing between items
                          runSpacing: 5.0, // Vertical spacing between lines
                          children: [
                            _buildInfoRow('Unit', part.unit ?? 'N/A'),
                            _buildInfoRow('Type', part.type?.toString() ?? 'N/A'),
                            _buildInfoRow('Status', part.status?.toString() ?? 'N/A'),
                            _buildInfoRow('Stock Quantity', part.stock?.quantity?.toString() ?? 'N/A'),
                            _buildInfoRow('Minimum Stock', part.stock?.minimumQuantity?.toString() ?? 'N/A'),
                            _buildInfoRow('Condition', part.condition ?? 'N/A'),
                            _buildInfoRow('Last Calibrated Date',
                                part.calibrationTime != null ? part.calibrationTime.toString() : 'N/A'),
                            _buildInfoRow('Next Calibration Date',
                                part.lastCalibrationDate != null ? part.lastCalibrationDate.toString() : 'N/A'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
    )],
        ),
      ),
      );

  }




  Widget _buildInfoRow(String label, String value) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 38, // Half screen width minus padding and margin
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Delete confirmation dialog
  void _showDeleteConfirmationDialog(int partId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Spare Part'),
          content: Text('Are you sure you want to delete this spare part?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteSparePart(partId);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}


class SparePartsSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    throw UnimplementedError();
  }
}


class EditSparePartScreen extends StatefulWidget {
  final InspectorSpareParts part;
  final Function onUpdated;


  const EditSparePartScreen({Key? key, required this.part, required this.onUpdated}) : super(key: key);


  @override
  _EditSparePartScreenState createState() => _EditSparePartScreenState();
}

class _EditSparePartScreenState extends State<EditSparePartScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController unitController;
  late TextEditingController typeController;
  late TextEditingController conditionController;
  late TextEditingController quantityController;
  late TextEditingController minimumQuantityController;
  String selectedStatus = 'active'; // Default value

  final List<String> statusOptions = ['active', 'inactive'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.part.name);
    descriptionController = TextEditingController(text: widget.part.description ?? '');
    unitController = TextEditingController(text: widget.part.unit ?? '');
    typeController = TextEditingController(text: widget.part.type.toString());
    conditionController = TextEditingController(text: widget.part.condition ?? '');
    quantityController = TextEditingController(text: widget.part.stock?.quantity.toString());
    minimumQuantityController = TextEditingController(text: widget.part.stock?.minimumQuantity.toString());

    // Ensure selectedStatus is one of the options in statusOptions
    selectedStatus = widget.part.status == 1 ? 'active' : 'inactive';
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    unitController.dispose();
    typeController.dispose();
    conditionController.dispose();
    quantityController.dispose();
    minimumQuantityController.dispose();
    super.dispose();
  }

  Future<void> updateSparePart() async {
    try {
      // Validate form before proceeding
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Check if widget.part is null
      if (widget.part == null) {
        throw Exception('Spare part data is missing');
      }

      // Retrieve authentication token
      final String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final String apiUrl =
          '${DaikiAPI.api_key}/api/v1/inventory/${widget.part.id}';

      // Map status ('active'/'inactive') to integer (1/0)
      int status = selectedStatus == 'active' ? 1 : 0;

      // Construct request body (CORRECT FORMAT)
      Map<String, dynamic> requestBody = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'unit': unitController.text.trim(),
        'type': int.tryParse(typeController.text.trim()) ?? 0,
        'condition': conditionController.text.trim(),
        'quantity': int.tryParse(quantityController.text.trim()) ?? 0,  // ✅ Moved out of 'stock'
        'minimum_quantity': int.tryParse(minimumQuantityController.text.trim()) ?? 0, // ✅ Moved out of 'stock'
        'status': status,
      };

      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      // Success handling
      if (response.statusCode == 200 &&
          (responseData['success'] == true ||
              responseData['status'] == true ||
              responseData['message']?.contains('updated successfully') == true)) {
        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onUpdated();
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Spare part updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        });
        return;
      }

      // Handle API error response
      String errorMsg = responseData['message'] ?? 'Failed to update spare part';
      throw Exception(errorMsg);
    } catch (e) {
      print('Update Error: $e');

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating spare part: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Spare Part'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: conditionController,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: minimumQuantityController,
                      decoration: InputDecoration(
                        labelText: 'Minimum Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.capitalize()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: updateSparePart,
          child: Text('Save Changes'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
          ),
        ),
      ),
    );
  }
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}



// Show dialog for Team Assign
Future<void> _showTeamAssignDialog(BuildContext context, InspectorSpareParts part) async {
  showDialog(
    context: context,
    builder: (context) => AssignTeamDialog(itemId: part.id), // Access the id property directly
  );
}

//===========//


// Team Assign Dialog




class AssignTeamDialog extends StatefulWidget {
  final int itemId;

  const AssignTeamDialog({Key? key, required this.itemId}) : super(key: key);

  @override
  _AssignTeamDialogState createState() => _AssignTeamDialogState();
}

class _AssignTeamDialogState extends State<AssignTeamDialog> {
  List<InspectorTeam> teams = [];
  List<InspectorTeam> selectedTeams = [];
  String stock = '';
  TextEditingController searchController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  bool isLoading = true;

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
                .map((teamData) => InspectorTeam.fromJson(teamData))
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
    bool isAssigning = false;

    if (!selectedTeams.any((team) => int.tryParse(stock) != null && int.parse(stock) > 0)) {
      _showError('Please assign stock to at least one team');
      return;
    }

    try {
      setState(() => isAssigning = true);

      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final teamsToAssign = selectedTeams.map((team) {
        return {
          'id': team.id.toString(),
          'stock': int.parse(stock), // Ensure stock is an integer
        };
      }).toList();

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/assign-teams-to-inventoryItem/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'teams': teamsToAssign}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          _showSuccess(responseData['message'] ?? 'Teams assigned successfully');
          Navigator.pop(context, true);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to assign teams');
        }
      } else {
        throw Exception('Failed to assign teams: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error assigning teams: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isAssigning = false);
      }
    }
  }


  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Teams to Item'),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TypeAheadField<InspectorTeam>(

              suggestionsCallback: (pattern) {
                return teams.where((team) =>
                team.name.toLowerCase().contains(pattern.toLowerCase()) &&
                    !selectedTeams.contains(team)
                ).toList();
              },
              itemBuilder: (context, InspectorTeam team) {
                return ListTile(
                  title: Text(team.name),
                );
              },
              onSelected: (InspectorTeam team) {
                setState(() {
                  selectedTeams.add(team);
                  searchController.clear();
                });
              },
            ),
            SizedBox(height: 16),
            if (selectedTeams.isNotEmpty) ...[
              Text('Selected Teams:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 100, // Fixed height for the list
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedTeams.length,
                  itemBuilder: (context, index) {
                    final team = selectedTeams[index];
                    return ListTile(
                      dense: true,
                      title: Text(team.name),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedTeams.remove(team);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 16),
            TextField(
              controller: stockController,
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
          onPressed: () async {
            if (selectedTeams.isNotEmpty && stock.isNotEmpty) {
              await assignTeamToItem();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select teams and enter stock')),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    stockController.dispose();
    super.dispose();
  }
}


 //  //====================  //





