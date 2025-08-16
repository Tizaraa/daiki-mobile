import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../../Core/Utils/api_service.dart';



class Inspector_Create_Inventory extends StatefulWidget {
  @override
  _Inspector_Create_InventoryState createState() => _Inspector_Create_InventoryState();
}

class _Inspector_Create_InventoryState extends State<Inspector_Create_Inventory> {
  // Controllers for text fields to capture user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _calibrationTimeController = TextEditingController();
  final TextEditingController _lastCalibrationDateController = TextEditingController();

  DateTime? _calibrationTime;
  DateTime? _lastCalibrationDate;

  // Dropdown values for type, status, and condition
  String? _selectedType;
  String? _selectedStatus;
  String? _selectedCondition;

  // List of options for type
  final List<String> _typeOptions = [
    "No Option","Testing apparatus", "Maintenance kit", "Spare parts"
  ];

  // List of options for status
  final List<String> _statusOptions = ["No Option","active", "inactive"];

  // List of options for condition
  final List<String> _conditionOptions = [
    "No Option","Good", "Not Good", "Not Working", "Need Replacement"
  ];

  // Function to post data to the API
  Future<void> postData() async {
    // Fetch token from TokenManager
    String? token = await TokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token not found. Please log in.')));
      return;
    }

    // Convert type, status, and condition to integers
    int? typeInt = _typeOptions.indexOf(_selectedType ?? "");
    int? statusInt = _statusOptions.indexOf(_selectedStatus ?? "");
    int? conditionInt = _conditionOptions.indexOf(_selectedCondition ?? "");

    final String url = '${DaikiAPI.api_key}/api/v1/inventory';

    // Collect the data from user input
    final Map<String, dynamic> data = {
      "name": _nameController.text,
      "description": _descriptionController.text,
      "unit": _unitController.text,
      "type": typeInt,
      "condition": conditionInt,
      "calibration_time": _calibrationTime?.toIso8601String() ?? '',
      "last_calibration_date": _lastCalibrationDate?.toIso8601String() ?? '',
      "status": statusInt,
    };

    // Try sending the POST request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Sending data as JSON
          'Authorization': 'Bearer $token', // Include the token
        },
        body: jsonEncode(data), // Encode the data as JSON
      );

      if (response.statusCode == 200) {
        // Successfully posted the data
        print('Data posted successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Data posted successfully!'),
        ));
      } else {
        // Handle error response
        print('Failed to post data. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to post data!'),
        ));
      }
    } catch (e) {
      // Handle any exceptions
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error occurred while posting data.'),
      ));
    }
  }

  // Function to show date picker and update the date
  Future<void> _selectDate(BuildContext context, bool isCalibrationTime) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    // If we are editing, set initialDate to the current date
    if (isCalibrationTime && _calibrationTime != null) {
      initialDate = _calibrationTime!;
    } else if (!isCalibrationTime && _lastCalibrationDate != null) {
      initialDate = _lastCalibrationDate!;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        if (isCalibrationTime) {
          _calibrationTime = picked;
          _calibrationTimeController.text = "${picked.toLocal()}".split(' ')[0]; // Format as yyyy-MM-dd
        } else {
          _lastCalibrationDate = picked;
          _lastCalibrationDateController.text = "${picked.toLocal()}".split(' ')[0]; // Format as yyyy-MM-dd
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              items: _typeOptions.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
              items: _conditionOptions.map((String condition) {
                return DropdownMenuItem<String>(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _calibrationTimeController,
              decoration: InputDecoration(
                labelText: 'Calibration Time (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              onTap: () => _selectDate(context, true), // Open date picker
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastCalibrationDateController,
              decoration: InputDecoration(
                labelText: 'Last Calibration Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              onTap: () => _selectDate(context, false), // Open date picker
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: postData, // Call the postData function when pressed
              child: Text('Post Data'),
            ),
          ],
        ),
      ),
    );
  }
}
