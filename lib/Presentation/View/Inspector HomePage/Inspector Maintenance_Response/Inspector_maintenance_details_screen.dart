import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';

class Inspector_MaintenanceDetailScreen extends StatefulWidget {
  final String id;
  final String? johkasouModelId; // Optional Johkasou model ID

  Inspector_MaintenanceDetailScreen({required this.id, this.johkasouModelId});

  @override
  _Inspector_MaintenanceDetailScreenState createState() =>
      _Inspector_MaintenanceDetailScreenState();
}

class _Inspector_MaintenanceDetailScreenState
    extends State<Inspector_MaintenanceDetailScreen> {
  late Future<String> _pdfFilePath;
  bool _isLoading = true;
  String? _errorMessage;

  Future<String> fetchPdfData() async {
    try {
      final token = await TokenManager.getToken();

      // Log token status
      print('Token: ${token != null ? 'Available' : 'Missing'}');
      if (token == null || await TokenManager.isTokenExpired()) {
        throw Exception('Token is missing or expired');
      }

      // Construct the API URL
      String apiUrl = widget.johkasouModelId != null
          ? '${DaikiAPI.api_key}/api/v1/maintenance/responses-pdf/${widget.id}?johkasou_model_id=${widget.johkasouModelId}'
          : '${DaikiAPI.api_key}/api/v1/maintenance/responses-pdf-for-all-model/${widget.id}';

      // Log the parameters and URL
      print('Fetching PDF with:');
      print('  Maintenance Response ID: ${widget.id}');
      print('  Johkasou Model ID: ${widget.johkasouModelId ?? 'Not provided'}');
      print('  API URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Log response details
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      if (response.statusCode != 200) {
        print('Response Body: ${response.body}');
        throw Exception('Failed to load PDF: ${response.statusCode} - ${response.reasonPhrase}');
      }

      // Verify content type
      final contentType = response.headers['content-type'] ?? 'Unknown';
      print('Content-Type: $contentType');
      if (!contentType.contains('application/pdf')) {
        print('Response Body: ${response.body}');
        throw Exception('Invalid response: Expected PDF, got $contentType');
      }

      // Save the PDF file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/maintenance_report_${widget.id}${widget.johkasouModelId ?? ''}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      // Log file path
      print('PDF saved to: ${file.path}');

      return file.path;
    } catch (e) {
      // Log the error
      print('Error fetching PDF: $e');
      throw Exception('Error fetching PDF: $e');
    }
  }

  Future<void> downloadPdf(String filePath) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final destinationPath =
            '${downloadsDir.path}/maintenance_report_${widget.id}${widget.johkasouModelId ?? ''}.pdf';
        await File(filePath).copy(destinationPath);

        // Log download path
        print('PDF downloaded to: $destinationPath');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded to $destinationPath'),
          ),
        );
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      // Log the error
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfFilePath = fetchPdfData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maintenance Report"),
        actions: [
          IconButton(
            icon: Icon(Icons.download, size: 30, color: Colors.teal),
            onPressed: () async {
              final filePath = await _pdfFilePath;
              if (filePath.isNotEmpty) {
                await downloadPdf(filePath);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No PDF file available to download'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _pdfFilePath,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No PDF data available'));
          } else {
            return SfPdfViewer.file(
              File(snapshot.data!),
              onDocumentLoaded: (details) {
                setState(() {
                  _isLoading = false;
                });
              },
              onDocumentLoadFailed: (error) {
                setState(() {
                  _errorMessage = error.toString();
                  _isLoading = false;
                });
              },
            );
          }
        },
      ),
    );
  }
}