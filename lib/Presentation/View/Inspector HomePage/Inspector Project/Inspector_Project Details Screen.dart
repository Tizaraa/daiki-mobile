import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../Model/Inspector_Project_Model.dart';
import 'Inspector_project_API_Service.dart';

class InspectorProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const InspectorProjectDetailScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  _InspectorProjectDetailScreenState createState() =>
      _InspectorProjectDetailScreenState();
}

class _InspectorProjectDetailScreenState
    extends State<InspectorProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  final InspectorProjectsApiService _apiService = InspectorProjectsApiService();
  late Future<Project> _projectFuture;
  Client? _clientDetails;
  List<ProjectUser> _projectUsers = [];
  bool _isLoadingClient = false;
  bool _isLoadingUsers = false;
  late TabController _tabController;

  // Enhanced Color Palette
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color accentColor = Color(0xFF10B981);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color surfaceColor = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _projectFuture = _loadProjectWithDetails();
    _loadProjectUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Project> _loadProjectWithDetails() async {
    Project project = await _apiService.getProjectDetail(widget.projectId);
    if (project.client.name == 'Loading...') {
      setState(() {
        _isLoadingClient = true;
      });
      try {
        _clientDetails = await _apiService.getClientDetail(project.client.id);
      } catch (e) {
        // Handle error silently for now
      } finally {
        setState(() {
          _isLoadingClient = false;
        });
      }
    }
    return project;
  }

  Future<void> _loadProjectUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _projectUsers = [];
    });
    try {
      final users = await _apiService.getProjectUsers(widget.projectId);
      setState(() {
        _projectUsers = users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Project Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Project Status'),
                Tab(text: 'Maintenance Status'),
                Tab(text: 'Capacity'),
                Tab(text: 'Location'),
                Tab(text: 'Project Type'),
                Tab(text: 'Facilities'),
                Tab(text: 'Modules'),
                Tab(text: 'Users'),
                Tab(text: 'Maintenance Schedules'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundLight, surfaceColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Project>(
          future: _projectFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Loading project details...',
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: errorColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: errorColor,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _projectFuture = _loadProjectWithDetails();
                            _loadProjectUsers();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: textMuted.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: textMuted,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No project data found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final project = snapshot.data!;
            final clientToShow = _clientDetails ?? project.client;
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(project, clientToShow),
                _buildProjectStatusTab(project),
                _buildMaintenanceStatusTab(project),
                _buildCapacityTab(project),
                _buildLocationTab(project),
                _buildProjectTypeTab(project),
                _buildFacilitiesTab(project),
                _buildModulesTab(project),
                _buildUsersTab(project),
                _buildMaintenanceSchedulesTab(project),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Project project, Client clientToShow) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'General Information',
            Icons.info_outline_rounded,
            [
              //_buildInfoRow('Project ID', project.projectId.toString()),
              _buildInfoRow('Project Code', project.pjCode),
              _buildInfoRow('Project Name', project.projectName),
              _buildInfoRow('Contracted Date', _formatDate(project.contractedDate)),
              _buildInfoRow('Expire Date', _formatDate(project.expireDate)),
              if (project.remarks != null && project.remarks!.isNotEmpty)
                _buildInfoRow('Remarks', project.remarks!),
              if (project.totalServiceCount != null)
                _buildInfoRow('Total Service Count', project.totalServiceCount.toString()),
              if (project.totalServicedCount != null)
                _buildInfoRow('Total Serviced Count', project.totalServicedCount.toString()),
              if (project.lastServiceMonth != null)
                _buildInfoRow('Last Service Month', project.lastServiceMonth!),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Client Information',
            Icons.person_outline_rounded,
            [
             // _buildInfoRow('ID', clientToShow.id.toString()),
              _buildInfoRow('Name', clientToShow.name),
              if (clientToShow.code.isNotEmpty)
                _buildInfoRow('Code', clientToShow.code),
              _buildInfoRow('Phone', clientToShow.phone),
              _buildInfoRow('Email', clientToShow.email),
              if (clientToShow.address != null)
                _buildInfoRow('Address', clientToShow.address!),
              _buildInfoRow('Type', clientToShow.type),
              if (clientToShow.tin != null)
                _buildInfoRow('TIN', clientToShow.tin!),
              if (clientToShow.bin != null)
                _buildInfoRow('BIN', clientToShow.bin!),
              if (_isLoadingClient)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (clientToShow.company != null)
            _buildSectionCard(
              'Company Information',
              Icons.business_rounded,
              [
               // _buildInfoRow('Company ID', clientToShow.company!.id.toString()),
                _buildInfoRow('Name', clientToShow.company!.name),
                if (clientToShow.company!.companyCode != null)
                  _buildInfoRow('Code', clientToShow.company!.companyCode!),
                if (clientToShow.company!.contactPerson != null)
                  _buildInfoRow('Contact Person', clientToShow.company!.contactPerson!),
                _buildInfoRow('Contact Number', clientToShow.company!.contactNumber),
                _buildInfoRow('Contact Email', clientToShow.company!.contactEmail),
                _buildInfoRow('Contact Address', clientToShow.company!.contactAddress),
                _buildInfoRow('TIN', clientToShow.company!.companyTin),
                _buildInfoRow('BIN', clientToShow.company!.companyBin),
                if (clientToShow.company!.businessType != null)
                  _buildInfoRow('Business Type', clientToShow.company!.businessType!),
              ],
            ),
          const SizedBox(height: 16),
          if (project.bdmName != null)
            _buildSectionCard(
              'Business Development Manager',
              Icons.manage_accounts_rounded,
              [
              //  _buildInfoRow('ID', project.bdmName!.id.toString()),
                _buildInfoRow('Name', project.bdmName!.name),
                if (project.bdmName!.phone != null)
                  _buildInfoRow('Phone', project.bdmName!.phone!),
                if (project.bdmName!.email != null)
                  _buildInfoRow('Email', project.bdmName!.email!),
              ],
            ),
          const SizedBox(height: 16),
          if (project.clientRelation != null)
            _buildSectionCard(
              'Client Relation',
              Icons.connect_without_contact_rounded,
              [
                _buildInfoRow('Name', project.clientRelation!.name),
                _buildInfoRow('Email', project.clientRelation!.email),
                _buildInfoRow('Phone', project.clientRelation!.phone),
                _buildInfoRow('Timezone', project.clientRelation!.timezone),
                _buildInfoRow('Company', project.clientRelation!.company.name),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProjectStatusTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Project Status',
            Icons.assignment_turned_in_rounded,
            [
              if (project.projectStatus != null) ...[
                _buildInfoRow('Service Per Annum', project.projectStatus!.name),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          'Payment Terms:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _buildStatusBadge(
                        project.projectStatus!.status == 1 ? 'Pending' : 'Inactive',
                        project.projectStatus!.status == 1,
                      ),
                    ],
                  ),
                ),
                if (project.projectStatus!.duration != null)
                  _buildInfoRow('Duration', project.projectStatus!.duration.toString()),
                if (project.projectStatus!.servicePerAlumn != null)
                  _buildInfoRow('Service Per Alumn', project.projectStatus!.servicePerAlumn.toString()),
                if (project.projectStatus!.createdAt != null)
                  _buildInfoRow('Created At', _formatDate(project.projectStatus!.createdAt)),
                if (project.projectStatus!.updatedAt != null)
                  _buildInfoRow('Updated At', _formatDate(project.projectStatus!.updatedAt)),
              ] else
                _buildEmptyState('No project status available.', Icons.info_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceStatusTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Maintenance Status',
            Icons.settings_rounded,
            [
              if (project.maintenanceStatus != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name', project.maintenanceStatus!.name),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              'Status:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          _buildStatusBadge(
                            project.maintenanceStatus!.status == 1 ? 'Active' : 'Inactive',
                            project.maintenanceStatus!.status == 1,
                          ),
                        ],
                      ),
                    ),
                    if (project.maintenanceStatus!.createdAt != null)
                      _buildInfoRow('Created At', _formatDate(project.maintenanceStatus!.createdAt)),
                    if (project.maintenanceStatus!.updatedAt != null)
                      _buildInfoRow('Updated At', _formatDate(project.maintenanceStatus!.updatedAt)),
                  ],
                )
              else
                _buildEmptyState('No maintenance status available.', Icons.settings_rounded),
            ],
          ),
          const SizedBox(height: 16),
          if (project.maintenanceScheduleByProject != null)
            _buildSectionCard(
              'Maintenance Schedule Summary',
              Icons.schedule_rounded,
              [
                if (project.maintenanceScheduleByProject!.serviced.isNotEmpty)
                  ...project.maintenanceScheduleByProject!.serviced.map((schedule) =>
                      _buildScheduleCard(schedule, true)
                  ),
                if (project.maintenanceScheduleByProject!.nonServiced.isNotEmpty)
                  ...project.maintenanceScheduleByProject!.nonServiced.map((schedule) =>
                      _buildScheduleCard(schedule, false)
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCapacityTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Capacity',
            Icons.analytics_rounded,
            [
              _buildInfoRow('Capacity', project.capacity),
              if (project.johkasouModel != null)
                _buildInfoRow('Johkasou Model', project.johkasouModel!.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Location',
            Icons.location_on_rounded,
            [
              _buildInfoRow('Location', project.location),
              if (project.projectLocation != null) ...[
                _buildInfoRow('District', project.projectLocation!.district),
                _buildInfoRow('Division', project.projectLocation!.division),
                _buildInfoRow('Country', project.projectLocation!.country),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTypeTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Project Type',
            Icons.category_rounded,
            [
              if (project.projectType != null)
                _buildInfoRow('Type', project.projectType!.name)
              else
                _buildEmptyState('No project type available.', Icons.category_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Project Facilities',
            Icons.apartment_rounded,
            [
              if (project.projectFacilities != null)
                _buildInfoRow('Facilities', project.projectFacilities!.name)
              else
                _buildEmptyState('No project facilities available.', Icons.apartment_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModulesTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Project Modules',
            Icons.view_module_rounded,
            [
              if (project.modules != null && project.modules!.isNotEmpty)
                ...project.modules!.map((module) =>
                    _buildModuleCard(module)
                )
              else
                _buildEmptyState('No modules available.', Icons.view_module_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Project Users',
            Icons.group_rounded,
            [
              if (_isLoadingUsers)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                )
              else if (_projectUsers.isNotEmpty)
                ..._projectUsers.map((user) =>
                    _buildUserCard(user)
                )
              else
                _buildEmptyState('No users assigned to this project.', Icons.group_rounded),
            ],
          ),
          const SizedBox(height: 16),
          if (project.usersForClients != null && project.usersForClients!.isNotEmpty)
            _buildSectionCard(
              'Users for Clients',
              Icons.support_agent_rounded,
              [
                ...project.usersForClients!.map((user) =>
                    _buildUserCard(user)
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSchedulesTab(Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Maintenance Schedules',
            Icons.calendar_today_rounded,
            [
              if (project.maintenanceSchedules != null && project.maintenanceSchedules!.isNotEmpty)
                ...project.maintenanceSchedules!.map((schedule) =>
                    _buildMaintenanceScheduleCard(schedule)
                )
              else
                _buildEmptyState('No maintenance schedules available.', Icons.calendar_today_rounded),
            ],
          ),
          const SizedBox(height: 16),
          if (project.monthlyMaintenanceSummary != null && project.monthlyMaintenanceSummary!.isNotEmpty)
            _buildSectionCard(
              'Monthly Maintenance Summary',
              Icons.bar_chart_rounded,
              [
                ...project.monthlyMaintenanceSummary!.map((summary) =>
                    _buildMonthlySummaryCard(summary)
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [successColor.withOpacity(0.1), successColor.withOpacity(0.2)]
              : [errorColor.withOpacity(0.1), errorColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? successColor.withOpacity(0.3) : errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? successColor : errorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: isActive ? successColor : errorColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: textMuted.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(dynamic schedule, bool isServiced) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isServiced
              ? [successColor.withOpacity(0.05), successColor.withOpacity(0.1)]
              : [warningColor.withOpacity(0.05), warningColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isServiced ? successColor.withOpacity(0.2) : warningColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isServiced ? successColor.withOpacity(0.1) : warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isServiced ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: isServiced ? successColor : warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.taskDescription,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(
                      isServiced ? 'Serviced' : 'Non-Serviced',
                      isServiced,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Schedule Count', schedule.scheduleCount.toString()),
        ],
      ),
    );
  }

  Widget _buildModuleCard(dynamic module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: surfaceColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.view_module_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.module,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildStatusBadge(
                module.status == 1 ? 'Active' : 'Inactive',
                module.status == 1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (module.number != null && module.number!.isNotEmpty)
            _buildInfoRow('Number', module.number!),
          if (module.blowerModel != null && module.blowerModel!.isNotEmpty)
            _buildInfoRow('Blower Model', module.blowerModel!),
          if (module.quantity != null && module.quantity!.isNotEmpty)
            _buildInfoRow('Quantity', module.quantity!),
          if (module.slNumber != null && module.slNumber!.isNotEmpty)
            _buildInfoRow('SL Number', module.slNumber!),
          if (module.commissionaryDate != null && module.commissionaryDate!.isNotEmpty)
            _buildInfoRow('Commissionary Date', _formatDate(module.commissionaryDate)),
          if (module.remark != null && module.remark!.isNotEmpty)
            _buildInfoRow('Remark', module.remark!),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: surfaceColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accentColor.withOpacity(0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (user.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.phone,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.company.name,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceScheduleCard(dynamic schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: surfaceColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: schedule.status == 1 ? successColor.withOpacity(0.1) : warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  schedule.status == 1 ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: schedule.status == 1 ? successColor : warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.taskInfo.taskDescription,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.group.name,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(
                schedule.status == 1 ? 'Serviced' : 'Non-Serviced',
                schedule.status == 1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: surfaceColor),
          const SizedBox(height: 12),
          _buildInfoRow('Maintenance Date', _formatDate(schedule.maintenanceDate)),
          if (schedule.nextMaintenanceDate != null)
            _buildInfoRow('Next Maintenance Date', _formatDate(schedule.nextMaintenanceDate)),
          if (schedule.remarks != null)
            _buildInfoRow('Remarks', schedule.remarks!),
          if (schedule.assignments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_ind_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Assigned Users:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...schedule.assignments.map((assignment) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'User ID: ${assignment.userId}',
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(dynamic summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [surfaceColor.withOpacity(0.3), surfaceColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: surfaceColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary.month,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        summary.totalServiced.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: successColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Serviced',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        summary.totalNonServiced.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: warningColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Non-Serviced',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (summary.schedules.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: surfaceColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Schedules:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...summary.schedules.map((schedule) =>
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: surfaceColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    schedule.taskInfo.taskDescription,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                _buildStatusBadge(
                                  schedule.status == 1 ? 'Serviced' : 'Non-Serviced',
                                  schedule.status == 1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Group', schedule.group.name),
                            _buildInfoRow('Maintenance Date', _formatDate(schedule.maintenanceDate)),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not set';
    try {
      DateTime dateTime = DateTime.parse(dateString);
      final DateFormat dateFormat = DateFormat('dd MMM yyyy, HH:mm');
      return dateFormat.format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}