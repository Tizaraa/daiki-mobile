import 'dart:io';
import 'dart:convert';
import 'package:daiki_axis_stp/Core/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';

class CategoryQuestionsScreen extends StatefulWidget {
  final int johkasouModelId;
  final String title;
  final int projectId;
  final int scheduleId;

  const CategoryQuestionsScreen({
    super.key,
    required this.johkasouModelId,
    required this.title,
    required this.projectId,
    required this.scheduleId,
  }) : assert(projectId > 0, 'Project ID must be greater than 0'),
        assert(scheduleId > 0, 'Schedule ID must be greater than 0'),
        assert(johkasouModelId > 0, 'Johkasou Model ID must be greater than 0');

  @override
  _CategoryQuestionsScreenState createState() => _CategoryQuestionsScreenState();
}

class _CategoryQuestionsScreenState extends State<CategoryQuestionsScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Category? _selectedCategory;
  Question? _selectedQuestion;
  List<XFile> _selectedImages = [];
  bool _isBeforeUpload = false;
  bool _isAfterUpload = false;
  TextEditingController _commentsController = TextEditingController();
  TextEditingController _memoController = TextEditingController();
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  final ImagePicker _picker = ImagePicker();

  // For multiple albums
  List<AlbumData> _albums = [];
  int _currentAlbumIndex = 0;

  // Controllers for typeahead
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  // Color scheme
  final Color _primaryColor = Color(0xFF0074BA);
  final Color _secondaryColor = Color(0xFFABBAF8);
  final Color _accentColor = Color(0xFF4CAF50);
  final Color _errorColor = Color(0xFFE53935);
  final Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _albums.add(AlbumData());
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _memoController.dispose();
    _categoryController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final categories = await _apiService.fetchCategoriesWithQuestions(widget.johkasouModelId);
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  void _addNewAlbum() {
    setState(() {
      _albums.add(AlbumData());
      _currentAlbumIndex = _albums.length - 1;
      _updateCurrentAlbumData();
    });
  }

  void _removeAlbum(int index) {
    if (_albums.length <= 1) return;

    setState(() {
      _albums.removeAt(index);
      if (_currentAlbumIndex >= index) {
        _currentAlbumIndex = _currentAlbumIndex > 0 ? _currentAlbumIndex - 1 : 0;
      }
      _updateCurrentAlbumData();
    });
  }

  void _updateCurrentAlbumData() {
    final currentAlbum = _albums[_currentAlbumIndex];
    setState(() {
      _selectedCategory = currentAlbum.category;
      _selectedQuestion = currentAlbum.question;
      _selectedImages = currentAlbum.images;
      _isBeforeUpload = currentAlbum.isBeforeUpload;
      _isAfterUpload = currentAlbum.isAfterUpload;
      _commentsController.text = currentAlbum.comments ?? '';
      _memoController.text = currentAlbum.memo ?? '';

      _categoryController.text = _selectedCategory?.name ?? '';
      _questionController.text = _selectedQuestion?.text ?? '';
    });
  }

  void _saveCurrentAlbumData() {
    _albums[_currentAlbumIndex] = AlbumData(
      category: _selectedCategory,
      question: _selectedQuestion,
      images: _selectedImages,
      isBeforeUpload: _isBeforeUpload,
      isAfterUpload: _isAfterUpload,
      comments: _commentsController.text.isNotEmpty ? _commentsController.text : null,
      memo: _memoController.text.isNotEmpty ? _memoController.text : null,
    );
  }

  Future<void> _showImageSourceDialog() async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _captureMultipleImagesFromCamera();
                  },
                ),
                Divider(height: 1),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImagesFromGallery();
                  },
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: _primaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: Text(label, style: TextStyle(fontSize: 16)),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (images != null) {
        setState(() {
          _selectedImages.addAll(images);
          _saveCurrentAlbumData();
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick images: $e');
    }
  }

  Future<void> _captureMultipleImagesFromCamera() async {
    try {
      bool continueCapturing = true;
      while (continueCapturing) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1200,
        );

        if (image != null) {
          setState(() {
            _selectedImages.add(image);
            _saveCurrentAlbumData();
          });

          continueCapturing = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Capture Another Photo?'),
              content: Text('Would you like to take another photo?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No', style: TextStyle(color: _primaryColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes', style: TextStyle(color: _primaryColor)),
                ),
              ],
            ),
          ) ?? false;
        } else {
          continueCapturing = false;
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to capture image: $e');
    }
  }

  Future<void> _uploadImagesOnly() async {
    if (_selectedCategory == null || _selectedImages.isEmpty) {
      _showErrorSnackbar('Please select a category and at least one image');
      return;
    }

    if (_selectedQuestion == null || _selectedQuestion!.id <= 0) {
      _showErrorSnackbar('Please select a valid question');
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('Authentication token not found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${DaikiAPI.api_key}/api/v1/photo-album/upload-images'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['project_id'] = widget.projectId.toString();
      request.fields['schedule_id'] = widget.scheduleId.toString();
      request.fields['question_id'] = _selectedQuestion!.id.toString();
      request.fields['category_id'] = _selectedCategory!.id.toString();
      request.fields['johkasou_model_id'] = widget.johkasouModelId.toString();
      request.fields['is_before'] = _isBeforeUpload ? '1' : '0';
      request.fields['is_after'] = _isAfterUpload ? '1' : '0';

      if (_commentsController.text.isNotEmpty) {
        request.fields['comments'] = _commentsController.text;
      }

      if (_memoController.text.isNotEmpty) {
        request.fields['memo'] = _memoController.text;
      }

      for (int i = 0; i < _selectedImages.length; i++) {
        var file = await http.MultipartFile.fromPath(
          'images[$i][file]',
          _selectedImages[i].path,
        );
        request.files.add(file);
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['status'] == true) {
          _showSuccessSnackbar('Images uploaded successfully');
          setState(() {
            _selectedImages.clear();
            _saveCurrentAlbumData();
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Failed to upload: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      _showErrorSnackbar('Error uploading: $e');
      print('Error uploading: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }




  Future<void> _submitAllAlbums() async {
    // Save current album data before submission
    _saveCurrentAlbumData();

    setState(() => _isSubmitting = true);

    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final albumsData = _albums.where((album) =>
      album.category != null && album.question != null
      ).map((album) {
        Map<String, dynamic> albumMap = {
          "project_id": widget.projectId,
          "schedule_id": widget.scheduleId,
          "question_id": album.question!.id,
          "category_id": album.category!.id,
          "johkasou_model_id": widget.johkasouModelId,
        };

        // Only add comments if not null or empty
        if (album.comments != null && album.comments!.isNotEmpty) {
          albumMap["comments"] = album.comments;
        }

        // Only add memo if not null or empty
        if (album.memo != null && album.memo!.isNotEmpty) {
          albumMap["memo"] = album.memo;
        }

        return albumMap;
      }).toList();

      if (albumsData.isEmpty) throw Exception('No valid albums to submit');

      print('Submitting albums data: ${json.encode({"albums": albumsData})}');

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/photo_album'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({"albums": albumsData}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          _showSuccessSnackbar('All albums submitted successfully');
          setState(() {
            _albums = [AlbumData()];
            _currentAlbumIndex = 0;
            _updateCurrentAlbumData();
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Submission failed');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Access denied (403). Please check your permissions or contact administrator.');
      } else {
        throw Exception('Failed to submit: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showErrorSnackbar('Error submitting albums: $e');
      print('Full error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _accentColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(_primaryColor)),
          SizedBox(height: 16),
          Text('Loading categories...', style: TextStyle(color: _primaryColor)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: _errorColor, size: 48),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadCategories,
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, color: Colors.grey, size: 48),
          SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeaheadDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TypeAheadField<T>(
            controller: controller,
            suggestionsCallback: (pattern) => items.where((item) =>
                displayText(item).toLowerCase().contains(pattern.toLowerCase())
            ).toList(),
            itemBuilder: (context, T suggestion) => ListTile(
              title: Text(displayText(suggestion)),
            ),
            onSelected: (T selected) {
              onChanged(selected);
              controller.text = displayText(selected);
            },
            builder: (context, controller, focusNode) => TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCheckboxOption({
    required bool value,
    required ValueChanged<bool?>? onChanged,
    required String label,
  }) {
    return InkWell(
      onTap: onChanged != null ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(label, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Selected Images (${_selectedImages.length})',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                          _saveCurrentAlbumData();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumTab(int index) {
    final isActive = index == _currentAlbumIndex;
    return GestureDetector(
      onTap: () {
        _saveCurrentAlbumData();
        setState(() {
          _currentAlbumIndex = index;
          _updateCurrentAlbumData();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive ? _primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive ? [
            BoxShadow(
              color: _primaryColor.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Album ${index + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (_albums.length > 1) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _removeAlbum(index),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Upload',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildCheckboxOption(
              value: _isBeforeUpload,
              onChanged: _selectedCategory != null ? (value) {
                setState(() {
                  _isBeforeUpload = value ?? false;
                  _saveCurrentAlbumData();
                });
              } : null,
              label: 'Before Upload',
            )),
            SizedBox(width: 16),
            Expanded(child: _buildCheckboxOption(
              value: _isAfterUpload,
              onChanged: _selectedCategory != null ? (value) {
                setState(() {
                  _isAfterUpload = value ?? false;
                  _saveCurrentAlbumData();
                });
              } : null,
              label: 'After Upload',
            )),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _selectedCategory != null &&
              _selectedQuestion != null &&
              (_isBeforeUpload || _isAfterUpload)
              ? _showImageSourceDialog
              : null,
          icon: Icon(Icons.add_a_photo, size: 20),
          label: Text('Add Images'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        _buildImagePreview(),
        SizedBox(height: 16),
        TextField(
          controller: _commentsController,
          decoration: InputDecoration(
            labelText: 'Comments (Optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 3,
          onChanged: (value) => _saveCurrentAlbumData(),
        ),

        SizedBox(height: 16),
        TextField(
          controller: _memoController,
          decoration: InputDecoration(
            labelText: 'Memo (Optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 2,
          onChanged: (value) => _saveCurrentAlbumData(),
        ),

        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isUploading || _selectedImages.isEmpty || _selectedQuestion == null
                ? null
                : _uploadImagesOnly,
            style: ElevatedButton.styleFrom(
              backgroundColor: TizaraaColors.Tizara,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isUploading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text('Set Images', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_albums.length, (index) => _buildAlbumTab(index)),
            ),
          ),
          SizedBox(height: 16),

          // Add new album button
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _addNewAlbum,
              icon: Icon(Icons.add, size: 18),
              label: Text('New Album'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(color: _primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Category selection
          _buildTypeaheadDropdown<Category>(
            label: 'Category',
            value: _selectedCategory,
            items: _categories,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _selectedQuestion = null;
                _selectedImages.clear();
                _isBeforeUpload = false;
                _isAfterUpload = false;
                _questionController.clear();
                _saveCurrentAlbumData();
              });
            },
            displayText: (category) => category.name,
            controller: _categoryController,
            hintText: 'Search or select category',
          ),

          // Question selection with delete option
          if (_selectedCategory != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeaheadDropdown<Question>(
                  label: 'Question',
                  value: _selectedQuestion,
                  items: _selectedCategory!.questions,
                  onChanged: (value) {
                    setState(() {
                      _selectedQuestion = value;
                      _saveCurrentAlbumData();
                    });
                  },
                  displayText: (question) => question.text,
                  controller: _questionController,
                  hintText: 'Search or select question',
                ),
                if (_selectedQuestion != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Question:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _selectedQuestion!.text,
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ],
            ),

          SizedBox(height: 24),
          _buildImageUploadSection(),
          SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: _isSubmitting || _albums.isEmpty ||
              _albums.every((album) => album.category == null || album.question == null)
              ? null
              : _submitAllAlbums,
          backgroundColor: _isSubmitting ? Colors.grey : _primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          label: _isSubmitting
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text('Submit All Albums', style: TextStyle(fontWeight: FontWeight.bold)),
          icon: Icon(Icons.send, size: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _categories.isEmpty
          ? _buildNoDataWidget()
          : _buildMainContent(),
    );
  }
}

class AlbumData {
  final Category? category;
  final Question? question;
  final List<XFile> images;
  final bool isBeforeUpload;
  final bool isAfterUpload;
  final String? comments;
  final String? memo;

  AlbumData({
    this.category,
    this.question,
    List<XFile>? images,
    this.isBeforeUpload = false,
    this.isAfterUpload = false,
    this.comments,
    this.memo,
  }) : images = images ?? [];
}

class Category {
  final int id;
  final String name;
  final int slNo;
  final int countryId;
  final String description;
  final String createdAt;
  final String updatedAt;
  final int status;
  final String nameSriLanka;
  final String model;
  final List<Question> questions;

  Category({
    required this.id,
    required this.name,
    required this.slNo,
    required this.countryId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.nameSriLanka,
    required this.model,
    required this.questions,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slNo: json['sl_no'] ?? 0,
      countryId: json['country_id'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      status: json['status'] ?? 0,
      nameSriLanka: json['name_sri_lanka'] ?? '',
      model: json['model'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ??
          [],
    );
  }
}

class Question {
  final int id;
  final int categoryId;
  final String text;
  final String type;
  final String? unit;
  final int required;
  final int? slNo;
  final dynamic min;
  final dynamic max;
  final String? textSriLanka;
  final dynamic string;
  final int status;
  final int? albumId; // Keep albumId field for backward compatibility

  Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.type,
    this.unit,
    required this.required,
    this.slNo,
    this.min,
    this.max,
    this.textSriLanka,
    this.string,
    required this.status,
    this.albumId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      unit: json['unit'],
      required: json['required'] ?? 0,
      slNo: json['sl_no'],
      min: json['min'],
      max: json['max'],
      textSriLanka: json['text_srilanka'],
      string: json['string'],
      status: json['status'] ?? 0,
      albumId: json['album_id'],
    );
  }
}

class ApiService {
  Future<List<Category>> fetchCategoriesWithQuestions(int johkasouModelId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null) throw Exception('Authentication token is missing.');

      final response = await http.get(
        Uri.parse(
            '${DaikiAPI.api_key}/api/v1/get-category-with-questions?johkasou_model_id=$johkasouModelId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final categoriesJson = data['date'] as List?;
          if (categoriesJson != null) {
            return categoriesJson.map((json) => Category.fromJson(json)).toList();
          }
        }
        throw Exception(data['message'] ?? 'API returned false status');
      }
      throw Exception('Failed to load categories. Status code: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}