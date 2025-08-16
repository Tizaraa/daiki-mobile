import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../Core/Utils/api_service.dart';

class InspectorProfilePage extends StatefulWidget {
  const InspectorProfilePage({Key? key}) : super(key: key);

  @override
  State<InspectorProfilePage> createState() => _InspectorProfilePageState();
}

class _InspectorProfilePageState extends State<InspectorProfilePage> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Loading flags
  bool _isLoading = false;
  bool _isImageUploading = false;

  // Image
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Cached user data
  String? _currentUserPhoto;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userRole = '';

  // Network-image cache key
  Key _imageKey = UniqueKey();

  // Colors
  static const Color primaryColor = Color(0xFF3F51B5);
  static const Color accentColor = Color(0xFF7986CB);
  static const Color lightColor = Color(0xFFE8EAF6);
  static const Color darkTextColor = Color(0xFF283593);
  static const Color lightTextColor = Color(0xFF9FA8DA);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Email validation function
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Phone validation function
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check for valid phone number format (10-15 digits, optionally starting with +)
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number (10-15 digits)';
    }

    return null;
  }

  // Name validation function
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    // Check if name contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userEmail = prefs.getString('user_email') ?? 'Email';
      _userRole = prefs.getString('user_role') ?? 'No Role';
      _userPhone = prefs.getString('user_phone') ?? 'No Phone';
      _currentUserPhoto = prefs.getString('user_photo');
      _imageKey = UniqueKey();
    });
    print('Loaded user photo from SharedPreferences: $_currentUserPhoto');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null || !await _selectedImage!.exists()) {
      _showErrorSnackBar('No image selected or file does not exist');
      return;
    }

    setState(() {
      _isImageUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        setState(() => _isImageUploading = false);
        _showErrorSnackBar('Authentication token not found');
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://minio.johkasou-erp.com/api/v1/profile/update-photo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _selectedImage!.path,
          filename: 'profile_photo.jpg',
        ),
      );

      print('Uploading image to server: ${_selectedImage!.path}');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String? newPhotoUrl = responseData['photo'] ??
            responseData['data']?['photo'] ??
            responseData['profile_photo'] ??
            responseData['photo_url'] ??
            responseData['image'] ??
            responseData['image_url'];

        if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
          if (!newPhotoUrl.startsWith('https://')) {
            newPhotoUrl = 'https://minio.johkasou-erp.com/daiki/profile/$newPhotoUrl';
          }

          imageCache.clear();
          imageCache.clearLiveImages();

          await prefs.setString('user_photo', newPhotoUrl);
          setState(() {
            _currentUserPhoto = newPhotoUrl;
            _selectedImage = null;
            _isImageUploading = false;
            _imageKey = UniqueKey();
          });

          print('Saved photo URL to SharedPreferences: $newPhotoUrl');
          _showSuccessSnackBar('Profile image updated successfully!');
        } else {
          setState(() => _isImageUploading = false);
          _showErrorSnackBar(
              'Image uploaded but no photo URL received from server. Response: ${response.body}');
        }
      } else {
        setState(() => _isImageUploading = false);
        try {
          final responseData = jsonDecode(response.body);
          _showErrorSnackBar(
              responseData['message'] ?? 'Upload failed with status ${response.statusCode}');
        } catch (e) {
          _showErrorSnackBar('Upload failed with status ${response.statusCode}. Response: ${response.body}');
        }
      }
    } catch (e) {
      setState(() => _isImageUploading = false);
      _showErrorSnackBar('Network error: $e');
      print('Upload error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.camera_alt, color: primaryColor),
            const SizedBox(width: 12),
            Text(
              'Select Photo',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: darkTextColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: primaryColor),
              title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera, color: primaryColor),
              title: Text('Take Photo', style: GoogleFonts.poppins(fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_isImageUploading) {
      return _buildLoadingIndicator(120);
    }

    if (_selectedImage != null && _selectedImage!.existsSync()) {
      return _buildImageFromFile(_selectedImage!, 120);
    }

    if (_currentUserPhoto != null && _currentUserPhoto!.isNotEmpty) {
      return _buildImageFromNetwork(_currentUserPhoto!, 120);
    }

    return _fallbackAvatar(60);
  }

  Widget _buildLoadingIndicator(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      shape: BoxShape.circle,
      border: Border.all(color: primaryColor, width: 2),
    ),
    child: const Center(
      child: CircularProgressIndicator(
        color: primaryColor,
        strokeWidth: 3,
      ),
    ),
  );

  Widget _buildImageFromFile(File image, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: primaryColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ClipOval(
      child: Image.file(
        image,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    ),
  );

  Widget _buildImageFromNetwork(String url, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: primaryColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ClipOval(
      child: Image.network(
        url,
        key: UniqueKey(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 2).toInt(),
        cacheHeight: (size * 2).toInt(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image from $url: $error');
          return _fallbackAvatar(size / 2);
        },
      ),
    ),
  );

  Widget _fallbackAvatar(double radius) => Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      color: accentColor,
      shape: BoxShape.circle,
      border: Border.all(color: primaryColor, width: 2),
    ),
    child: Center(
      child: Text(
        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings, color: Colors.white),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    _buildProfileImage(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isImageUploading ? null : _showImagePickerDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isImageUploading ? Icons.hourglass_empty : Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor, width: 1),
                  ),
                  child: Text(
                    _userRole,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: darkTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                      const Divider(height: 25),
                      _buildInfoRow(Icons.email, 'Email', _userEmail),
                      const SizedBox(height: 20),
                      _buildInfoRow(Icons.phone, 'Phone', _userPhone),
                      const SizedBox(height: 20),
                      _buildInfoRow(Icons.work, 'Role', _userRole),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _nameController.text = _userName;
                      _emailController.text = _userEmail;
                      _phoneController.text = _userPhone;
                      _showEditProfileDialog(context);
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: lightTextColor,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  );

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note, color: primaryColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _buildFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: accentColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateProfile(context, setDialogState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Update',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: lightTextColor,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: lightTextColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: lightTextColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 16, color: darkTextColor),
        validator: validator,
      );

  Future<void> _updateProfile(BuildContext context, StateSetter setDialogState) async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setDialogState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/admin/update/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );

      setDialogState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setString('user_name', _nameController.text.trim());
        await prefs.setString('user_email', _emailController.text.trim());
        await prefs.setString('user_phone', _phoneController.text.trim());

        setState(() {
          _userName = _nameController.text.trim();
          _userEmail = _emailController.text.trim();
          _userPhone = _phoneController.text.trim();
          _imageKey = UniqueKey();
        });

        Navigator.of(context).pop();
        _showSuccessSnackBar('Profile updated successfully!');
      } else {
        try {
          final responseData = jsonDecode(response.body);
          _showErrorSnackBar(responseData['message'] ?? 'Failed to update profile');
        } catch (e) {
          _showErrorSnackBar('Failed to update profile');
        }
      }
    } catch (e) {
      setDialogState(() => _isLoading = false);
      _showErrorSnackBar('Error: $e');
    }
  }
}