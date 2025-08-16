// app/routes.dart

import 'package:daiki_axis_stp/Presentation/View/Company%20Profile/company_profile_screen.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector%20Completed%20Task.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector%20Pending%20task.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector-HomePage.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_Dashboard.dart';
import 'package:daiki_axis_stp/Presentation/View/How%20to%20Use/how_to_use.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Create%20CAR/Inspector_Create_CAR.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Maintenance_Response/Inspector_maintenance_response_table.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20HomePage/Inspector%20Maintenance_Response/Inspector_maintenance_schedule.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20NavBar/Inspector%20Client%20list/inspector_client_list.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20NavBar/Inspector%20Group%20Member/inspector_group_member.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20NavBar/Inspector%20Group/inspector_group.dart';
import 'package:daiki_axis_stp/Presentation/View/Inspector%20NavBar/Inspector%20Inventory/Inspector%20Create%20Page/Inspector_inventory_screen.dart';
import 'package:daiki_axis_stp/Presentation/View/Splash/splash_screen.dart';
import 'package:flutter/material.dart';
import '../Presentation/View/Authentication/change_password.dart';
import '../Presentation/View/Authentication/login_screen.dart';
import '../Presentation/View/FAQ/faq_screen.dart';
import '../Presentation/View/Privacy Policy/privacy_policy.dart';


class AppRoutes {
  // Route names as constants
  static const String splash = '/';
  static const String login = '/login';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Task routes
  static const String taskList = '/tasks';
  static const String pendingTasks = '/tasks/pending';
  static const String completedTasks = '/tasks/completed';
  static const String questionPage = '/tasks/questions';

  // CAR routes
  static const String carList = '/cars';
  static const String createCar = '/cars/create';
  static const String carDetails = '/cars/details';
  static const String editCar = '/cars/edit';

  // Group routes
  static const String groupList = '/groups';
  static const String assignGroup = '/groups/assign';
  static const String groupMembers = '/groups/members';

  // Other feature routes
  static const String inventory = '/inventory';
  static const String maintenanceSchedule = '/maintenance/schedule';
  static const String maintenanceResponse = '/maintenance/response';

  // Settings routes
  static const String siteList = '/settings/sites';
  static const String companyProfile = '/settings/company-profile';
  static const String faq = '/settings/faq';
  static const String howToUse = '/settings/how-to-use';
  static const String privacyPolicy = '/settings/privacy-policy';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Auth Routes
      case splash:
        return _buildRoute(AnimatedSplashScreen(nextScreen: LoginPage()), settings);

      case login:
        return _buildRoute(LoginPage(), settings);

      case changePassword:
        return _buildRoute(ChangePasswordScreen(), settings);

    // Main App Routes
      case home:
        return _buildRoute(InspectorHomePage(), settings);

      case dashboard:
        return _buildRoute(Inspector_Dashboard(), settings);

    // Task Routes
      case taskList:
        return _buildRoute(ClientScreen(), settings);

      case pendingTasks:
        return _buildRoute(Inspector_PendingTaskScreen(title: 'Pending Task'), settings);

      case completedTasks:
        return _buildRoute(Inspector_CompletedTaskScreen(title: 'Completed Task', hasAbnormalResponse: 0,), settings);


    // CAR Routes


      case createCar:
        return _buildRoute(InspectorCreateCAR(), settings);


    // Group Routes
      case groupList:
        return _buildRoute(InspectorGroup(), settings);

      case groupMembers:
        return _buildRoute(InspectorGroupMember(), settings);


    // Other Feature Routes
      case inventory:
        return _buildRoute(Inspector_InventoryScreen(), settings);

      case maintenanceSchedule:
        return _buildRoute(Inspector_MaintenanceScheduleScreen(), settings);

      case maintenanceResponse:
        return _buildRoute(Inspector_MaintenanceScreenOutput(), settings);

    // Settings Routes
      case siteList:
        return _buildRoute(ClientScreen(), settings);

      case companyProfile:
        return _buildRoute(CompanyProfileScreen(), settings);

      case faq:
        return _buildRoute(FAQScreen(), settings);

      case howToUse:
        return _buildRoute(HowToUse(), settings);

      case privacyPolicy:
        return _buildRoute(PrivacyPolicyPage(), settings);

    // Default case - route not found
      default:
        return _buildErrorRoute('Route not found: ${settings.name}');
    }
  }

  // Helper method to build routes with consistent transition
  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right to left
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  // Helper method to build fade route (for special cases like splash)
  static Route<dynamic> _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 500),
    );
  }

  // Error route for invalid routes
  static Route<dynamic> _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Navigation Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    splash,
                        (route) => false,
                  );
                },
                child: Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      login,
          (route) => false,
    );
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      home,
          (route) => false,
    );
  }






  // Method to check if user is authenticated
  static String getInitialRoute() {

    return splash;
  }
}