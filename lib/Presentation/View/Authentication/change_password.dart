import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _showPasswordHint = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Modern color scheme
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4ECDC4);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color darkTextColor = Color(0xFF2C3E50);
  static const Color lightTextColor = Color(0xFF7F8C8D);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Strong password validation function
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  // Function to get password strength indicator
  Widget _buildPasswordStrengthIndicator(String password) {
    List<bool> criteria = [
      password.length >= 8,
      password.contains(RegExp(r'[A-Z]')),
      password.contains(RegExp(r'[a-z]')),
      password.contains(RegExp(r'[0-9]')),
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    ];

    int strengthCount = criteria.where((c) => c).length;
    Color strengthColor = strengthCount < 3 ? errorColor :
    strengthCount < 5 ? warningColor : successColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Password Strength: ${strengthCount < 3 ? "Weak" : strengthCount < 5 ? "Medium" : "Strong"}',
          style: TextStyle(
            color: strengthColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strengthCount / 5,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
      ],
    );
  }

  // Function to build password requirements hint
  Widget _buildPasswordHint() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Password Requirements:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirementItem('At least 8 characters', _newPasswordController.text.length >= 8),
          _buildRequirementItem('One uppercase letter (A-Z)', _newPasswordController.text.contains(RegExp(r'[A-Z]'))),
          _buildRequirementItem('One lowercase letter (a-z)', _newPasswordController.text.contains(RegExp(r'[a-z]'))),
          _buildRequirementItem('One number (0-9)', _newPasswordController.text.contains(RegExp(r'[0-9]'))),
          _buildRequirementItem('One special character (!@#\$%^&*)', _newPasswordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isValid ? successColor : errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isValid ? successColor : errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get token from token manager
      final token = await TokenManager.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Authentication token not found. Please login again.');
        return;
      }

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/auth/change-password-mobile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': _currentPasswordController.text,
          'password': _newPasswordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Success - show success dialog and then logout
        _showSuccessDialog();
        _clearForm();
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired
        _showErrorDialog('Session expired. Please login again.');
      } else {
        // Other errors
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to change password';

        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('errors')) {
            // Handle validation errors
            final errors = errorData['errors'];
            if (errors is Map<String, dynamic>) {
              final errorList = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  errorList.addAll(value.map((e) => e.toString()));
                }
              });
              errorMessage = errorList.join('\n');
            }
          }
        }

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Network error. Please check your connection and try again.');
    }
  }

  Future<void> _performLogout() async {
    try {
      // Clear token from token manager
      await TokenManager.clearToken();

      // Navigate to login screen and clear all previous routes
      // Adjust the route name according to your app's routing structure
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // Replace with your actual login route
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // If there's an error during logout, still navigate to login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // Replace with your actual login route
            (Route<dynamic> route) => false,
      );
    }
  }

  void _clearForm() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  successColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: successColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: successColor.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Password Changed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Your password has been changed successfully. For security reasons, you will be logged out automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: lightTextColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _performLogout(); // Logout and navigate to login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Continue to Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  errorColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: errorColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: errorColor.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: lightTextColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    required IconData icon,
    bool isNewPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkTextColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            validator: validator,
            onChanged: isNewPassword ? (value) {
              setState(() {
                _showPasswordHint = value.isNotEmpty && !_isStrongPassword(value);
              });
            } : null,
            style: TextStyle(
              fontSize: 16,
              color: darkTextColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: lightTextColor.withOpacity(0.7),
                fontSize: 15,
              ),
              suffixIcon: Container(
                margin: EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isNewPassword)
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showPasswordHint = !_showPasswordHint;
                          });
                        },
                        tooltip: 'Show password requirements',
                      ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isVisible ? Icons.visibility_off : Icons.visibility,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      onPressed: onToggleVisibility,
                    ),
                  ],
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: errorColor, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: errorColor, width: 2),
              ),
              filled: true,
              fillColor: cardColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),

        // Show password strength indicator for new password
        if (isNewPassword && controller.text.isNotEmpty)
          _buildPasswordStrengthIndicator(controller.text),

        // Show password requirements hint for new password
        if (isNewPassword && _showPasswordHint)
          _buildPasswordHint(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              backgroundColor,
              backgroundColor,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Section
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [primaryColor, secondaryColor],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        spreadRadius: 0,
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Secure Your Account',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Create a strong password to keep your account safe and secure',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: lightTextColor,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12),

                          // Form Section
                          Container(
                            padding: EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Current Password Field
                                _buildPasswordField(
                                  label: 'Current Password',
                                  hint: 'Enter your current password',
                                  controller: _currentPasswordController,
                                  isVisible: _isCurrentPasswordVisible,
                                  icon: Icons.key,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Current password is required';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 12),

                                // New Password Field
                                _buildPasswordField(
                                  label: 'New Password',
                                  hint: 'Create a strong password',
                                  controller: _newPasswordController,
                                  isVisible: _isNewPasswordVisible,
                                  icon: Icons.security,
                                  isNewPassword: true,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isNewPasswordVisible = !_isNewPasswordVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'New password is required';
                                    }
                                    if (!_isStrongPassword(value)) {
                                      return 'Password must meet all security requirements';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 12),

                                // Confirm Password Field
                                _buildPasswordField(
                                  label: 'Confirm New Password',
                                  hint: 'Confirm your new password',
                                  controller: _confirmPasswordController,
                                  isVisible: _isConfirmPasswordVisible,
                                  icon: Icons.check_circle_outline,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12),

                          // Change Password Button
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isLoading
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'Updating Password...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}