
import 'package:daiki_axis_stp/Presentation/View/Authentication/login_screen.dart';
import 'package:daiki_axis_stp/Presentation/View/Splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Utils/api_service.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Debug print
      print('Retrieved token for logout: $token');

      if (token == null || token.isEmpty) {
        print('No token found in SharedPreferences');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Make logout API call
      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/v1/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Logout Response Status: ${response.statusCode}');
      print('Logout Response Body: ${response.body}');

      await prefs.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
       // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
      }
    } catch (e) {
      print('Logout Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      //icon: const Icon(Icons.logout,color: Colors.indigo,size: 20,),
      label: const Text('Log Out',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
      onPressed: () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                      logout(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnimatedSplashScreen(nextScreen: LoginPage(),)),
                      );
                    });
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}