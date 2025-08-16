import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../Core/Utils/colors.dart';
import '../../../../Model/Inspector_Project_Model.dart';
import 'Inspector_Project Details Screen.dart';
import 'Inspector_project_API_Service.dart';

class Nav_InspectorProjectListScreen extends StatefulWidget {
  @override
  _Nav_InspectorProjectListScreenState createState() => _Nav_InspectorProjectListScreenState();
}

class _Nav_InspectorProjectListScreenState extends State<Nav_InspectorProjectListScreen> {
  final InspectorProjectsApiService _apiService = InspectorProjectsApiService();
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  TextEditingController _searchController = TextEditingController();
  Map<int, bool> _expandedStates = {};
  String? _selectedMaintenanceStatus;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_filterProjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final projects = await _apiService.getProjects();
      setState(() {
        _allProjects = projects;
        _filteredProjects = projects;
        _isLoading = false;
      });
      _filterProjects();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not set';
    try {
      DateTime dateTime = DateTime.parse(dateString);
      final DateFormat dateFormat = DateFormat('yy-MM-dd');
      return dateFormat.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _filterProjects() {
    String query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredProjects = _allProjects.where((project) {
        final projectName = project.projectName.toLowerCase();
        final projectCode = project.pjCode.toLowerCase();
        final contractedDate = project.contractedDate?.toLowerCase() ?? '';

        final matchesSearch = query.isEmpty ||
            projectName.contains(query) ||
            projectCode.contains(query) ||
            contractedDate.contains(query);

        final matchesMaintenance = _selectedMaintenanceStatus == null ||
            (project.maintenanceStatus != null &&
                project.maintenanceStatus!.name.toLowerCase() == _selectedMaintenanceStatus!.toLowerCase());

        return matchesSearch && matchesMaintenance;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Projects", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: TizaraaColors.Tizara,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by Project name or Code',
                        hintText: 'Search by Project name or Code',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0476BD).withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              height: 40,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "SL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    color: Colors.white,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Project Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildProjectList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProjects,
              child: const Text('Retry',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_filteredProjects.isEmpty) {
      return Center(
        child: Text(
          'No projects found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProjects.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final project = _filteredProjects[index];
        _expandedStates.putIfAbsent(index, () => false);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            onExpansionChanged: (bool expanded) {
              setState(() {
                _expandedStates[index] = expanded;
              });
            },
            collapsedBackgroundColor: TizaraaColors.primaryColor2,
            backgroundColor: TizaraaColors.primaryColor,
            leading: Transform.translate(
              offset: const Offset(-7, 0),
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: TizaraaColors.Tizara,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              project.projectName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
                color: Color(0xFF0F4C81),
              ),
            ),
            subtitle: Text(
              _formatDate(project.contractedDate),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: _expandedStates[index]!
                    ? const Color(0xFF0F4C81).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                _expandedStates[index]! ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                color: const Color(0xFF0F4C81),
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color:  TizaraaColors.primaryColor2,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoColumn('Project Code', project.pjCode, Icons.code),
                    _buildInfoColumn('Location', project.location, Icons.location_on),
                    _buildInfoColumn('Customer', project.client.name, Icons.business),
                    _buildInfoColumn('Site Name', project.branch?.name ?? '-', Icons.branding_watermark),
                    //_buildStatusColumn('Maintenance Status', project.maintenanceStatus),
                    _buildInfoColumn('Contracted Date', _formatDate(project.contractedDate), Icons.calendar_today),
                    _buildInfoColumn('Expire Date', _formatDate(project.expireDate), Icons.event_busy),
                    _buildModulesColumn('Modules', project.modules),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 24,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showProjectDetailsBottomSheet(context, project.projectId);
                        },
                        icon: const Icon(Icons.info_outline, color: Colors.white),
                        label: const Text(
                          "More Info",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F4C81),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF0F4C81)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColumn(String label, MaintenanceStatus? status) {
    final statusName = status?.name ?? '-';
    Color statusColor = Colors.grey;
    if (statusName.toLowerCase().contains('active')) {
      statusColor = Colors.green;
    } else if (statusName.toLowerCase().contains('expired') || statusName.toLowerCase().contains('inactive')) {
      statusColor = Colors.red;
    } else if (statusName.toLowerCase().contains('pending')) {
      statusColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 18, color: Color(0xFF0F4C81)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 29.0, top: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                statusName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesColumn(String label, List<ProjectModule>? modules) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list, size: 18, color: Color(0xFF0F4C81)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          modules != null && modules.isNotEmpty
              ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
                child: Row(
                            children: modules.map((module) {
                return Padding(
                  padding: const EdgeInsets.only(left: 7.0, ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: TizaraaColors.Tizara),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: TizaraaColors.primaryColor2,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        module.module,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                );
                            }).toList(),
                          ),
              )
              : const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Not available',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectDetailsBottomSheet(BuildContext context, int projectId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Stack(
              children: [
                const SizedBox(width: 10),
                InspectorProjectDetailScreen(projectId: projectId),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}