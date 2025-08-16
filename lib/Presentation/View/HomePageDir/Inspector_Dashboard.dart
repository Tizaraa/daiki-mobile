import 'package:daiki_axis_stp/Core/Utils/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../Inspector HomePage/Inspector Create CAR/Inspector_Create_CAR.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_response_table.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_schedule.dart';
import '../Inspector HomePage/Inspector Project/nav_Inspector_project_Screen.dart';
import '../Inspector HomePage/Inspector Project/projects_screen.dart';
import '../Inspector NavBar/Inspector Client list/inspector_client_list.dart';
import '../Inspector NavBar/Inspector Group Member/inspector_group_member.dart';
import '../Inspector NavBar/Inspector Group/Inspector Homepage Group/inspector_homepage_group.dart';
import '../Inspector NavBar/Inspector Inventory/Inspector Create Page/Inspector_inventory_screen.dart';
import 'Inspector Completed Task.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'Inspector Pending task.dart';

class Inspector_Dashboard extends StatefulWidget {
  const Inspector_Dashboard({super.key});

  @override
  State<Inspector_Dashboard> createState() => _Inspector_DashboardState();
}

class _Inspector_DashboardState extends State<Inspector_Dashboard> {
  static const Color primaryColor = Color(0xFFDAF4F4);
  static const Color primaryColor2 = Color(0xFFB7D3EA);

  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  late List<Widget> bottomBarPages;

  @override
  void initState() {
    super.initState();

    _checkInitialConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Check token validity immediately when dashboard opens
    _checkTokenValidity();

    // Setup periodic token validation check
    _setupPeriodicTokenCheck();

    bottomBarPages = [
      MainDashboard(),
      Nav_InspectorProjectListScreen(),
      ClientScreen(),
      InspectorGroupMember()
    ];
  }

  // Check token validity periodically
  void _setupPeriodicTokenCheck() {
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _checkTokenValidity();
        _setupPeriodicTokenCheck(); // Setup next check
      }
    });
  }

  // Check if token is valid
  Future<void> _checkTokenValidity() async {
    bool isExpired = await TokenManager.isTokenExpired();
    if (isExpired && mounted) {
      _handleSessionExpiry();
    }
  }

  // Handle session expiry
  void _handleSessionExpiry() {
    // Clear the token
    TokenManager.clearToken();

    // Show expiry message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your session has expired. Please log in again.'),
        backgroundColor: Colors.orange,
      ),
    );

    // Navigate to login page
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivity.onConnectivityChanged.drain();
    super.dispose();
  }

  //===========internet checker start================//

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  Future<void> _checkInitialConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = (result != ConnectivityResult.none);
    });

    if (!_isConnected) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your network connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //=========== internet checker end ================//

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default pop behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitDialog(context);
          if (shouldPop) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: true,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: bottomBarPages,
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xff3fbfb1), // Deep blue
                const Color(0xff92c5c1), // Bright blue
                const Color(0xff11aaa5), // Cyan blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                _pageController.jumpToPage(index);
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.home_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.home, size: 26),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.library_books_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.library_books_rounded, size: 26),
                ),
                label: 'Projects',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.task_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.task, size: 26),
                ),
                label: 'Site List',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.groups_outlined, size: 26),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.groups, size: 26),
                ),
                label: 'Group\nMembers',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  Map<String, int> _menuCounts = {
    "pending_task": 0,
    "completed_task": 0,
    "group": 0,
    "assigned_project": 0,
    "maintenance_schedule": 0,
    "maintenance_report": 0,
    "inventory": 0,
    "car": 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuCounts();
  }

  Future<void> _fetchMenuCounts() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No token found. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/dashboard/menu-count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            _menuCounts = Map<String, int>.from(data['data']);
            _isLoading = false;
          });
        } else {
          throw Exception('API returned status false: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load menu counts: ${response.statusCode}');
      }
    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Error fetching menu counts: $e'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              "Welcome Technician, to Daiki STP Maintenance!",
              style: GoogleFonts.abyssinicaSil(fontSize: 19, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildGradientCard(
                  context,
                  "Pending Tasks",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Inspector_PendingTaskScreen(title: 'Pending Tasks'),
                      ),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.pending_actions,
                  _menuCounts['pending_task']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Completed Tasks",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Inspector_CompletedTaskScreen(
                          title: 'Completed Tasks',
                          hasAbnormalResponse: 0,
                        ),
                      ),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.task_alt,
                  _menuCounts['completed_task']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Groups",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InspectorHomePageGroup()),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.group,
                  _menuCounts['group']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Assigned Projects",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InspectorProjectListScreen()),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.assignment,
                  _menuCounts['assigned_project']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Maintenance Schedule",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Inspector_MaintenanceScheduleScreen()),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.assignment,
                  _menuCounts['maintenance_schedule']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Maintenance Report",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Inspector_MaintenanceScreenOutput()),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.book,
                  _menuCounts['maintenance_report']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Inventory",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Inspector_InventoryScreen()),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.inventory,
                  _menuCounts['inventory']?.toString() ?? '0',
                ),
                _buildGradientCard(
                  context,
                  "Create CAR",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InspectorCreateCAR(),
                      ),
                    );
                  },
                  [Color(0xFFFFFFFF), Color(0xFFDAE5F6)],
                  Icons.token,
                  _menuCounts['car']?.toString() ?? '0',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGradientCard(
      BuildContext context,
      String title,
      VoidCallback? onTap,
      List<Color> gradientColors,
      IconData icon,
      String count,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 105,
        width: (MediaQuery.of(context).size.width - 36) / 2.1,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 30, color: Colors.teal),
                  Text(
                    count,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  style: GoogleFonts.tinos(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _showExitDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Exit'),
        content: const Text('Are you sure you want to exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}