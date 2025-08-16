import 'package:daiki_axis_stp/Core/Utils/colors.dart';
import 'package:daiki_axis_stp/Presentation/View/Authentication/bio-metric_password.dart';
import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector-HomePage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        String? userRole = prefs.getString('user_role');
        _navigateBasedOnRole(userRole, token);
      }
    }
  }

  void _navigateBasedOnRole(String? role, String? token) {
    if (!mounted) return;

    if (role?.toLowerCase() == 'technician') {
      Navigator.of(context).pushNamedAndRemoveUntil('/inspector-homepage', (route) => false);
    } else if (role?.toLowerCase() == 'manager') {
      // Navigator.pushReplacement(context, MaterialPageRoute(
      //     builder: (context) => ManagerHomepage(token: token ?? ''),
      //   ),
      // );
    } else if (role?.toLowerCase() == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InspectorHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InspectorHomePage()),
      );
    }
  }

  Future<void> _showSuccessDialog(String userName, String roleName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00B2AE),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Login Successful',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B2AE),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B2AE),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.badge,
                        color: Color(0xFFFFFFFF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        roleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00B2AE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B2AE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final token = await TokenManager.getToken();
                  _navigateBasedOnRole(roleName, token);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);
      if (kDebugMode) {
        print('Login response: $data');
      }

      if (response.statusCode == 200 && data['status'] == true) {
        final prefs = await SharedPreferences.getInstance();

        String? userId = data['user']?['id']?.toString() ?? data['id']?.toString();
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID missing in login response');
        }

        await TokenManager.saveToken(
          data['access_token'] ?? '',
          data['expires_in'] ?? 0,
          data['refresh_token'] ?? '',
          userId,
        );
        if (kDebugMode) {
          print('Stored user_id: ${await TokenManager.getUserId()}');
        }

        final userName = data['user']?['name'] ?? 'No Name';
        final userEmail = data['user']?['email'] ?? '';
        final userPhone = data['user']?['phone'] ?? '';
        final userPassword = _passwordController.text;
        // Construct full profile image URL using the photo field
        final profileImageUrl = data['user']?['photo'] != null
            ? 'https://minio.johkasou-erp.com/daiki/profile/${data['user']['photo']}'
            : 'https://minio.johkasou-erp.com/daiki/profile/default';

        await prefs.setString('user_name', userName);
        await prefs.setString('user_email', userEmail);
        await prefs.setString('user_phone', userPhone);
        await prefs.setString('user_password', userPassword);
        await prefs.setString('profile_image_url', profileImageUrl);

        String? roleName;
        if (data['user']?['roles'] != null &&
            data['user']['roles'] is List &&
            data['user']['roles'].isNotEmpty) {
          roleName = data['user']['roles'][0]['name'] ?? 'User';
          if (kDebugMode) {
            print('Extracted role name: $roleName');
          }
          await prefs.setString('user_role', roleName!);
        } else {
          await prefs.setString('user_role', 'User');
        }

        String message = data['message'] ?? 'Login successful!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );

        await _showSuccessDialog(userName, roleName ?? 'User');
      } else {
        String errorMessage = data['message'] ?? 'Login failed. Please check your credentials.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive dimensions
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;
            final double padding = screenWidth > 600 ? 40.0 : 15.0; // Larger padding for tablets
            final double formWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85; // Limit form width on large screens
            final double fontSizeTitle = screenWidth > 600 ? 32.0 : 28.0; // Responsive title font
            final double buttonHeight = screenWidth > 600 ? 60.0 : 50.0; // Responsive button height
            final double iconSize = screenWidth > 600 ? 60.0 : 50.0; // Responsive fingerprint icon size
            final double spacing = screenWidth > 600 ? 24.0 : 16.0; // Responsive spacing

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  // Background image
                  SizedBox(
                    height: screenHeight,
                    width: screenWidth,
                    child: Image.asset(
                      'assets/background.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text(
                            'Background image not found',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Form content
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: formWidth),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: screenHeight * 0.2), // Responsive top spacing
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05), // Responsive spacing
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: spacing),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscureText = !_obscureText);
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 5) {
                                    return 'Password must be at least 5 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: spacing * 1.5),
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TizaraaColors.Tizara,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                    'Login',
                                    style: TextStyle(fontSize: screenWidth > 600 ? 20 : 18),
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing * 1.25),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/forget-password', (Route<dynamic> route) => false);
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Forget Password?",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth > 600 ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing * 0.625),
                              Container(
                                height: iconSize,
                                width: iconSize,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(iconSize / 2),
                                  color: TizaraaColors.Tizara,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.all(iconSize * 0.2),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AuthWrapper()),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.fingerprint,
                                    size: iconSize * 0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}