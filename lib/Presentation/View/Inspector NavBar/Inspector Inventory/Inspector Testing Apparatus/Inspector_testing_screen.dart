
import 'package:daiki_axis_stp/Presentation/View/Inspector%20NavBar/Inspector%20Inventory/Inspector%20Testing%20Apparatus/testing%20appartus%20view%20details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../../Core/Utils/api_service.dart';
import '../../../../../Core/Utils/colors.dart';
import 'Inspector_inventory_stoke_model.dart';



class InspectorTestingInventoryScreen extends StatefulWidget {
  const InspectorTestingInventoryScreen({super.key});

  @override
  _InspectorTestingInventoryScreenState createState() => _InspectorTestingInventoryScreenState();
}


class _InspectorTestingInventoryScreenState extends State<InspectorTestingInventoryScreen> {
  List<InspectorInventoryItem> inventoryItems = [];
  List<InspectorInventoryItem> filteredItems = []; // New filtered list
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController(); // Search controller

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
    _searchController.addListener(_filterItems); // Listen to search input changes
  }

  Future<void> fetchInventoryData() async {
    try {
      bool isExpired = await TokenManager.isTokenExpired();
      if (isExpired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
        return;
      }

      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/inventory'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          final items = responseData['data']['testingApparatus'] as List;
          setState(() {
            inventoryItems = items.map((item) => InspectorInventoryItem.fromJson(item)).toList();
            filteredItems = inventoryItems; // Initialize filtered list
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        await TokenManager.clearToken();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        throw Exception('Failed to load inventory: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Filter items based on search query
  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = inventoryItems.where((item) {
        final nameMatch = (item.name ?? '').toLowerCase().contains(query);
        final skuMatch = item.sku.toLowerCase().contains(query);
        final statusMatch = getStatusString(item.status).toLowerCase().contains(query);
        return nameMatch || skuMatch || statusMatch;
      }).toList();
    });
  }

  Future<void> deleteItem(int itemId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('${DaikiAPI.api_key}/api/v1/inventory/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchInventoryData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully')),
        );
      } else if (response.statusCode == 401) {
        await TokenManager.clearToken();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: ${e.toString()}')),
      );
    }
  }

  String getTypeString(int type) {
    switch (type) {
      case 1:
        return 'Inspector Testing Apparatus';
      case 2:
        return 'Inspector Maintenance Kit List';
      default:
        return 'Unknown';
    }
  }

  String getStatusString(int status) {
    switch (status) {
      case 1:
        return 'Active';
      case 0:
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  String formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Testing Apparatus',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: TizaraaColors.Tizara,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, code, or status...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Inventory List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: fetchInventoryData,
              child: filteredItems.isEmpty
                  ? const Center(child: Text('No items found'))
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestingAppartusViewDetails(itemId: item.id),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: TizaraaColors.primaryColor2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                          Text(item.sku, style: const TextStyle(fontSize: 14, color: Colors.black45,),),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('Edit', style: TextStyle(color: Colors.green)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'assign_team',
                                        child: Row(
                                          children: [
                                            Icon(Icons.group_add, color: Colors.blueAccent),
                                            SizedBox(width: 8),
                                            Text('Assign Team', style: TextStyle(color: Colors.blueAccent)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'View Details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove_red_eye, color: Colors.teal),
                                            SizedBox(width: 8),
                                            Text('View Details', style: TextStyle(color: Colors.teal)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditInventoryItemScreen(item: item),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text('Are you sure you want to delete this item?'),
                                            actions: [
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: const Text('Delete'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  deleteItem(item.id);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (value == 'assign_team') {
                                        _showTeamAssignDialog(context, item);
                                      } else if (value == 'View Details') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TestingAppartusViewDetails(itemId: item.id),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(item.description),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Code',
                                    value: item.sku.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Type',
                                    value: getTypeString(item.type),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Unit',
                                    value: item.unit,
                                  ),
                                ),
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Stock',
                                    value: item.stock.quantity.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Min Stock',
                                    value: item.stock.minimumQuantity.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: _InfoTile(
                                    label: 'condition',
                                    value: item.condition.toString(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Last Calibrated Date',
                                    value: formatDate(item.lastCalibrationDate),
                                  ),
                                ),
                                Expanded(
                                  child: _InfoTile(
                                    label: 'Next Calibration Date',
                                    value: formatDate(item.calibrationTime),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.status == 1
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                getStatusString(item.status),
                                style: TextStyle(
                                  color: item.status == 1 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _showTeamAssignDialog(BuildContext context, InspectorInventoryItem item) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/team-list/${item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          List<Team> teams = (responseData['data']['team'] as List)
              .map((teamData) => Team.fromJson(teamData))
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignNewTeamPage(
                itemId: item.id,
                teams: teams,
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to fetch teams');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}



// Assign New Team Page



class AssignNewTeamPage extends StatefulWidget {
  final int itemId;
  final List<Team> teams;

  const AssignNewTeamPage({
    Key? key,
    required this.itemId,
    required this.teams,
  }) : super(key: key);

  @override
  _AssignNewTeamPageState createState() => _AssignNewTeamPageState();
}

class _AssignNewTeamPageState extends State<AssignNewTeamPage> {
  String? selectedTeam;
  String stock = '';
  String? selectedTeamName;
  TextEditingController _typeAheadController = TextEditingController(); // Add this line

  Future<void> assignTeamToItem() async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/assign-teams-to-inventoryItem/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'teams': [
            {
              'id': selectedTeam,
              'stock': stock,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team & Stock Updated Successfully!')),
        );
        // Pop twice to return to the original screen
        Navigator.of(context).pop();

      } else {
        throw Exception('Failed to assign team: Status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning team: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign New Team'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF03106C)),
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: TypeAheadField(
                controller: _typeAheadController, // Add this line
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
                    final selectedTeamObj = widget.teams.firstWhere(
                          (team) => team.name == suggestion,
                    );
                    setState(() {
                      selectedTeam = selectedTeamObj.id.toString();
                      selectedTeamName = suggestion;
                      _typeAheadController.text = suggestion; // Add this line
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error selecting team')),
                    );
                  }
                },
                suggestionsCallback: (pattern) {
                  return widget.teams
                      .where((team) => team.name.toLowerCase().contains(pattern.toLowerCase()))
                      .map((team) => team.name)
                      .toList();
                },
                hideOnEmpty: true,
              ),
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
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Assign Team'),
              onPressed: () {
                if (selectedTeam == null || stock.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a team and enter stock')),
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
        ),
      ),
    );
  }
}







// Team Model
class Team {
  final int id;
  final String name;
  int stock;

  Team({
    required this.id,
    required this.name,
    this.stock = 0,
  });

  // Add fromJson factory constructor
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      name: json['name'] as String,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stock': stock,
    };
  }
}



// New screen for team assignment
class TeamAssignScreen extends StatefulWidget {
  final InspectorInventoryItem item;

  const TeamAssignScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  _TeamAssignScreenState createState() => _TeamAssignScreenState();
}

class _TeamAssignScreenState extends State<TeamAssignScreen> {
  List<Team> teams = [];
  bool isLoading = true;
  bool isAssigning = false;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    try {
      setState(() => isLoading = true);

      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/team-list/${widget.item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (!mounted) return;

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
          throw Exception(responseData['message'] ?? 'Failed to load teams');
        }
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showError('Error fetching teams: ${e.toString()}');
    }
  }

  Future<void> assignTeamsToItem() async {
    if (!teams.any((team) => team.stock > 0)) {
      _showError('Please assign stock to at least one team');
      return;
    }

    try {
      setState(() => isAssigning = true);

      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final teamsToAssign = teams.where((team) => team.stock > 0).toList();

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/assign-teams-to-inventoryItem/${widget.item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'teams': teamsToAssign.map((team) => team.toJson()).toList(),
        }),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Teams to Item'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: ${widget.item.name}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (teams.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No teams available'),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Assignment',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...teams.map((team) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                team.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Stock for ${team.name}',
                                  border: const OutlineInputBorder(),
                                  hintText: 'Enter stock quantity',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    team.stock = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isAssigning ? null : assignTeamsToItem,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: isAssigning
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Text('Assign Teams and Stock'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}







class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

//=======================//

class EditInventoryItemScreen extends StatefulWidget {
  final InspectorInventoryItem item;

  const EditInventoryItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  _EditInventoryItemScreenState createState() =>
      _EditInventoryItemScreenState();
}

class _EditInventoryItemScreenState extends State<EditInventoryItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  late TextEditingController _calibrationTimeController;
  late TextEditingController _lastCalibrationDateController;
  late TextEditingController _quantityController;
  late TextEditingController _minimumQuantityController;

  String _condition = 'good';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _unitController = TextEditingController(text: widget.item.unit);
    _calibrationTimeController = TextEditingController(text: widget.item.calibrationTime);
    _lastCalibrationDateController = TextEditingController(text: widget.item.lastCalibrationDate);

    // Add controllers for new fields
    _quantityController = TextEditingController(
        text: widget.item.stock.quantity.toString()
    );
    _minimumQuantityController = TextEditingController(
        text: widget.item.stock.minimumQuantity.toString()
    );
  }

  Future<void> updateItem() async {
    try {
      // Validate form before submission
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Check token
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare the request body with all required fields
      Map<String, dynamic> requestBody = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'unit': _unitController.text.trim(),
        'type': widget.item.type,
        'status': widget.item.status,

        // Required fields from error message
        'quantity': int.parse(_quantityController.text.trim()),
        'minimum_quantity': int.parse(_minimumQuantityController.text.trim()),
        'condition': _condition,
      };

      // Optional fields
      if (_calibrationTimeController.text.isNotEmpty) {
        requestBody['calibration_time'] = _calibrationTimeController.text.trim();
      }
      if (_lastCalibrationDateController.text.isNotEmpty) {
        requestBody['last_calibration_date'] = _lastCalibrationDateController.text.trim();
      }

      // Debug print
      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.put(
        Uri.parse('${DaikiAPI.api_key}/api/v1/inventory/${widget.item.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Debug print
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Parse the response
      final responseData = json.decode(response.body);

      // Handle response
      if (response.statusCode == 200) {
        // Check for success based on the actual response structure
        if (responseData['success'] == true ||
            responseData['status'] == true ||
            responseData['message']?.contains('updated successfully') == true) {

          // Use a more robust navigation and feedback mechanism
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ?? 'Item updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          });
          return; // Exit the method to prevent further error handling
        }
      }

      // If we reach here, something went wrong
      throw Exception(responseData['message'] ?? 'Unexpected response');
    } catch (e) {
      print('Update Error: $e');

      // Use a more informative error message
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Show error snackbar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
        title: const Text('Edit Inventory Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _calibrationTimeController,
                decoration: InputDecoration(
                  labelText: 'Calibration Time',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastCalibrationDateController,
                decoration: InputDecoration(
                  labelText: 'Last Calibration Date',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // New fields for quantity and condition
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _minimumQuantityController,
                decoration: InputDecoration(
                  labelText: 'Minimum Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Minimum Quantity is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: ['good', 'fair', 'poor']
                    .map((condition) => DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _condition = value;
                    });
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: updateItem,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
