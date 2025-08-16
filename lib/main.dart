
import 'package:daiki_axis_stp/Presentation/View/Authentication/change_password.dart';
import 'package:daiki_axis_stp/Presentation/View/Authentication/forget_password.dart';
import 'package:daiki_axis_stp/Presentation/View/Authentication/logout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Presentation/View/Authentication/login_screen.dart';
import 'Presentation/View/HomePageDir/Inspector-HomePage.dart';
import 'Presentation/View/HomePageDir/Inspector_Dashboard.dart';
import 'Presentation/View/Inspector HomePage/Inspector Maintenance_Response/Inspector_maintenance_schedule.dart';
import 'Presentation/View/Inspector HomePage/Inspector Project/projects_screen.dart';
import 'Presentation/View/Inspector NavBar/Inspector Group/Inspector Homepage Group/inspector_homepage_group.dart';
import 'Presentation/View/Splash/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('data_box');
  debugPrintRebuildDirtyWidgets = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     // showPerformanceOverlay: true,
      title: 'Daiki Axis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF00B2AE),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash_screen',
      routes: {
        '/splash_screen': (context) =>  AnimatedSplashScreen(nextScreen: LoginPage()),
        '/login': (context) =>  LoginPage(),
        '/logout': (context) =>  LogoutPage(),
        '/change-password': (context) =>  ChangePasswordScreen(),
        '/forget-password': (context) =>  ForgetPasswordScreen(),
        '/home': (context) => const InspectorHomePage(),
      //  '/inspector-question-page': (context) => const InspectorQuestionpage(),
        '/inspector-homepage': (context) => const InspectorHomePage(),
       // '/manager-homepage': (context) => ManagerHomepage(token: '',),
        '/Inspector_Dashboard': (context) => Inspector_Dashboard(),
        '/Inspector_homepage_group': (context) => InspectorHomePageGroup(),
        '/InspectorProjectListScreen': (context) => InspectorProjectListScreen(),
        '/Inspector_MaintenanceScheduleScreen': (context) => Inspector_MaintenanceScheduleScreen(),

      },
    );
  }
}

