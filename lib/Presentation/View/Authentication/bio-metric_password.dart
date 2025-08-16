import 'package:daiki_axis_stp/Presentation/View/HomePageDir/Inspector_Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isRegistered = prefs.getBool('isRegistered') ?? false;

    setState(() {
      _isRegistered = isRegistered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isRegistered ? const BiometricLoginScreen() : const BiometricRegistrationScreen();
  }
}

/// Enhanced Registration Screen
class BiometricRegistrationScreen extends StatefulWidget {
  const BiometricRegistrationScreen({super.key});

  @override
  State<BiometricRegistrationScreen> createState() => _BiometricRegistrationScreenState();
}

class _BiometricRegistrationScreenState extends State<BiometricRegistrationScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoading = false;
  String _statusMessage = '';
  BiometricStatus _status = BiometricStatus.initial;
  List<BiometricType> _availableBiometrics = [];

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricCapabilities();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  Future<void> _checkBiometricCapabilities() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool deviceSupported = await _auth.isDeviceSupported();
      final List<BiometricType> available = await _auth.getAvailableBiometrics();

      setState(() {
        _availableBiometrics = available;
      });

      if (!canCheck || !deviceSupported) {
        _updateStatus(BiometricStatus.unsupported,
            'This device does not support biometric authentication');
      } else if (available.isEmpty) {
        _updateStatus(BiometricStatus.notEnrolled,
            'No biometric credentials are enrolled on this device');
      } else {
        _updateStatus(BiometricStatus.ready,
            'Ready to register with ${_getBiometricTypeString(available)}');
      }
    } catch (e) {
      _updateStatus(BiometricStatus.error, 'Error checking biometric capabilities: $e');
    }
  }

  String _getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (types.contains(BiometricType.iris)) return 'Iris';
    return 'Biometrics';
  }

  void _updateStatus(BiometricStatus status, String message) {
    setState(() {
      _status = status;
      _statusMessage = message;
    });
  }

  Future<void> _registerBiometric() async {
    if (_status != BiometricStatus.ready) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Authenticating with server...';
    });

    try {
      // Step 1: Authenticate with the server using email and password
      final response = await http.post(
        Uri.parse('https://backend.johkasou-erp.com/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': 'technician@gmail.com',
          'password': 'password',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Save token and user data
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

        await prefs.setString('user_email', 'technician@gmail.com');
        await prefs.setString('user_password', 'password');
        await prefs.setString('user_name', data['user']?['name'] ?? 'Technician');
        await prefs.setString('user_role', data['user']?['roles']?[0]['name'] ?? 'User');

        // Step 2: Perform biometric authentication
        _updateStatus(BiometricStatus.authenticating, 'Please verify your identity');
        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Register your biometric authentication to secure your account',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (didAuthenticate) {
          await prefs.setBool('isRegistered', true);
          await prefs.setInt('registrationDate', DateTime.now().millisecondsSinceEpoch);

          _updateStatus(BiometricStatus.success, 'Registration successful!');

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const Inspector_Dashboard(),
                transitionDuration: const Duration(milliseconds: 800),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: child,
                  );
                },
              ),
            );
          }
        } else {
          _updateStatus(BiometricStatus.failed, 'Biometric authentication was cancelled or failed');
          _shakeController.forward().then((_) => _shakeController.reset());
        }
      } else {
        String errorMessage = data['message'] ?? 'Login failed. Please check your credentials.';
        _updateStatus(BiometricStatus.error, errorMessage);
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Authentication error';
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometric credentials are enrolled';
          break;
        case 'PasscodeNotSet':
          errorMessage = 'Please set up a passcode first';
          break;
        default:
          errorMessage = e.message ?? 'Unknown error occurred';
      }
      _updateStatus(BiometricStatus.error, errorMessage);
      _shakeController.forward().then((_) => _shakeController.reset());
    } catch (e) {
      _updateStatus(BiometricStatus.error, 'Error: $e');
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildBiometricIcon() {
    IconData icon = Icons.fingerprint;
    Color color = Theme.of(context).colorScheme.primary;

    if (_availableBiometrics.contains(BiometricType.face)) {
      icon = Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      icon = Icons.fingerprint;
    }

    switch (_status) {
      case BiometricStatus.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case BiometricStatus.failed:
      case BiometricStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case BiometricStatus.unsupported:
      case BiometricStatus.notEnrolled:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        break;
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _status == BiometricStatus.ready ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 60, color: color),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'Secure Registration',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Set up biometric authentication to protect your account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Biometric Icon
              _buildBiometricIcon(),

              const SizedBox(height: 40),

              // Status Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _statusMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Action Button
              if (_status == BiometricStatus.ready)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerBiometric,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _availableBiometrics.contains(BiometricType.face)
                              ? Icons.face
                              : Icons.fingerprint,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Register Biometric',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_status == BiometricStatus.notEnrolled)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Open device settings - this varies by platform
                      HapticFeedback.lightImpact();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    child: const Text('Open Device Settings'),
                  ),
                ),

              const SizedBox(height: 20),

              // Skip/Demo button for testing
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('isRegistered');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration cleared for testing')),
                  );
                },
                child: Text(
                  'Clear Registration (Testing)',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Login Screen
class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoading = false;
  String _statusMessage = 'Welcome back! Please authenticate to continue';
  BiometricStatus _status = BiometricStatus.initial;
  List<BiometricType> _availableBiometrics = [];

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricCapabilities();
    // Auto-trigger authentication after a short delay
    Future.delayed(const Duration(milliseconds: 1500), _authenticateUser);
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  Future<void> _checkBiometricCapabilities() async {
    try {
      final List<BiometricType> available = await _auth.getAvailableBiometrics();
      setState(() {
        _availableBiometrics = available;
        _status = available.isNotEmpty ? BiometricStatus.ready : BiometricStatus.notEnrolled;
      });
    } catch (e) {
      setState(() {
        _status = BiometricStatus.error;
        _statusMessage = 'Error checking biometric capabilities';
      });
    }
  }

  Future<void> _authenticateUser() async {
    if (_status != BiometricStatus.ready) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Authenticating with server...';
    });

    try {
      // Step 1: Retrieve stored credentials
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? 'technician@gmail.com';
      final password = prefs.getString('user_password') ?? 'password';

      // Step 2: Authenticate with the server
      final response = await http.post(
        Uri.parse('https://backend.johkasou-erp.com/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Save token
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

        // Step 3: Perform biometric authentication
        setState(() {
          _statusMessage = 'Please verify your identity';
        });

        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Authenticate to access your secure account',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (didAuthenticate) {
          setState(() {
            _status = BiometricStatus.success;
            _statusMessage = 'Authentication successful!';
          });

          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const Inspector_Dashboard(),
                transitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        } else {
          setState(() {
            _status = BiometricStatus.failed;
            _statusMessage = 'Biometric authentication failed or was cancelled';
          });
          _shakeController.forward().then((_) => _shakeController.reset());
        }
      } else {
        String errorMessage = data['message'] ?? 'Login failed. Please check your credentials.';
        setState(() {
          _status = BiometricStatus.error;
          _statusMessage = errorMessage;
        });
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    } on PlatformException catch (e) {
      setState(() {
        _status = BiometricStatus.error;
        _statusMessage = _getErrorMessage(e.code);
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    } catch (e) {
      setState(() {
        _status = BiometricStatus.error;
        _statusMessage = 'Error: $e';
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'NotAvailable':
        return 'Biometric authentication is not available';
      case 'NotEnrolled':
        return 'No biometric credentials are enrolled';
      case 'PasscodeNotSet':
        return 'Please set up a device passcode first';
      case 'LockedOut':
        return 'Too many failed attempts. Please try again later';
      default:
        return 'Authentication error occurred';
    }
  }

  Widget _buildBiometricIcon() {
    IconData icon = Icons.fingerprint;
    Color color = Theme.of(context).colorScheme.primary;

    if (_availableBiometrics.contains(BiometricType.face)) {
      icon = Icons.face;
    }

    switch (_status) {
      case BiometricStatus.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case BiometricStatus.failed:
      case BiometricStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        break;
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _status == BiometricStatus.ready ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 70, color: color),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('isRegistered');
              await prefs.remove('user_email');
              await prefs.remove('user_password');
              await prefs.remove('user_name');
              await prefs.remove('user_role');
              await TokenManager.clearToken();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const BiometricRegistrationScreen()),
                );
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Reset Registration',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Header
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Authenticate to access your account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Biometric Icon
              _buildBiometricIcon(),

              const SizedBox(height: 60),

              // Status Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Retry Button
              if (_status == BiometricStatus.failed || _status == BiometricStatus.error)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _authenticateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Enum for authentication status
enum BiometricStatus {
  initial,
  ready,
  authenticating,
  success,
  failed,
  error,
  unsupported,
  notEnrolled,
}