import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Core/Token-Manager/token_manager_screen.dart';
import 'package:daiki_axis_stp/Core/Utils/colors.dart';

import '../../../Core/Utils/api_service.dart';

class InspectorPtViewAlbum extends StatefulWidget {
  final int johkasouModelID;
  final int ScheduleID;
  final String title;

  const InspectorPtViewAlbum({
    super.key,
    required this.johkasouModelID,
    required this.ScheduleID,
    required this.title,
  });

  @override
  State<InspectorPtViewAlbum> createState() => _InspectorPtViewAlbumState();
}

class _InspectorPtViewAlbumState extends State<InspectorPtViewAlbum>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _albumData;
  List<dynamic> _beforeMaintenance = [];
  List<dynamic> _afterMaintenance = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAlbumData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlbumData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Validate inputs
      if (widget.ScheduleID <= 0) {
        throw Exception('Invalid Schedule ID: ${widget.ScheduleID}');
      }
      if (widget.johkasouModelID <= 0) {
        throw Exception('Invalid Johkasou Model ID: ${widget.johkasouModelID}');
      }

      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or invalid.');
      }

      print('Fetching album data for ScheduleID: ${widget.ScheduleID}, JohkasouModelID: ${widget.johkasouModelID}');
      print('Using token: $token');

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/photo-albums/by-schedule/${widget.ScheduleID}?johkasou_model_id=${widget.johkasouModelID}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            // Check if data['data'] is a Map; if not, treat as empty
            if (data['data'] is Map<String, dynamic>) {
              _albumData = data['data'];
              _beforeMaintenance = data['data']['before_maintenance'] ?? [];
              _afterMaintenance = data['data']['after_maintenance'] ?? [];
            } else {
              _albumData = null; // or {} if you prefer
              _beforeMaintenance = [];
              _afterMaintenance = [];
            }
            _isLoading = false;
          });

          // Enhanced logging for debugging
          print('=== ALBUM DATA STRUCTURE ===');
          print('Full Album Data: $_albumData');
          print('Before Maintenance: $_beforeMaintenance');
          print('After Maintenance: $_afterMaintenance');
          print('=== END ALBUM DATA STRUCTURE ===');
        } else {
          throw Exception('API returned false status: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Validation error occurred';
        final errors = errorData['errors'] ?? {};
        print('Validation Errors: $errors');
        throw Exception('Validation error: $errorMessage. Details: $errors');
      } else if (response.statusCode == 401) {
        await TokenManager.clearToken();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to load album data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error in _fetchAlbumData: $e');
    }
  }


  Future<void> _deleteQuestion(int questionId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or invalid.');
      }

      if (_albumData == null) {
        throw Exception('Album data is missing. Please try refreshing the data.');
      }

      // Enhanced project ID extraction with multiple fallbacks
      int? projectId;

      // Check if project exists in album data
      if (_albumData!['project'] != null) {
        final projectData = _albumData!['project'];

        // Try multiple possible keys for project ID
        projectId = projectData['project_id'] ??
            projectData['id'] ??
            projectData['pj_id'] ??
            projectData['projectId'];

        print('Project data structure: $projectData');
        print('Extracted project ID: $projectId');
      }

      // If project ID is still null, try to get it from other places in album data
      projectId ??= _albumData!['project_id'] ?? _albumData!['pj_id'] ?? _albumData!['projectId'];

      // Final validation
      if (projectId == null) {
        print('Full album data structure: $_albumData');
        throw Exception('Project ID could not be found in album data. Please check the API response structure.');
      }

      // Prepare request body
      final requestBody = {
        'johkasou_model_id': widget.johkasouModelID,
        'question_id': questionId,
        'schedule_id': widget.ScheduleID,
        'project_id': projectId,
      };

      // Construct the correct endpoint URL
      final url = Uri.parse('${DaikiAPI.api_key}/api/v1/remove-question-images');

      print('=== Delete Question Request Details ===');
      print('URL: $url');
      print('Headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"}');
      print('Request Body: ${json.encode(requestBody)}');
      print('=====================================');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Delete Question API Response Status: ${response.statusCode}');
      print('Delete Question API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          // Refresh data after successful deletion
          await _fetchAlbumData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Question deleted successfully'),
                backgroundColor: TizaraaColors.Tizara,
              ),
            );
          }
        } else {
          throw Exception('API returned false status: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        await TokenManager.clearToken();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Validation error occurred';
        final errors = errorData['errors'] ?? {};
        print('Delete Question Validation Errors: $errors');
        throw Exception('Validation error: $errorMessage. Details: $errors');
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Resource not found';
        print('404 Error Details: $errorData');
        throw Exception('Failed to delete question: Resource not found. $errorMessage');
      } else {
        throw Exception('Failed to delete question. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting question: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error in _deleteQuestion: $e');
    }
  }

  Future<void> _deleteImage(int imageId) async {
    try {
      String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or invalid.');
      }

      final response = await http.delete(
        Uri.parse('${DaikiAPI.api_key}/api/v1/photo-albums/remove-image/$imageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Image API Response Status: ${response.statusCode}');
      print('Delete Image API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          // Refresh data after successful deletion
          await _fetchAlbumData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image deleted successfully'),
              backgroundColor: TizaraaColors.Tizara,
            ),
          );
        } else {
          throw Exception('API returned false status: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        await TokenManager.clearToken();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to delete image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error in _deleteImage: $e');
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TizaraaColors.Tizara),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading album data...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAlbumData,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TizaraaColors.Tizara,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Colors.grey,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Photos Available',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No photos found for this schedule',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://via.placeholder.com/150',
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<dynamic> albums) {
    if (albums.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.grey,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Images Available',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No photos have been uploaded for this section yet.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final category = albums[index]['category'];
        final questions = albums[index]['questions'] as List;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TizaraaColors.Tizara.withOpacity(0.8),
                      TizaraaColors.Tizara,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  category['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: questions.map((question) {
                    final questionData = question['question'];
                    final album = question['albums'];
                    final images = album['images'] as List;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  questionData['text'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                tooltip: 'Delete Question',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this question?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteQuestion(questionData['id']);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        images.isEmpty
                            ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'No images available for this question',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, imageIndex) {
                            final image = images[imageIndex];
                            final imageUrl = 'https://minio.johkasou-erp.com/daiki/${image['image_path']}';

                            return GestureDetector(
                              onTap: () => _showFullScreenImage(imageUrl),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  ),
                                                );
                                              },
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 24,
                                                ),
                                                tooltip: 'Delete Image',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Confirm Delete'),
                                                      content: const Text('Are you sure you want to delete this image?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            _deleteImage(image['id']);
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(color: Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.white,
                                        child: Text(
                                          image['description'] ?? 'No description',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (images.isNotEmpty) const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectHeader() {
    if (_albumData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TizaraaColors.Tizara.withOpacity(0.1),
            TizaraaColors.Tizara.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TizaraaColors.Tizara.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TizaraaColors.Tizara,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _albumData!['project']['project_name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.qr_code,
                label: 'Code',
                value: _albumData!['project']['pj_code'],
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.settings,
                label: 'Module',
                value: _albumData!['johkasou_model']['module'],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoChip(
            icon: Icons.photo_album,
            label: 'Album No',
            value: _albumData!['albumNo'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TizaraaColors.Tizara.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: TizaraaColors.Tizara,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildProjectHeader(),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: TizaraaColors.Tizara,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.settings_backup_restore, size: 18),
                    const SizedBox(width: 8),
                    Text('Before (${_beforeMaintenance.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Text('After (${_afterMaintenance.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildImageGrid(_beforeMaintenance),
              _buildImageGrid(_afterMaintenance),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: TizaraaColors.Tizara,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAlbumData,
            tooltip: 'Refresh',
          ),

        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _beforeMaintenance.isEmpty && _afterMaintenance.isEmpty
          ? _buildNoDataWidget()
          : _buildMainContent(),
    );
  }
}