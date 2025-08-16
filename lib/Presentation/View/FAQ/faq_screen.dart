import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../Core/Utils/api_service.dart';
import '../../../Model/faq_model.dart';




class ApiService {
  static const String baseUrl = '${DaikiAPI.api_key}/api/v1'; // Updated to /api/v1

  Future<List<FAQ>> getFAQs() async {
    try {
      String? token = await TokenManager.getToken();
      print('Token: ${token != null ? 'Available' : 'Missing'}');
      if (token == null || await TokenManager.isTokenExpired()) {
        token = await _refreshToken();
        if (token == null) throw Exception('Token refresh failed');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/faqs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('getFAQs Response Status: ${response.statusCode}');
      print('getFAQs Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Parsed JSON: $jsonResponse');
        if (jsonResponse['status'] == true &&
            jsonResponse['data'] != null &&
            jsonResponse['data']['faqPaginate'] != null &&
            jsonResponse['data']['faqPaginate']['data'] != null) {
          final List<dynamic> faqList = jsonResponse['data']['faqPaginate']['data'];
          print('FAQ List: $faqList');
          return faqList.map((item) => FAQ.fromJson(item)).toList();
        }
        print('No FAQs found in response');
        return [];
      } else {
        throw Exception('Failed to load FAQs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getFAQs: $e');
      throw Exception('Error fetching FAQs: $e');
    }
  }

  Future<String?> _refreshToken() async {
    final newToken = await TokenManager.refreshToken();
    print('Refreshed Token: ${newToken != null ? 'Available' : 'Missing'}');
    return newToken;
  }

  Future<FAQ> createFAQ(FAQ faq) async {
    try {
      String? token = await TokenManager.getToken();
      print('Token for createFAQ: ${token != null ? 'Available' : 'Missing'}');
      if (token == null || await TokenManager.isTokenExpired()) {
        token = await _refreshToken();
        if (token == null) throw Exception('Token refresh failed');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/faqs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(faq.toJson()),
      );

      print('createFAQ Response Status: ${response.statusCode}');
      print('createFAQ Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          return FAQ.fromJson(jsonResponse['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create FAQ: ${response.body}');
      }
    } catch (e) {
      print('Error in createFAQ: $e');
      throw Exception('Error creating FAQ: $e');
    }
  }

  Future<FAQ> updateFAQ(int id, FAQ faq) async {
    try {
      String? token = await TokenManager.getToken();
      print('Token for updateFAQ: ${token != null ? 'Available' : 'Missing'}');
      if (token == null || await TokenManager.isTokenExpired()) {
        token = await _refreshToken();
        if (token == null) throw Exception('Token refresh failed');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/faqs/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(faq.toJson()),
      );

      print('updateFAQ Response Status: ${response.statusCode}');
      print('updateFAQ Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          return FAQ.fromJson(jsonResponse['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to update FAQ: ${response.body}');
      }
    } catch (e) {
      print('Error in updateFAQ: $e');
      throw Exception('Error updating FAQ: $e');
    }
  }

  Future<void> deleteFAQ(int id) async {
    try {
      String? token = await TokenManager.getToken();
      print('Token for deleteFAQ: ${token != null ? 'Available' : 'Missing'}');
      if (token == null || await TokenManager.isTokenExpired()) {
        token = await _refreshToken();
        if (token == null) throw Exception('Token refresh failed');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/faqs/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('deleteFAQ Response Status: ${response.statusCode}');
      print('deleteFAQ Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete FAQ: ${response.body}');
      }
    } catch (e) {
      print('Error in deleteFAQ: $e');
      throw Exception('Error deleting FAQ: $e');
    }
  }
}

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final ApiService _apiService = ApiService();
  List<FAQ> _faqs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final faqs = await _apiService.getFAQs();
      print('Loaded FAQs: ${faqs.length}');
      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading FAQs: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddEditDialog([FAQ? faq]) async {
    final titleController = TextEditingController(text: faq?.title ?? '');
    final descriptionController = TextEditingController(text: faq?.description ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(faq == null ? 'Add FAQ' : 'Edit FAQ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final newFaq = FAQ(
                  id: faq?.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  userId: 43,
                );

                if (faq == null) {
                  await _apiService.createFAQ(newFaq);
                } else {
                  await _apiService.updateFAQ(faq.id!, newFaq);
                }

                Navigator.pop(context);
                _loadFAQs();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('FAQ ${faq == null ? 'created' : 'updated'} successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Future<void> _confirmDelete(FAQ faq) async {
  //   return showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Delete FAQ'),
  //       content: Text('Are you sure you want to delete this FAQ?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             try {
  //               await _apiService.deleteFAQ(faq.id!);
  //               Navigator.pop(context);
  //               _loadFAQs();
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('FAQ deleted successfully')),
  //               );
  //             } catch (e) {
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text('Error: $e')),
  //               );
  //             }
  //           },
  //           child: Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQ",style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF189F8F),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadFAQs,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadFAQs,
        child: _faqs.isEmpty
            ? Center(child: Text('No FAQs found'))
            : ListView.builder(
          itemCount: _faqs.length,
          itemBuilder: (context, index) {
            final faq = _faqs[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text(
                  faq.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(faq.description),
                  ),
                  // ButtonBar(
                  //   alignment: MainAxisAlignment.end,
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(Icons.edit, color: Colors.blue),
                  //       onPressed: () => _showAddEditDialog(faq),
                  //     ),
                  //     IconButton(
                  //       icon: Icon(Icons.delete, color: Colors.red),
                  //       onPressed: () => _confirmDelete(faq),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showAddEditDialog(),
      //   child: Icon(Icons.add),
      // ),
    );
  }
}