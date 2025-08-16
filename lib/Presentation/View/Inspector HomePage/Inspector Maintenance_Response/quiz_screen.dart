//
// import 'package:daiki_axis_stp/Maintenance_Response/quiz_model.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http_parser/http_parser.dart';
// import '../Authentication/login_screen.dart';
// import '../Token-Manager/token_manager_screen.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// //===================api services=====================//
//
// class ApiService {
//   Future<List<Category>> fetchCategories(int maintenanceScheduleId) async {
//     try {
//       String? token = await TokenManager.getToken();
//
//       if (token == null) {
//         throw Exception('No token found. Please log in.');
//       }
//
//       final response = await http.get(
//         Uri.parse('https://backend.johkasou-erp.com/api/v1/stp-data/perform/$maintenanceScheduleId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//
//         if (data['date'] != null && data['date']['categories'] != null) {
//           final categoriesJson = data['date']['categories'];
//
//           if (categoriesJson is List) {
//             return categoriesJson.map((json) => Category.fromJson(json)).toList();
//           } else {
//             throw Exception('Categories data is not in the expected format.');
//           }
//         } else {
//           throw Exception('Categories data not found.');
//         }
//       } else {
//         throw Exception('Failed to load categories.');
//       }
//     } catch (e) {
//       throw Exception('Error fetching categories: $e');
//     }
//   }
// }
//
//
// class QuizScreen extends StatefulWidget {
//   final int maintenanceScheduleId;
//   final int projectId;
//   final String project_name;
//   final String next_maintenance_date;
//
//   const QuizScreen({
//     Key? key,
//     required this.maintenanceScheduleId,
//     required this.projectId,
//     required this.project_name,
//     required this.next_maintenance_date,
//   }) : super(key: key);
//
//   @override
//   State<QuizScreen> createState() => _QuizScreenState();
// }
//
// class _QuizScreenState extends State<QuizScreen> {
//   final ApiService _apiService = ApiService(); // API service to fetch data
//   final _formKey = GlobalKey<FormState>(); // Global key for form validation
//   final ImagePicker _imagePicker = ImagePicker(); // Image picker instance for capturing images
//   List<Category> categories = []; // Holds the quiz categories
//   bool isLoading = true; // Tracks if data is loading
//   String? error; // Holds error messages
//   bool isSubmitting = false; // Tracks the form submission status
//   Map<int, File?> questionVideos = {}; // New map for storing videos
//
//
//   // Store the answers and images here for persistence
//   Map<int, String?> selectedOptions = {}; // Stores selected answers for questions
//   Map<int, File?> questionImages = {}; // Stores images related to questions
//   Set<int> touchedQuestions = {}; // Set to track answered questions
//
//   int currentCategoryIndex = 0; // Tracks the current category index
//
//   String locationInfo = '';
//   String ipInfo = '';
//   String deviceInfo = '';
//
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQuizData(); // Fetch quiz data when the screen loads
//     _checkSessionValidity();
//   }
//
//   Future<void> _checkSessionValidity() async {
//     final tokenExpired = await TokenManager.isTokenExpired();
//     if (tokenExpired) {
//       // If the token is expired, clear the session and log the user out
//       await TokenManager.clearToken();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }
//
//   Future<void> _loadQuizData() async {
//     try {
//       setState(() {
//         isLoading = true; // Set loading to true when fetching data
//         error = null; // Reset error state
//       });
//
//       final data = await _apiService.fetchCategories(widget.maintenanceScheduleId); // Fetch categories from API
//       print("Fetched categories data: $data");
//
//       setState(() {
//         categories = data; // Set the categories list with fetched data
//         isLoading = false; // Set loading to false once data is loaded
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString(); // Set error message if fetching fails
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   bool _isAllQuestionsAnswered() {
//     // Checks if all required questions have been answered
//     for (var category in categories) {
//       for (var question in category.questions) {
//         if ((question.type == 'radio' || question.type == 'number') &&
//             selectedOptions[question.id] == null) {
//           return false;
//         }
//       }
//     }
//     return true;
//   }
//
//
//
// // Method to capture the image and display location, IP, and device info
//   Future<void> _captureImage(int questionId) async {
//     try {
//       // Capture image using the camera
//       final XFile? photo = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//         maxWidth: 1200,
//       );
//
//       if (photo != null) {
//         // Fetch location (latitude and longitude)
//         Position position = await _getCurrentLocation(); // Get the current location
//
//         // Ensure GeocodingPlatform is available before using it
//         if (GeocodingPlatform.instance != null) {
//           // Convert latitude and longitude to address
//           List<Placemark> placemarks = await GeocodingPlatform.instance!
//               .placemarkFromCoordinates(position.latitude, position.longitude);
//
//           // Check if placemarks is not empty
//           if (placemarks.isNotEmpty) {
//             Placemark place = placemarks.first;
//
//             // Format the address
//             locationInfo = '${place.street}, ${place.locality}, ${place.country}';
//           } else {
//             locationInfo = 'Address not found';
//           }
//         } else {
//           locationInfo = 'Geocoding service is unavailable';
//         }
//
//         // Fetch IP address and device model
//         String ipAddress = await _getIPAddress(); // Get the IP address
//         String deviceModel = await _getDeviceModel(); // Get the device model
//
//         // Update the UI state with the captured image and information
//         setState(() {
//           questionImages[questionId] = File(photo.path); // Store captured image
//           ipInfo = 'IP: $ipAddress';
//           deviceInfo = 'Device: $deviceModel';
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error capturing image: $e')),
//       );
//     }
//   }
//
//   Widget _buildCaptureButton({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required String label,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).primaryColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, color: Colors.teal),
//         label: Text(label, style: TextStyle(color: Colors.black)),
//         style: TextButton.styleFrom(
//           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         ),
//       ),
//     );
//   }
//
//   // Update the capture function to ensure proper file handling
//   Future<void> _captureMedia(int questionId, bool isVideo) async {
//     try {
//       if (isVideo) {
//         final XFile? video = await _imagePicker.pickVideo(
//           source: ImageSource.camera,
//           maxDuration: const Duration(minutes: 3),
//         );
//
//         if (video != null) {
//           final File videoFile = File(video.path);
//           // Verify file exists and has size
//           if (await videoFile.exists()) {
//             setState(() {
//               questionVideos[questionId] = videoFile;
//             });
//             await _uploadMedia(questionId, videoFile, true);
//           } else {
//             throw Exception('Video file not found after capture');
//           }
//         }
//       } else {
//         final XFile? photo = await _imagePicker.pickImage(
//           source: ImageSource.camera,
//           imageQuality: 80,
//           maxWidth: 1200,
//         );
//
//         if (photo != null) {
//           final File imageFile = File(photo.path);
//           // Verify file exists and has size
//           if (await imageFile.exists()) {
//             setState(() {
//               questionImages[questionId] = imageFile;
//             });
//             await _uploadMedia(questionId, imageFile, false);
//           } else {
//             throw Exception('Image file not found after capture');
//           }
//         }
//       }
//     } catch (e) {
//       print('Error in _captureMedia: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error capturing media: $e')),
//       );
//     }
//   }
//
// //   ==========  upload media    =============//
//   Future<void> _uploadMedia(int questionId, File mediaFile, bool isVideo) async {
//     try {
//       String? token = await TokenManager.getToken();
//       if (token == null) {
//         throw Exception('No token found. Please log in.');
//       }
//
//       // Create multipart request
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://backend.johkasou-erp.com/api/v1/image/store'),
//       );
//
//       // Add headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });
//
//       // Add required fields
//       request.fields['question_id'] = questionId.toString();
//       request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
//       request.fields['schedule_id'] = widget.maintenanceScheduleId.toString();
//
//       // Properly handle the file
//       String fileName = mediaFile.path.split('/').last;
//       String contentType = isVideo ? 'video/mp4' : 'image/jpeg';
//
//       // Create MultipartFile with content type
//       var stream = http.ByteStream(mediaFile.openRead());
//       var length = await mediaFile.length();
//
//       var multipartFile = http.MultipartFile(
//         isVideo ? 'video' : 'media',  // Use "media" for images
//         stream,
//         length,
//         filename: fileName,
//         contentType: MediaType.parse(contentType),
//       );
//
//       request.files.add(multipartFile);
//
//       // Debug prints
//       print('Uploading file: ${mediaFile.path}');
//       print('File exists: ${await mediaFile.exists()}');
//       print('File size: $length bytes');
//       print('Content type: $contentType');
//
//       // Show upload progress
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Uploading ${isVideo ? 'video' : 'image'}...')),
//       );
//
//       try {
//         // Send request
//         final streamedResponse = await request.send();
//         final response = await http.Response.fromStream(streamedResponse);
//
//         // Debug response
//         print('Response status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           final responseData = json.decode(response.body);
//           if (responseData['status'] == true) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('${isVideo ? 'Video' : 'Image'} uploaded successfully')),
//             );
//           } else {
//             throw Exception(responseData['message'] ?? 'Failed to upload media');
//           }
//         } else {
//           // Print detailed error information
//           print('Upload failed with status ${response.statusCode}');
//           print('Response headers: ${response.headers}');
//           print('Response body: ${response.body}');
//
//           throw Exception('Failed to upload media. Status code: ${response.statusCode}');
//         }
//       } catch (e) {
//         print('Error during upload: $e');
//         throw e;
//       }
//     } catch (e) {
//       print('Error in _uploadMedia: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading media: $e')),
//       );
//     }
//   }
//
// // Fetch current location
//   Future<Position> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Location permissions are permanently denied');
//     }
//     return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//   }
//
// // Fetch IP address
//   Future<String> _getIPAddress() async {
//     try {
//       final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['ip'];
//       } else {
//         throw Exception('Failed to fetch IP address');
//       }
//     } catch (e) {
//       throw Exception('Error fetching IP address: $e');
//     }
//   }
//
// // Fetch device model
//   Future<String> _getDeviceModel() async {
//     final deviceInfoPlugin = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
//       return androidInfo.model; // Get Android device model
//     } else if (Platform.isIOS) {
//       IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
//       return iosInfo.model; // Get iOS device model
//     } else {
//       return 'Unknown Device';
//     }
//   }
//
//
//   void _nextCategory() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         if (currentCategoryIndex < categories.length - 1) {
//           currentCategoryIndex++; // Move to the next category
//         }
//       });
//     }
//   }
//
//   void _previousCategory() {
//     setState(() {
//       if (currentCategoryIndex > 0) {
//         currentCategoryIndex--; // Go back to the previous category
//       }
//     });
//   }
//
//
//   Future<void> _submitAnswers() async {
//     if (!_isAllQuestionsAnswered()) {
//       setState(() {
//         error = 'Please answer all the required questions before submitting.';
//       });
//       return;
//     }
//
//     try {
//       setState(() {
//         isSubmitting = true;
//         error = null;
//       });
//
//       String? token = await TokenManager.getToken();
//       if (token == null) {
//         throw Exception('No token found. Please log in.');
//       }
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://backend.johkasou-erp.com/api/v1/maintenance/store'),
//       );
//
//       // Add headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });
//
//       // Add the basic fields
//       request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
//       request.fields['project_id'] = widget.projectId.toString();
//       request.fields['user_id'] = '1';
//
//       // Format responses as individual form fields
//       int index = 0;
//
//       // Debug print to check images before submission
//       print('Images to upload: ${questionImages.length}');
//       questionImages.forEach((key, value) {
//         print('Question ID: $key has image: ${value?.path}');
//       });
//
//       for (var category in categories) {
//         for (var question in category.questions) {
//           if (selectedOptions[question.id] != null) {
//             // Create a unique key for each response
//             String responseKey = 'responses[$index]';
//
//             // Add basic response data
//             request.fields['$responseKey[question_id]'] = question.id.toString();
//             request.fields['$responseKey[category_id]'] = category.id.toString();
//             request.fields['$responseKey[response]'] = selectedOptions[question.id] ?? '';
//             request.fields['$responseKey[remarks]'] = questionComments[question.id] ?? '';
//
//             // Handle image for this question
//             if (questionImages[question.id] != null) {
//               File imageFile = questionImages[question.id]!;
//
//               if (await imageFile.exists()) {
//                 // Create a unique field name for each image
//                 String imageFieldName = '$responseKey[media]';
//
//                 var stream = http.ByteStream(imageFile.openRead());
//                 var length = await imageFile.length();
//
//                 print('Adding image for question ${question.id} with field name: $imageFieldName');
//
//                 var multipartFile = http.MultipartFile(
//                   imageFieldName,
//                   stream,
//                   length,
//                   filename: 'question_${question.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
//                 );
//
//                 request.files.add(multipartFile);
//               }
//             }
//
//             index++;
//           }
//         }
//       }
//
//       // Debug prints
//       print('Total number of files being sent: ${request.files.length}');
//       print('All field names in request:');
//       request.fields.forEach((key, value) {
//         print('Field: $key = $value');
//       });
//       print('All files in request:');
//       request.files.forEach((file) {
//         print('File field name: ${file.field}, filename: ${file.filename}');
//       });
//
//       // Send request
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['status'] == true || responseData['success'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Answers and images submitted successfully')),
//           );
//           Navigator.pop(context);
//         } else {
//           throw Exception(responseData['message'] ?? 'Failed to submit answers');
//         }
//       } else {
//         final errorResponse = json.decode(response.body);
//         throw Exception(errorResponse['message'] ?? 'Failed to submit answers');
//       }
//     } catch (e) {
//       print('Error submitting answers: $e');
//       setState(() {
//         error = 'Failed to submit answers: ${e.toString()}';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(error ?? 'Failed to submit answers')),
//       );
//     } finally {
//       setState(() {
//         isSubmitting = false;
//       });
//     }
//   }
//
//
//   // Builds text field for number type questions
//   Widget _buildTextFieldForNumber(Question question) {
//     return TextFormField(
//       keyboardType: TextInputType.number,
//       controller: TextEditingController(text: selectedOptions[question.id]),
//       onChanged: (value) {
//         setState(() {
//           selectedOptions[question.id] = value;
//           touchedQuestions.add(question.id); // Track the touched question
//         });
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'This field is required';
//         }
//
//         final intValue = int.tryParse(value);
//         if (intValue == null) {
//           return 'Please enter a valid number'; // Validate number input
//         }
//
//         if (question.min != null && intValue < question.min!) {
//           return 'Please enter a value greater than or equal to ${question.min}';
//         }
//         if (question.max != null && intValue > question.max!) {
//           return 'Please enter a value less than or equal to ${question.max}';
//         }
//
//         return null;
//       },
//       decoration: InputDecoration(
//         labelText: 'Enter a number',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//     );
//   }
//
//   // Builds options for questions with multiple choices
//   Widget _buildOption(int questionId, Option option, FormFieldState field) {
//     bool isSelected = selectedOptions[questionId] == option.value;
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isSelected
//               ? Theme.of(context).primaryColor
//               : Colors.grey.withOpacity(0.3),
//         ),
//         color: isSelected
//             ? Theme.of(context).primaryColor.withOpacity(0.1)
//             : Colors.white,
//       ),
//       child: RadioListTile<String>(
//         title: Text(
//           option.text,
//           style: TextStyle(
//             color: isSelected
//                 ? Theme.of(context).primaryColor
//                 : Colors.black87,
//           ),
//         ),
//         value: option.value,
//         groupValue: selectedOptions[questionId],
//         onChanged: (value) {
//           setState(() {
//             selectedOptions[questionId] = value;
//             touchedQuestions.add(questionId); // Track selected option
//             field.didChange(value);
//           });
//         },
//         activeColor: Theme.of(context).primaryColor,
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           title: Column(
//             children: [
//               Text(
//                 widget.project_name,
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                // 'Maintenance Due Date:${widget.next_maintenance_date}',
//                 'Maintenance Due Date:${widget.next_maintenance_date}',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//         body: isLoading
//             ? Center(child: CircularProgressIndicator())
//             : error != null
//             ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, size: 48, color: Colors.red),
//               SizedBox(height: 16),
//               Text(
//                 'Error: $error', // Display error if any
//                 style: TextStyle(color: Colors.red),
//               ),
//               ElevatedButton(
//                 onPressed: _loadQuizData,
//                 child: Text('Retry'),
//               ),
//             ],
//           ),
//         )
//             : Form(
//           key: _formKey,
//           child: Stack(
//             children: [
//               ListView(
//                 padding: EdgeInsets.only(bottom: 100),
//                 children: [
//                   Card(
//                     color: Colors.white,
//                     margin: EdgeInsets.all(16),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).primaryColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(12),
//                             topRight: Radius.circular(12),
//                           ),
//                         ),
//                           width: MediaQuery.of(context).size.width/1,
//                           padding: EdgeInsets.all(16),
//                           child: Text(
//                             categories[currentCategoryIndex].name, // Display current category name
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.all(16),
//                           child: _buildQuestionsForCategory(
//                               categories[currentCategoryIndex]), // Display questions for current category
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 4,
//                         offset: Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       ElevatedButton(
//                         onPressed: currentCategoryIndex > 0
//                             ? _previousCategory
//                             : null, // Enable/disable Previous button
//                         child: Text('Previous'),
//                       ),
//                       ElevatedButton(
//                         onPressed: isSubmitting ? null : _nextCategory, // Enable/disable Next button
//                         child: Text('Next'),
//                       ),
//                       ElevatedButton(
//                         onPressed: isSubmitting ||
//                             !_isAllQuestionsAnswered()
//                             ? null
//                             : _submitAnswers, // Enable/disable Submit button
//                         child: Text('Submit'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuestionsForCategory(Category category) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         for (var question in category.questions) ...[ // Loop through all questions in category
//           Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: _buildQuestion(question), // Build each question widget
//           ),
//         ],
//       ],
//     );
//   }
//
//   // Add this Map to store user comments for each question
//   Map<int, String?> questionComments = {};
//
//   Widget _buildQuestion(Question question) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           question.text,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 12),
//
//         // Image capture section
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Column(
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         color: Theme.of(context).primaryColor.withOpacity(0.1),
//                         child: TextButton.icon(
//                           onPressed: () async {
//                             // Capture image and handle errors
//                             await _captureImage(question.id);
//                           },
//                           icon: Icon(
//                             Icons.camera_alt,
//                             color: Colors.teal,
//                           ),
//                           label: Text(
//                             'Take Photo',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       // Video capture button
//                       _buildCaptureButton(
//                         onPressed: () => _captureMedia(question.id, true),
//                         icon: Icons.videocam,
//                         label: 'Take Video',
//                       ),
//                     ],
//                   ),
//
//                   if (questionImages[question.id] != null) ...[
//
//
//                     // Display the additional information (Address, IP, Device)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (locationInfo.isNotEmpty)
//                           Text(locationInfo, style: TextStyle(fontSize: 12, color: Colors.grey)),
//                         if (ipInfo.isNotEmpty)
//                           Text(ipInfo, style: TextStyle(fontSize: 12, color: Colors.grey)),
//                         if (deviceInfo.isNotEmpty)
//                           Text(deviceInfo, style: TextStyle(fontSize: 12, color: Colors.grey)),
//                       ],
//                     ),
//                     // Delete button to remove the image and info
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         setState(() {
//                           questionImages.remove(question.id); // Remove image
//                           locationInfo = '';  // Reset address info
//                           ipInfo = '';         // Reset IP info
//                           deviceInfo = '';     // Reset device info
//                         });
//                       },
//                     ),
//                   ] else ...[
//                     // If no image, show an info text that no image has been taken
//                     Text(
//                       'No photo taken',
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ]
//                 ],
//               ),
//
//
//
//               if (questionImages[question.id] != null) ...[
//                 SizedBox(height: 8),
//                 Container(
//                   height: 200,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       questionImages[question.id]!,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//
//         // Adding a comment section
//         Padding(
//           padding: const EdgeInsets.only(top: 16),
//           child: TextFormField(
//             initialValue: questionComments[question.id] ?? '',
//             onChanged: (value) {
//               setState(() {
//                 questionComments[question.id] = value;
//               });
//             },
//             maxLines: 3,  // Allows multiline input for comments
//             decoration: InputDecoration(
//               focusedBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Color(0xFF0074BA),),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               labelText: 'Enter your comment',
//               labelStyle: TextStyle(color: Color(0xFF0074BA),),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//
//           ),
//         ),
//
//         // Options for the question
//         if (question.options.isEmpty) ...[
//           if (question.type == 'number')
//             _buildTextFieldForNumber(question)
//           else
//             Text(
//               'This question is optional.',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//         ],
//         if (question.options.isNotEmpty) ...[
//           FormField<String>(
//             validator: (value) {
//               if (selectedOptions[question.id] == null &&
//                   touchedQuestions.contains(question.id)) {
//                 return 'Please select an option';
//               }
//               return null;
//             },
//             builder: (FormFieldState<String> field) {
//               return Column(
//                 children: [
//                   ...question.options.map(
//                         (option) => _buildOption(question.id, option, field),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ],
//     );
//   }
// }


  //   =============   //



import 'package:daiki_axis_stp/Core/Utils/api_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../Authentication/login_screen.dart';
import 'Inspector_quiz_model.dart';
//===================api services=====================//

class ApiService {
  Future<List<Category>> fetchCategories(int maintenanceScheduleId) async {
    try {
      String? token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      final response = await http.get(
        Uri.parse('${DaikiAPI.api_key}/api/v1/stp-data/perform/$maintenanceScheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['date'] != null && data['date']['categories'] != null) {
          final categoriesJson = data['date']['categories'];

          if (categoriesJson is List) {
            return categoriesJson.map((json) => Category.fromJson(json)).toList();
          } else {
            throw Exception('Categories data is not in the expected format.');
          }
        } else {
          throw Exception('Categories data not found.');
        }
      } else {
        throw Exception('Failed to load categories.');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}


class QuizScreen extends StatefulWidget {
  final int maintenanceScheduleId;
  final int projectId;
  final String project_name;
  final String next_maintenance_date;

  const QuizScreen({
    Key? key,
    required this.maintenanceScheduleId,
    required this.projectId,
    required this.project_name,
    required this.next_maintenance_date,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  List<Category> categories = [];
  bool isLoading = true;
  String? error;
  bool isSubmitting = false;

  Map<int, String?> selectedOptions = {};
  Map<int, File?> questionImages = {};
  Map<int, File?> questionVideos = {}; // New map for storing videos
  Map<int, String?> questionComments = {};
  Set<int> touchedQuestions = {};

  int currentCategoryIndex = 0;
  // Add state for pump visibility
  bool showRawWaterPump = false;
  bool showEffluentPump = false;

  Map<int, Question?> dependentQuestions = {};
  Map<int, bool> dependentQuestionsVisibility = {};
  Map<int, List<Question>> relatedQuestions = {};
  Map<int, bool> relatedQuestionsVisibility = {};
  List<Question> visibleQuestions = [];
  Map<int, bool> mainQuestionVisibility = {};

  Map<int, bool> outsideQuestionsVisibility = {};
  Map<int, Question?> outsideDependentQuestions = {};
  Map<int, List<Question>> outsideRelatedQuestions = {};

  Map<int, Question> outsideQuestions = {};

  // 🟢 Global maps for storing always-visible category questions
  Map<int, Question> alwaysVisibleQuestions = {};
  Map<int, bool> alwaysVisibleQuestionsVisibility = {};

  final Map<int, TextEditingController> controllers = {};

  String locationInfo = '';
  String ipInfo = '';
  String deviceInfo = '';

// 🟢 Categories that should always be shown
  final List<String> alwaysVisibleCategories = [
    "Outside",
    "Control Panel",
    "Hour Meter",
    "Blower Condition",
    "Tap Water Meter",
    "Water Level",
    "Water Lifted",
    "Take Photos",
    "Measuring Parameter",
    "Scum",
    "Circulation Volume",
    "Sludge",
    "Disinfection Chamber & Chlorine",
    "SEDIMENTATION CHAMB",
    "MOVING BED CHAMBER",
    "ANAEROBIC CONTACT MEDIA CHAMB",
    "Sedimentation & separation  CHAMB",
    "CLEAN INSIDE OF EACH CHAMBER",
    "RAW WATER TANK",
    "Effluent pump TANK",
    "AGITATION BLOWER",
    "MAIN BLOWER",
    "Circulation VOLUME",
    "CHECK OUTSIDE",
    "remarks"
  ];



  @override
  void initState() {
    super.initState();
    _loadQuizData();
    _checkSessionValidity();

  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      setState(() {
        isLoading = true; // Set loading to true when fetching data
        error = null; // Reset error state
      });

      final data = await _apiService.fetchCategories(widget.maintenanceScheduleId); // Fetch categories from API
      print("Fetched categories data: $data");

      setState(() {
        categories = data; // Set the categories list with fetched data
        isLoading = false; // Set loading to false once data is loaded
      });
      _processDependentQuestions();
      _initializeMainQuestionVisibility(); // Initialize main question visibility
      _updateVisibleQuestions(); // Initialize visible questions
    } catch (e) {
      setState(() {
        error = e.toString(); // Set error message if fetching fails
        isLoading = false; // Stop loading
      });
    }
  }

  void _updateVisibleQuestions() {
    visibleQuestions.clear();

    for (var category in categories) {
      for (var question in category.questions) {
        if (mainQuestionVisibility[question.id] == true || alwaysVisibleQuestionsVisibility[question.id] == true) {
          visibleQuestions.add(question);
        }

        // Update visibility for dependent/related questions
        for (var option in question.options) {
          if (selectedOptions[question.id] == option.value) {
            if (dependentQuestions[option.id] != null) {
              dependentQuestionsVisibility[option.id] = true;
              visibleQuestions.add(dependentQuestions[option.id]!);
            }
            if (dependentQuestions[option.id * 1000] != null) {
              dependentQuestionsVisibility[option.id * 1000] = true;
              visibleQuestions.add(dependentQuestions[option.id * 1000]!);
            }
            if (relatedQuestions[option.id] != null) {
              relatedQuestionsVisibility[option.id] = true;
              visibleQuestions.addAll(relatedQuestions[option.id]!);
            }
          }
        }
      }
    }
  }

  void _initializeMainQuestionVisibility() {
    for (var category in categories) {
      for (var question in category.questions) {
        // Initially, all questions in alwaysVisibleCategories or "Pumps type" are visible
        if (alwaysVisibleCategories.contains(category.name) || question.text == "Pumps type") {
          mainQuestionVisibility[question.id] = true;
        } else {
          mainQuestionVisibility[question.id] = false;
        }
      }
    }
  }




  void _processDependentQuestions() {
    for (var category in categories) {

      // 🟢 Process "Pumps" category
      if (category.name == "Pumps") {
        for (var question in category.questions) {
          if (question.text == "Pumps type") {
            for (var option in question.options) {
              List<String> relatedQuestionTexts = [];

              switch (option.text) {
                case "Raw Water Pump":
                  relatedQuestionTexts = ["1 Raw Water Pump", "2 Raw Water Pump"];
                  break;
                case "Effluent Pump":
                  relatedQuestionTexts = ["1 Effluent Pump"];
                  break;
                case "Both":
                  relatedQuestionTexts = ["1 Raw Water Pump", "2 Raw Water Pump", "1 Effluent Pump"];
                  break;
                case "N/A":
                  relatedQuestionTexts = [];
                  break;
              }

              // Store related questions
              relatedQuestions[option.id] = [];
              relatedQuestionsVisibility[option.id] = false;

              for (var text in relatedQuestionTexts) {
                Question? relatedQuestion = _findQuestionByText(category, text);
                if (relatedQuestion != null) {
                  relatedQuestions[option.id]!.add(relatedQuestion);
                }
              }
            }
          }
        }
      }
      // 🟢 Process categories that should always be visible
      if (alwaysVisibleCategories.contains(category.name)) {
        for (var question in category.questions) {
          alwaysVisibleQuestions[question.id] = question;
          alwaysVisibleQuestionsVisibility[question.id] = true; // Always visible
        }
      }
    }
  }


  Question? _findQuestionByText(Category category, String text) {
    for (var question in category.questions) {
      if (question.text == text) {
        return question;
      }
    }
    return null;
  }


  Future<void> _uploadMedia(int questionId, File mediaFile, bool isVideo) async {



    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.johkasou-erp.com/api/v1/image/store'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add required fields
      request.fields['question_id'] = questionId.toString();
      request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
      request.fields['schedule_id'] = widget.maintenanceScheduleId.toString();

      // Properly handle the file
      String fileName = mediaFile.path.split('/').last;
      String contentType = isVideo ? 'video/mp4' : 'image/jpeg';

      // Create MultipartFile with content type
      var stream = http.ByteStream(mediaFile.openRead());
      var length = await mediaFile.length();

      var multipartFile = http.MultipartFile(
        isVideo ? 'video' : 'media',  // Use "media" for images
        stream,
        length,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);

      // Debug prints
      print('Uploading file: ${mediaFile.path}');
      print('File exists: ${await mediaFile.exists()}');
      print('File size: $length bytes');
      print('Content type: $contentType');

      // Show upload progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading ${isVideo ? 'video' : 'image'}...')),
      );

      try {
        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        // Debug response
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${isVideo ? 'Video' : 'Image'} uploaded successfully')),
            );
          } else {
            throw Exception(responseData['message'] ?? 'Failed to upload media');
          }
        } else {
          // Print detailed error information
          print('Upload failed with status ${response.statusCode}');
          print('Response headers: ${response.headers}');
          print('Response body: ${response.body}');

          throw Exception('Failed to upload media. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during upload: $e');
        throw e;
      }
    } catch (e) {
      print('Error in _uploadMedia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading media: $e')),
      );
    }
  }





// Helper function to get file mime type
  String getMimeType(String path) {
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.mp4')) return 'video/mp4';
    if (path.endsWith('.mov')) return 'video/quicktime';
    return 'application/octet-stream';
  }



// Update the capture function to ensure proper file handling
  Future<void> _captureMedia(int questionId, bool isVideo) async {
    try {
      if (isVideo) {
        final XFile? video = await _imagePicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 3),
        );

        if (video != null) {
          final File videoFile = File(video.path);
          // Verify file exists and has size
          if (await videoFile.exists()) {
            setState(() {
              questionVideos[questionId] = videoFile;
            });
            await _uploadMedia(questionId, videoFile, true);
          } else {
            throw Exception('Video file not found after capture');
          }
        }
      } else {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1200,
        );

        if (photo != null) {
          // Fetch location (latitude and longitude)
          Position position = await _getCurrentLocation(); // Get the current location

          // Ensure GeocodingPlatform is available before using it
          if (GeocodingPlatform.instance != null) {
            // Convert latitude and longitude to address
            List<Placemark> placemarks = await GeocodingPlatform.instance!
                .placemarkFromCoordinates(position.latitude, position.longitude);

            // Check if placemarks is not empty
            if (placemarks.isNotEmpty) {
              Placemark place = placemarks.first;

              // Format the address
              locationInfo = '${place.street}, ${place.locality}, ${place.country}';
            } else {
              locationInfo = 'Address not found';
            }
          } else {
            locationInfo = 'Geocoding service is unavailable';
          }

          // Fetch IP address and device model
          String ipAddress = await _getIPAddress(); // Get the IP address
          String deviceModel = await _getDeviceModel(); // Get the device model

          // Update the UI state with the captured image and information
          setState(() {
            questionImages[questionId] = File(photo.path); // Store captured image
            ipInfo = 'IP: $ipAddress';
            deviceInfo = 'Device: $deviceModel';
          });
          final File imageFile = File(photo.path);
          // Verify file exists and has size
          if (await imageFile.exists()) {
            setState(() {
              questionImages[questionId] = imageFile;
            });
            await _uploadMedia(questionId, imageFile, false);
          } else {
            throw Exception('Image file not found after capture');
          }
        }
      }
    } catch (e) {
      print('Error in _captureMedia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing media: $e')),
      );
    }
  }


  Widget _buildDropdownForOptions(Question question) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        value: selectedOptions[question.id],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
        items: question.options.map((option) {
          return DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.text),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedOptions[question.id] = value!;
            touchedQuestions.add(question.id);
            mainQuestionVisibility[question.id] = true;

            print('Selected option for ${question.text} (ID: ${question.id}): $value');

            for (var key in dependentQuestionsVisibility.keys) {
              dependentQuestionsVisibility[key] = false;
            }
            for (var key in relatedQuestionsVisibility.keys) {
              relatedQuestionsVisibility[key] = false;
            }

            if (value != "N/A") {
              for (var option in question.options) {
                if (option.value == value) {
                  if (option.text == "Both") {
                    dependentQuestionsVisibility[option.id] = dependentQuestions[option.id] != null;
                    dependentQuestionsVisibility[option.id * 1000] = dependentQuestions[option.id * 1000] != null;
                  } else {
                    dependentQuestionsVisibility[option.id] = dependentQuestions[option.id] != null;
                  }
                  relatedQuestionsVisibility[option.id] = true;
                }
              }
            }
            _updateVisibleQuestions();
          });
        },
        validator: (value) {
          if (value == null) {
            return 'This field is required';
          }
          return null;
        },
        hint: Text('Select an option'),
      ),
    );
  }


  Future<void> _checkSessionValidity() async {
    final tokenExpired = await TokenManager.isTokenExpired();
    if (tokenExpired) {
      // If the token is expired, clear the session and log the user out
      await TokenManager.clearToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginPage()),
      );
    }
  }

  void _nextCategory() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (currentCategoryIndex < categories.length - 1) {
          currentCategoryIndex++; // Move to the next category
        }
      });
    }
  }

  void _previousCategory() {
    setState(() {
      if (currentCategoryIndex > 0) {
        currentCategoryIndex--; // Go back to the previous category
      }
    });
  }

  bool _isAllQuestionsAnswered() {
    bool allAnswered = true;
    for (var category in categories) {
      for (var question in category.questions) {
        bool isVisible = mainQuestionVisibility[question.id] == true ||
            alwaysVisibleQuestionsVisibility[question.id] == true ||
            (dependentQuestionsVisibility[question.id] == true) ||
            (relatedQuestionsVisibility[question.id] == true);

        if (isVisible && question.type == 'radio' && selectedOptions[question.id] == null) {
          print('Unanswered visible dropdown: ${question.text} (ID: ${question.id})');
          allAnswered = false;
        }
      }
    }
    if (!allAnswered) {
      print('Current selectedOptions: $selectedOptions');
      print('Current questionComments: $questionComments');
    }
    return allAnswered;
  }

  Future<void> _submitAnswers() async {
    if (!_isAllQuestionsAnswered()) {
      setState(() {
        error = 'Please answer all the required questions before submitting.';
      });
      return;
    }

    try {
      setState(() {
        isSubmitting = true;
        error = null;
      });

      String? token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      String? userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found or invalid. Please log in again.');
      }
      print('Submitting with user_id: $userId');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.johkasou-erp.com/api/v1/maintenance/store'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['maintenance_schedule_id'] = widget.maintenanceScheduleId.toString();
      request.fields['project_id'] = widget.projectId.toString();
      request.fields['user_id'] = userId;

      int index = 0;
      for (var category in categories) {
        for (var question in category.questions) {
          if (selectedOptions[question.id] != null || questionComments[question.id] != null) {
            String responseKey = 'responses[$index]';
            request.fields['$responseKey[question_id]'] = question.id.toString();
            request.fields['$responseKey[category_id]'] = category.id.toString();
            request.fields['$responseKey[response]'] = selectedOptions[question.id] ?? '';
            request.fields['$responseKey[remarks]'] = questionComments[question.id] ?? '';
            // ... (image handling unchanged)
            index++;
          }
        }
      }

      print('Request fields: ${request.fields}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true || responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Answers and images submitted successfully')),
          );
          Navigator.pop(context);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to submit answers');
        }
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to submit answers');
      }
    } catch (e) {
      print('Error submitting answers: $e');
      setState(() {
        error = 'Failed to submit answers: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to submit answers')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Widget _buildCommentField(Question question) {
    return TextFormField(
      initialValue: questionComments[question.id] ?? '',
      onChanged: (value) {
        setState(() {
          questionComments[question.id] = value;
        });
      },
      maxLines: 1,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0074BA)),
          borderRadius: BorderRadius.circular(8),
        ),
        labelText: 'Enter your comment',
        labelStyle: TextStyle(color: Color(0xFF0074BA)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }



  Widget _buildTextFieldForNumber(Question question) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: controllers[question.id],  // Use the initialized controller
        onChanged: (value) {
          setState(() {
            selectedOptions[question.id] = value;
            touchedQuestions.add(question.id);
          });
        },
        validator: (value) {
          if (question.required == 1 && (value == null || value.isEmpty)) {
            return 'This field is required';
          }

          if (value != null && value.isNotEmpty) {
            final doubleValue = double.tryParse(value);

            if (doubleValue == null) {
              return 'Please enter a valid number';
            }

            if (question.min != null && doubleValue < question.min!) {
              return 'Please enter a value greater than or equal to ${question.min}';
            }

            if (doubleValue > 100) {
              return 'Please enter a value less than or equal to 100';
            }
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: '${question.text}${question.unit != null ? " (${question.unit})" : ""}',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Text(
                widget.project_name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Maintenance Due Date:${widget.next_maintenance_date}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error: $error',
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: _loadQuizData,
                child: Text('Retry'),
              ),
            ],
          ),
        )
            : Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(bottom: 100),
                children: [
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(16),
                          child: Text(
                            categories[currentCategoryIndex].name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: _buildQuestionsForCategory(categories[currentCategoryIndex]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentCategoryIndex > 0 ? _previousCategory : null,
                        child: Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _nextCategory,
                        child: Text('Next'),
                      ),
                      ElevatedButton(
                        onPressed: isSubmitting || !_isAllQuestionsAnswered() ? null : _submitAnswers,//isSubmitting || !_isAllQuestionsAnswered() ? null :
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildQuestionsForCategory(Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🟢 Always Show "Pumps type" First
        if (category.name == "Pumps") ...[
          for (var question in category.questions)
            if (question.text == "Pumps type")
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildQuestion(question),
              ),

          // Show dependent pump-related questions based on selection
          if (selectedOptions.containsKey(194) && selectedOptions[194] != null) ...[
            for (var option in categories.firstWhere((c) => c.name == "Pumps").questions
                .firstWhere((q) => q.text == "Pumps type").options) ...[
              if (selectedOptions[194] == option.value && relatedQuestions[option.id] != null && relatedQuestionsVisibility[option.id]!) ...[
                for (var relatedQuestion in relatedQuestions[option.id]!) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildQuestion(relatedQuestion),
                  ),
                ],
              ],
            ]
          ],
        ],

        // 🟢 Show Always-Visible Categories (Outside, Control Panel, Hour Meter, etc.)
        if (alwaysVisibleCategories.contains(category.name)) ...[
          for (var question in category.questions)
            if (alwaysVisibleQuestionsVisibility.containsKey(question.id) && alwaysVisibleQuestionsVisibility[question.id]!)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildQuestion(question),
              ),
        ],
      ],
    );
  }



  Widget _buildCaptureButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.teal),
        label: Text(label, style: TextStyle(color: Colors.black)),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildNumberField(Question question) {
    controllers.putIfAbsent(question.id, () => TextEditingController(text: questionComments[question.id] ?? ''));

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controllers[question.id],
        decoration: InputDecoration(
          labelText: question.text,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            questionComments[question.id] = value;
            print('Stored comment for ${question.text} (ID: ${question.id}): $value');
          });
        },
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Title
        Text(
          question.text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),

        // Media capture section
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Photo capture button
                  _buildCaptureButton(
                    onPressed: () => _captureMedia(question.id, false),
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                  ),
                  SizedBox(width: 8),
                  // Video capture button
                  _buildCaptureButton(
                    onPressed: () => _captureMedia(question.id, true),
                    icon: Icons.videocam,
                    label: 'Take Video',
                  ),
                ],
              ),


              if (questionImages[question.id] != null) ...[


                // Display the additional information (Address, IP, Device)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (locationInfo.isNotEmpty)
                      Text(locationInfo, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    if (ipInfo.isNotEmpty)
                      Text(ipInfo, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    if (deviceInfo.isNotEmpty)
                      Text(deviceInfo, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                // Delete button to remove the image and info
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      questionImages.remove(question.id); // Remove image
                      locationInfo = '';  // Reset address info
                      ipInfo = '';         // Reset IP info
                      deviceInfo = '';     // Reset device info
                    });
                  },
                ),
              ] else ...[
                // If no image, show an info text that no image has been taken
                Text(
                  'No photo taken',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ]
            ],
          ),
        ),


        // Display captured image
        if (questionImages[question.id] != null) ...[
          SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                questionImages[question.id]!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],


        // Question options (if any)
        if (question.options.isNotEmpty)
          _buildDropdownForOptions(question),

        // Number or String input field
        if (question.type == 'number' || question.type == 'String')
          _buildTextFieldForNumber(question),

        // Comment section
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildCommentField(question),
        ),
      ],
    );
  }
}


// Fetch current location
Future<Position> _getCurrentLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

// Fetch IP address
Future<String> _getIPAddress() async {
  try {
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['ip'];
    } else {
      throw Exception('Failed to fetch IP address');
    }
  } catch (e) {
    throw Exception('Error fetching IP address: $e');
  }
}

// Fetch device model
Future<String> _getDeviceModel() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.model; // Get Android device model
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    return iosInfo.model; // Get iOS device model
  } else {
    return 'Unknown Device';
  }
}
