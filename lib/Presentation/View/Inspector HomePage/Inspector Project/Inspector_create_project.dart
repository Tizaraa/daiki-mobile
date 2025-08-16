import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../Core/Token-Manager/token_manager_screen.dart';
import '../../../../Core/Utils/api_service.dart';



class Inspector_CreateProjectScreen extends StatefulWidget {
  @override
  _Inspector_CreateProjectScreenState createState() => _Inspector_CreateProjectScreenState();
}

class _Inspector_CreateProjectScreenState extends State<Inspector_CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form data controllers
  TextEditingController pjCodeController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController projectStatusController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  DateTime? contractedDate;
  DateTime? expireDate;
  DateTime? installationStartTime;
  DateTime? installationEndTime;

  // Dropdown selections
  String? selectedClient;
  String? selectedMaintenanceStatus;
  String? selectedPIC;

  // Predefined lists (should be fetched from the backend ideally)
  List<String> clients = ['1', '2', '3']; // Example
  List<String> maintenanceStatuses = ['Pending', 'Completed', 'In Progress'];
  List<String> pics = ['1', '2', '3']; // Example

  bool isLoading = false;

  // POST API URL
  static const String apiUrl = '${DaikiAPI.api_key}/api/v1/project';

  // Function to validate dates
  bool validateDates() {
    if (contractedDate == null || expireDate == null ||
        installationStartTime == null || installationEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select all dates'))
      );
      return false;
    }

    if (expireDate!.isBefore(contractedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expire date must be after contracted date'))
      );
      return false;
    }

    if (installationEndTime!.isBefore(installationStartTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Installation end date must be after start date'))
      );
      return false;
    }

    return true;
  }

  // Function to handle validation errors
  void handleValidationError(String responseBody) {
    try {
      final Map<String, dynamic> errorData = json.decode(responseBody);

      // Check for errors object in the response
      if (errorData.containsKey('errors')) {
        final errors = errorData['errors'];
        // Combine all error messages
        String errorMessage = '';

        if (errors is Map) {
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '${key}: ${value.join(', ')}\n';
            } else {
              errorMessage += '${key}: $value\n';
            }
          });
        } else if (errors is String) {
          errorMessage = errors;
        }

        // Show error dialog with detailed messages
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Validation Error'),
              content: SingleChildScrollView(
                child: Text(errorMessage),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (errorData.containsKey('message')) {
        // Show simple error message if no detailed errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'])),
        );
      }
    } catch (e) {
      // If parsing fails, show generic error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected validation error occurred')),
      );
    }
  }

  // Updated submitForm function
  Future<void> submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false) || !validateDates()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = await TokenManager.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token is invalid or expired. Please login again.'))
        );
        return;
      }

      // Updated projectData to keep capacity as string
      final Map<String, dynamic> projectData = {
        'pj_code': pjCodeController.text.trim(),
        'project_name': projectNameController.text.trim(),
        'location': locationController.text.trim(),
        'client': selectedClient,
        'capacity': capacityController.text.trim(), // Keep as string, don't convert to int
        'project_status': projectStatusController.text.trim(),
        'maintenance_status': selectedMaintenanceStatus,
        'contracted_date': contractedDate?.toUtc().toIso8601String(),
        'expire_date': expireDate?.toUtc().toIso8601String(),
        'pic': selectedPIC,
        'installation_start_time': installationStartTime?.toUtc().toIso8601String(),
        'installation_end_time': installationEndTime?.toUtc().toIso8601String(),
        'remarks': remarksController.text.trim(),
        'project_type': 'Private',
        'project_facilities': 'Residential',
      };


      // Print request data for debugging
      print('Request URL: $apiUrl');
      print('Request Headers: ${{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}}');
      print('Request Body: ${json.encode(projectData)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Add Accept header
          'Authorization': 'Bearer $token',
        },
        body: json.encode(projectData),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      switch (response.statusCode) {
        case 200:
        case 201:
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Project created successfully'))
            );
            Navigator.pop(context);
          } else {
            throw Exception(responseData['message'] ?? 'Unknown error occurred');
          }
          break;
        case 422:
          handleValidationError(response.body);
          break;
        case 400:
          throw Exception('Invalid data format. Please check your inputs.');
        case 401:
          throw Exception('Unauthorized. Please login again.');
        case 403:
          throw Exception('Permission denied.');
        default:
          throw Exception('Server error occurred (${response.statusCode}). Please try again later.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to select dates
  Future<void> selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Project',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF00B2AE),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Project Code Field
                  _buildTextField(
                    controller: pjCodeController,
                    label: 'Project Code *',
                    icon: Icons.code,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter project code' : null,
                  ),
                  // Project Name Field
                  _buildTextField(
                    controller: projectNameController,
                    label: 'Project Name *',
                    icon: Icons.business,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter project name' : null,
                  ),
                  // Location Field
                  _buildTextField(
                    controller: locationController,
                    label: 'Location *',
                    icon: Icons.location_on,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter location' : null,
                  ),
                  // Client Dropdown
                  _buildDropdown(
                    label: 'Client *',
                    value: selectedClient,
                    items: clients,
                    onChanged: (value) => setState(() => selectedClient = value),
                  ),
                  // Capacity Field
                  _buildTextField(
                    controller: capacityController,
                    label: 'Capacity *',
                    icon: Icons.group,
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter capacity' : null,
                  ),
                  // Project Status Field
                  _buildTextField(
                    controller: projectStatusController,
                    label: 'Project Status *',
                    icon: Icons.check_circle,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter project status' : null,
                  ),
                  // Maintenance Status Dropdown
                  _buildDropdown(
                    label: 'Maintenance Status *',
                    value: selectedMaintenanceStatus,
                    items: maintenanceStatuses,
                    onChanged: (value) => setState(() => selectedMaintenanceStatus = value),
                  ),
                  // Date Pickers
                  _buildDatePicker(label: 'Contracted Date *', selectedDate: contractedDate, onDateSelected: (date) => setState(() => contractedDate = date)),
                  _buildDatePicker(label: 'Expire Date *', selectedDate: expireDate, onDateSelected: (date) => setState(() => expireDate = date)),
                  _buildDatePicker(label: 'Installation Start Date *', selectedDate: installationStartTime, onDateSelected: (date) => setState(() => installationStartTime = date)),
                  _buildDatePicker(label: 'Installation End Date *', selectedDate: installationEndTime, onDateSelected: (date) => setState(() => installationEndTime = date)),
                  // PIC Dropdown
                  _buildDropdown(
                    label: 'PIC *',
                    value: selectedPIC,
                    items: pics,
                    onChanged: (value) => setState(() => selectedPIC = value),
                  ),
                  // Remarks Field
                  _buildTextField(
                    controller: remarksController,
                    label: 'Remarks',
                    icon: Icons.comment,
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : submitForm,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Project',style: TextStyle(color: Colors.white,fontSize: 20),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00B2AE),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        items: items.map((client) {
          return DropdownMenuItem(
            value: client,
            child: Text(client),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('$label: ${selectedDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'}'),
        onTap: () => selectDate(context, selectedDate, onDateSelected),
        tileColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers
    pjCodeController.dispose();
    projectNameController.dispose();
    locationController.dispose();
    capacityController.dispose();
    projectStatusController.dispose();
    remarksController.dispose();
    super.dispose();
  }
}
