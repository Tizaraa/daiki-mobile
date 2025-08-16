import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Message/Inspector_message.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Notification/Inspector_Notification.dart';
import 'package:flutter/material.dart';
import 'package:daiki_axis_stp/Presentation/View/FAQ/faq_screen.dart';
import 'package:daiki_axis_stp/Presentation/View/How%20to%20Use/how_to_use.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Authentication/change_password.dart';
import '../Authentication/logout_screen.dart';
import '../Company Profile/company_profile_screen.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_response_table.dart';
import '../Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_schedule.dart';
import '../Inspector HomePage/Inspector Project/nav_Inspector_project_Screen.dart';
import '../Inspector HomePage/Profile/inspector_profile.dart';
import '../Inspector NavBar/Inspector CAR/Inspector_CAR_List.dart';
import '../Inspector NavBar/Inspector Client list/inspector_client_list.dart';
import '../Inspector NavBar/Inspector Group Member/inspector_group_member.dart';
import '../Inspector NavBar/Inspector Inventory/Inspector Create Page/Inspector_inventory_screen.dart';
import 'Inspector_Dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InspectorHomePage extends StatefulWidget {
  const InspectorHomePage({super.key});

  @override
  _InspectorHomePageState createState() => _InspectorHomePageState();
}

class _InspectorHomePageState extends State<InspectorHomePage> {
  Widget _currentScreen = const Inspector_Dashboard();

  // Add these variables to track user data and force refreshes
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  String _profileImageUrl = '';
  Key _drawerKey = UniqueKey();
  Key _profileImageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Add method to load and refresh user data
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userEmail = prefs.getString('user_email') ?? 'Email';
      _userRole = prefs.getString('user_role') ?? 'No Role';
      _profileImageUrl = prefs.getString('user_photo') ??
          prefs.getString('profile_image_url') ??
          'https://minio.johkasou-erp.com/daiki/profile/default';
      _drawerKey = UniqueKey();
      _profileImageKey = UniqueKey();
    });
  }

  void _onMenuItemTapped(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper method for menu categories
  Widget _buildMenuCategory(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Helper method for menu items
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xffffffff),
                Color(0xfffafafa),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black26,
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: SizedBox(
            width: 180.0,
            height: 50.0,
            child: Image.asset(
              'assets/logo.jpeg',
              fit: BoxFit.fill,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xffefdbc0),
                      Color(0xffe68d70),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              offset: const Offset(0, 60),
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              shadowColor: Colors.black38,
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                  // Navigate to profile and refresh data when returning
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InspectorProfilePage(),
                      ),
                    );
                    // Refresh user data when returning from profile
                    await _loadUserData();
                    break;
                  case 'change_password':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                    break;
                  case 'logout':
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  height: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF87DEB5), Color(0xff679590)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<String>(
                  value: 'change_password',
                  height: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.orange.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<String>(
                  value: 'logout',
                  height: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFff9a9e), Color(0xFFfecfef)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        LogoutPage()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffd56e6e),
                    Color(0xffcf5959),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorNotification(),));
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00b894),
                    Color(0xFF00cec9),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.message, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => InspectorMessage(),));
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
        toolbarHeight: 70.0,
      ),
      drawer: Drawer(
        key: _drawerKey, // Add key for drawer refresh
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FAFC), // Light gray-blue
                Color(0xFFE2E8F0), // Slightly darker gray-blue
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Enhanced Drawer Header - Now uses state variables instead of FutureBuilder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFCCE6F1), // Snow white
                      Color(0xFFC8DDEF), // Alice blue
                      Color(0xFFCCEBF8), // Light cyan
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 50, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image (Left side) - Now uses state variable
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profileImageUrl.isNotEmpty && _profileImageUrl != 'https://minio.johkasou-erp.com/daiki/profile/default'
                              ? CachedNetworkImage(
                            key: _profileImageKey, // Add unique key for cache refresh
                            imageUrl: _profileImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            memCacheWidth: 160, // Add memory cache control
                            memCacheHeight: 160,
                            placeholder: (context, url) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.white.withOpacity(0.3),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildFallbackAvatar(),
                          )
                              : _buildFallbackAvatar(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // User Info (Right side - stacked vertically) - Now uses state variables
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // User Name
                            Text(
                              _userName,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            // User Role
                            Text(
                              _userRole,
                              style: GoogleFonts.inter(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // User Email
                            Expanded(
                              child: Text(
                                _userEmail,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: Colors.black.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Menu Items
              _buildMenuItem(
                icon: Icons.dashboard_rounded,
                title: "Dashboard",
                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                onTap: () {
                  _onMenuItemTapped(const Inspector_Dashboard());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.schedule_rounded,
                title: "Maintenance Schedules",
                gradient: const LinearGradient(colors: [Color(0xFF74b9ff), Color(0xFF0984e3)]),
                onTap: () {
                  _onMenuItemTapped(const Inspector_MaintenanceScheduleScreen());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.assessment_rounded,
                title: "Maintenance Report",
                gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)]),
                onTap: () {
                  _onMenuItemTapped(const Inspector_MaintenanceScreenOutput());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.assignment_rounded,
                title: "CAR List",
                gradient: const LinearGradient(colors: [Color(0xFF00b894), Color(0xFF00cec9)]),
                onTap: () {
                  _onMenuItemTapped(TicketsScreen());
                  Navigator.pop(context);
                },
              ),

              _buildMenuItem(
                icon: Icons.work_rounded,
                title: "Projects",
                gradient: const LinearGradient(colors: [Color(0xFFfdcb6e), Color(0xFFe17055)]),
                onTap: () {
                  _onMenuItemTapped(Nav_InspectorProjectListScreen());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.location_city_rounded,
                title: "Site List",
                gradient: const LinearGradient(colors: [Color(0xFF6c5ce7), Color(0xFFa29bfe)]),
                onTap: () {
                  _onMenuItemTapped(ClientScreen());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.groups_rounded,
                title: "Group Member",
                gradient: const LinearGradient(colors: [Color(0xFFfd79a8), Color(0xFFfdcb6e)]),
                onTap: () {
                  _onMenuItemTapped(InspectorGroupMember());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.inventory_2_rounded,
                title: "Inventory",
                gradient: const LinearGradient(colors: [Color(0xFF55a3ff), Color(0xFF003d82)]),
                onTap: () {
                  _onMenuItemTapped(const Inspector_InventoryScreen());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.business_rounded,
                title: "Company Profile",
                gradient: const LinearGradient(colors: [Color(0xFF00b894), Color(0xFF55efc4)]),
                onTap: () {
                  _onMenuItemTapped(CompanyProfileScreen());
                  Navigator.pop(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.help_rounded,
                title: "FAQ",
                gradient: const LinearGradient(colors: [Color(0xFFe17055), Color(0xFFfab1a0)]),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FAQScreen()));
                },
              ),
              _buildMenuItem(
                icon: Icons.info_rounded,
                title: "How to use",
                gradient: const LinearGradient(colors: [Color(0xFF00cec9), Color(0xFF55efc4)]),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HowToUse()));
                },
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_rounded,
                title: "Privacy Policy",
                gradient: const LinearGradient(colors: [Color(0xFF6c5ce7), Color(0xFFfd79a8)]),
                onTap: () async {
                  final Uri url = Uri.parse('https://minio.johkasou-erp.com/daiki/policy/privacy-policy.pdf');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open Privacy Policy')),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),
              // Logout Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFef5350),
                      Color(0xFFf44336),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 22.0),
                          child: Icon(Icons.logout, size: 20, color: Colors.white),
                        ),
                        SizedBox(width: 40),
                        LogoutPage(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFa8edea),
              Color(0xFFfed6e3),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: _currentScreen,
      ),
    );
  }

  // Add fallback avatar widget
  Widget _buildFallbackAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}