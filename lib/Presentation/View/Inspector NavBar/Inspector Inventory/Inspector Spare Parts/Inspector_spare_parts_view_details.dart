// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:daiki_axis_stp/Utils/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
//
// import '../../../../Token-Manager/token_manager_screen.dart';
//
//
// class InspectorSparePartsViewDetails extends StatefulWidget {
//   final int itemId;
//
//   const InspectorSparePartsViewDetails({Key? key, required this.itemId}) : super(key: key);
//
//   @override
//   _InspectorSparePartsViewDetailsState createState() => _InspectorSparePartsViewDetailsState();
// }
//
// class _InspectorSparePartsViewDetailsState extends State<InspectorSparePartsViewDetails> {
//   bool isLoading = true;
//   bool hasError = false;
//   String errorMessage = '';
//   InspectorSpareParts? itemDetails;
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _unitController;
//   late TextEditingController _conditionController;
//   late TextEditingController _skuController;
//   late TextEditingController _liftingPriceController;
//   late TextEditingController _remarksController;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _descriptionController = TextEditingController();
//     _unitController = TextEditingController();
//     _conditionController = TextEditingController();
//     _skuController = TextEditingController();
//     _liftingPriceController = TextEditingController();
//     _remarksController = TextEditingController();
//     fetchItemDetails();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _unitController.dispose();
//     _conditionController.dispose();
//     _skuController.dispose();
//     _liftingPriceController.dispose();
//     _remarksController.dispose();
//     super.dispose();
//   }
//
//   // Get the token from TokenManager
//   Future<String?> getToken() async {
//     return await TokenManager.getToken();
//   }
//
//   String formatDate(DateTime? date) {
//     if (date == null) return 'Not available';
//     return DateFormat('dd MMM yyyy, HH:mm').format(date);
//   }
//
//
//   Future<void> updateItemDetails() async {
//     final String url = 'https://backend.johkasou-erp.com/api/v1/inventory/${widget.itemId}';
//
//     try {
//       final token = await getToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }
//
//       // Parse lifting price safely
//       double liftingPrice = 0.0;
//       try {
//         liftingPrice = double.parse(_liftingPriceController.text);
//       } catch (e) {
//         print("Error parsing lifting price: $e");
//         // Use the current value if parsing fails
//         liftingPrice = itemDetails?.liftingPrice ?? 0.0;
//       }
//
//       final response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'name': _nameController.text,
//           'description': _descriptionController.text,
//           'unit': _unitController.text,
//           'condition': _conditionController.text,
//           'sku': _skuController.text,
//           'lifting_price': liftingPrice,
//           'remarks': _remarksController.text,
//         }),
//       );
//
//       print("Update response status: ${response.statusCode}");
//       print("Update response body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['status'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Item updated successfully')),
//           );
//           fetchItemDetails();
//         } else {
//           throw Exception(data['message'] ?? 'Invalid response format');
//         }
//       } else {
//         throw Exception('Failed to update item details: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       print("Error updating item: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   Widget buildSection(String title, List<Widget> children) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width,
//                 color: TizaraaColors.Tizara,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),),
//                 )),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(value.isNotEmpty ? value : 'N/A'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildBasicDetails() {
//     // Debug info about the state of itemDetails
//     print("Building basic details. itemDetails is ${itemDetails == null ? 'null' : 'not null'}");
//     if (itemDetails != null) {
//       print("Item name: ${itemDetails!.name}");
//       print("Stock object: ${itemDetails!.stock == null ? 'null' : 'not null'}");
//       if (itemDetails!.stock != null) {
//         print("Stock quantity: ${itemDetails!.stock!.quantity}");
//       }
//     }
//
//     return buildSection(
//       'Basic Details',
//       [
//         buildDetailRow('Name', itemDetails?.name ?? 'N/A'),
//         buildDetailRow('Description', itemDetails?.description ?? 'No description available'),
//         buildDetailRow('Condition', itemDetails?.condition ?? 'Unknown'),
//         buildDetailRow('Unit', itemDetails?.unit ?? 'Unknown unit'),
//         buildDetailRow('Created At', itemDetails?.createdAt != null ? formatDate(itemDetails?.createdAt) : 'N/A'),
//         buildDetailRow('Updated At', itemDetails?.updatedAt != null ? formatDate(itemDetails?.updatedAt) : 'N/A'),
//         buildDetailRow('Type', itemDetails?.type == 1 ? 'Type 1' :
//         itemDetails?.type == 2 ? 'Type 2' :
//         itemDetails?.type == 3 ? 'Type 3' : 'Unknown'),
//         buildDetailRow('Status', itemDetails?.status == 1 ? 'Active' : 'Inactive'),
//         buildDetailRow('Calibration Time',
//             itemDetails?.calibrationTime != null ? formatDate(itemDetails?.calibrationTime) : 'N/A'),
//         buildDetailRow('Last Calibration Date',
//             itemDetails?.lastCalibrationDate != null ? formatDate(itemDetails?.lastCalibrationDate) : 'N/A'),
//         buildDetailRow('SKU', itemDetails?.sku ?? 'N/A'),
//         buildDetailRow('Lifting Price', itemDetails?.liftingPrice.toString() ?? 'N/A'),
//         buildDetailRow('Remarks', itemDetails?.remarks ?? 'No remarks available'),
//         buildDetailRow('Stock Quantity',
//             itemDetails?.stock?.quantity?.toString() ?? 'N/A'),
//         buildDetailRow('Stock Minimum Quantity',
//             itemDetails?.stock?.minimumQuantity?.toString() ?? 'N/A'),
//         buildDetailRow('Stock Created At',
//             itemDetails?.stock?.createdAt != null ? formatDate(itemDetails?.stock?.createdAt) : 'N/A'),
//         buildDetailRow('Stock Updated At',
//             itemDetails?.stock?.updatedAt != null ? formatDate(itemDetails?.stock?.updatedAt) : 'N/A'),
//       ],
//     );
//   }
//
//
//
//
//
//   Future<void> fetchItemDetails() async {
//     print("Fetching item details for ID: ${widget.itemId}");
//     final String url = 'https://backend.johkasou-erp.com/api/v1/inventory/${widget.itemId}';
//
//     try {
//       final token = await getToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }
//
//       print("Making API request to: $url");
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print("API Response Status Code: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("API Response Data: ${json.encode(data)}");
//
//         if (data['status'] == true && data['data'] != null) {
//           print("Processing response data...");
//
//           // Create the model object
//           final parsedItem = InspectorSpareParts.fromJson(data['data']);
//           print("Successfully parsed item: ${parsedItem.name}");
//
//           setState(() {
//             itemDetails = parsedItem;
//             try {
//               _nameController.text = itemDetails?.name ?? '';
//               _descriptionController.text = itemDetails?.description ?? '';
//               _unitController.text = itemDetails?.unit ?? '';
//               _conditionController.text = itemDetails?.condition ?? '';
//               _skuController.text = itemDetails?.sku ?? '';
//               _liftingPriceController.text = itemDetails?.liftingPrice.toString() ?? '0';
//               _remarksController.text = itemDetails?.remarks ?? '';
//               print("Text controllers updated successfully");
//             } catch (e) {
//               print("Error updating text controllers: $e");
//             }
//             isLoading = false;
//             hasError = false;
//           });
//
//           print("State updated, item details loaded");
//         } else {
//           print("API returned false status or null data");
//           throw Exception(data['message'] ?? 'Invalid response format');
//         }
//       } else {
//         print("API request failed with status code: ${response.statusCode}");
//         throw Exception('Failed to load item details: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       print("Error in fetchItemDetails: $e");
//       setState(() {
//         isLoading = false;
//         hasError = true;
//         errorMessage = e.toString();
//       });
//     }
//   }
//
//   Widget buildImage(String? token) {
//     if (itemDetails?.inventoryImage == null || itemDetails!.inventoryImage.isEmpty) {
//       return const Icon(Icons.image, size: 200, color: Colors.grey);
//     }
//
//     final String encodedImageUrl = Uri.encodeFull('https://minio.johkasou-erp.com/daiki/image/${itemDetails!.inventoryImage}');
//     print("Image URL: $encodedImageUrl");
//
//     return Container(
//       height: 200,
//       width: double.infinity,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: CachedNetworkImage(
//           imageUrl: encodedImageUrl,
//           fit: BoxFit.cover,
//           httpHeaders: token != null ? {
//             'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           } : {},
//           placeholder: (context, url) => Center(child: CircularProgressIndicator()),
//           errorWidget: (context, url, error) {
//             print("Error loading image: $error");
//             return Container(
//               height: 200,
//               color: Colors.grey[200],
//               child: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("Building main widget. isLoading: $isLoading, hasError: $hasError");
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Inspector Spare Parts Details'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : hasError
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Error: $errorMessage'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   isLoading = true;
//                   hasError = false;
//                 });
//                 fetchItemDetails();
//               },
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       )
//           : itemDetails == null
//           ? Center(child: Text('No data available. Please try again.'))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             FutureBuilder<String?>(
//               future: getToken(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else {
//                   return buildImage(snapshot.data);
//                 }
//               },
//             ),
//             const SizedBox(height: 16),
//             buildBasicDetails(),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class InspectorStock {
//   final int? id;
//   final int? itemId;  // Changed from inventoryId to itemId to match JSON
//   final int? quantity;
//   final int? minimumQuantity;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   InspectorStock({
//     this.id,
//     this.itemId,
//     this.quantity,
//     this.minimumQuantity,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory InspectorStock.fromJson(Map<String, dynamic> json) {
//     try {
//       print("Parsing InspectorStock from JSON: ${json.keys}");
//       return InspectorStock(
//         id: _parseId(json['id']),
//         itemId: _parseId(json['item_id']),  // Changed to match JSON
//         quantity: _parseId(json['quantity']),
//         minimumQuantity: _parseId(json['minimum_quantity']),
//         createdAt: json['created_at'] != null ? _parseDateTime(json['created_at']) : null,
//         updatedAt: json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
//       );
//     } catch (e) {
//       print("Error in InspectorStock.fromJson: $e");
//       return InspectorStock.empty();
//     }
//   }
//
//   // Factory constructor for creating an empty stock object
//   factory InspectorStock.empty() {
//     return InspectorStock(
//       id: 0,
//       itemId: 0,
//       quantity: 0,
//       minimumQuantity: 0,
//       createdAt: null,
//       updatedAt: null,
//     );
//   }
// }
//
// // Complete InspectorSpareParts class
// class InspectorSpareParts {
//   final int id;
//   final String name;
//   final String description;
//   final String unit;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int type;
//   final int status;
//   final DateTime? calibrationTime;
//   final DateTime? lastCalibrationDate;
//   final String condition;
//   final String inventoryImage;
//   final int? brandId;
//   final String sku;
//   final double liftingPrice;
//   final String? remarks;
//   final InspectorStock? stock;
//   final List<dynamic>? calibrationHistory;
//   final List<dynamic>? teams;
//
//   InspectorSpareParts({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.unit,
//     this.createdAt,
//     this.updatedAt,
//     required this.type,
//     required this.status,
//     this.calibrationTime,
//     this.lastCalibrationDate,
//     required this.condition,
//     required this.inventoryImage,
//     this.brandId,
//     required this.sku,
//     required this.liftingPrice,
//     this.remarks,
//     this.stock,
//     this.calibrationHistory,
//     this.teams,
//   });
//
//   factory InspectorSpareParts.fromJson(Map<String, dynamic> json) {
//     try {
//       print("Parsing InspectorSpareParts from JSON: ${json.keys}");
//
//       // Create a safe stock object (either from data or empty)
//       InspectorStock? stockObj;
//       if (json['stock'] != null) {
//         try {
//           stockObj = InspectorStock.fromJson(json['stock']);
//           print("Stock parsed successfully: ${stockObj.quantity}");
//         } catch (e) {
//           print("Error parsing stock: $e. Creating empty stock.");
//           stockObj = InspectorStock.empty();
//         }
//       } else {
//         print("Stock is null in JSON. Creating empty stock.");
//         stockObj = null;
//       }
//
//       // Parse optional DateTime fields safely
//       DateTime? calibrationTime;
//       if (json['calibration_time'] != null) {
//         try {
//           calibrationTime = _parseDateTime(json['calibration_time']);
//         } catch (e) {
//           print("Error parsing calibration_time: $e");
//           calibrationTime = null;
//         }
//       }
//
//       DateTime? lastCalibrationDate;
//       if (json['last_calibration_date'] != null) {
//         try {
//           lastCalibrationDate = _parseDateTime(json['last_calibration_date']);
//         } catch (e) {
//           print("Error parsing last_calibration_date: $e");
//           lastCalibrationDate = null;
//         }
//       }
//
//       // More verbose parsing to catch any issues
//       final double liftingPrice = _parseDouble(json['lifting_price']);
//       print("Parsed lifting price: $liftingPrice");
//
//       return InspectorSpareParts(
//         id: _parseId(json['id']),
//         name: json['name'] ?? '',
//         description: json['description'] ?? '',
//         unit: json['unit'] ?? '',
//         createdAt: json['created_at'] != null ? _parseDateTime(json['created_at']) : null,
//         updatedAt: json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
//         type: _parseId(json['type']),
//         status: _parseId(json['status']),
//         calibrationTime: calibrationTime,
//         lastCalibrationDate: lastCalibrationDate,
//         condition: json['condition'] ?? '',
//         inventoryImage: json['inventory_image'] ?? '',
//         brandId: json['brand_id'] != null ? _parseId(json['brand_id']) : null,
//         sku: json['sku'] ?? '',
//         liftingPrice: liftingPrice,
//         remarks: json['remarks'],
//         stock: stockObj,
//         calibrationHistory: json['calibration_history'] as List<dynamic>?,
//         teams: json['teams'] as List<dynamic>?,
//       );
//     } catch (e) {
//       print("Error in InspectorSpareParts.fromJson: $e");
//       // Return a minimal valid object with empty data to prevent null errors
//       return InspectorSpareParts(
//         id: 0,
//         name: 'Error loading data',
//         description: '',
//         unit: '',
//         createdAt: null,
//         updatedAt: null,
//         type: 0,
//         status: 0,
//         calibrationTime: null,
//         lastCalibrationDate: null,
//         condition: '',
//         inventoryImage: '',
//         brandId: null,
//         sku: '',
//         liftingPrice: 0.0,
//         stock: InspectorStock.empty(),
//         calibrationHistory: [],
//         teams: [],
//       );
//     }
//   }
// }
//
// // Helper methods for parsing JSON values
// int _parseId(dynamic value) {
//   if (value == null) return 0;
//   if (value is int) return value;
//   if (value is String) {
//     try {
//       return int.parse(value);
//     } catch (e) {
//       print("Error parsing ID from string: $e");
//       return 0;
//     }
//   }
//   return 0;
// }
//
// double _parseDouble(dynamic value) {
//   if (value == null) return 0.0;
//   if (value is double) return value;
//   if (value is int) return value.toDouble();
//   if (value is String) {
//     try {
//       return double.parse(value);
//     } catch (e) {
//       print("Error parsing double from string: $e");
//       return 0.0;
//     }
//   }
//   return 0.0;
// }
//
// DateTime _parseDateTime(dynamic value) {
//   if (value == null) return DateTime.now();
//   if (value is String) {
//     try {
//       return DateTime.parse(value);
//     } catch (e) {
//       print("Error parsing DateTime: $e");
//       return DateTime.now();
//     }
//   }
//   return DateTime.now();
// }
//
//

//   =============  //

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Core/Utils/api_service.dart';
import '../../../../../Core/Utils/colors.dart';


class InspectorStock {
  final int? id;
  final int? itemId;  // Changed from inventoryId to itemId to match JSON
  final int? quantity;
  final int? minimumQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InspectorStock({
    this.id,
    this.itemId,
    this.quantity,
    this.minimumQuantity,
    this.createdAt,
    this.updatedAt,
  });

  factory InspectorStock.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing InspectorStock from JSON: ${json.keys}");
      return InspectorStock(
        id: _parseId(json['id']),
        itemId: _parseId(json['item_id']),  // Changed to match JSON
        quantity: _parseId(json['quantity']),
        minimumQuantity: _parseId(json['minimum_quantity']),
        createdAt: json['created_at'] != null ? _parseDateTime(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
      );
    } catch (e) {
      print("Error in InspectorStock.fromJson: $e");
      return InspectorStock.empty();
    }
  }

  // Factory constructor for creating an empty stock object
  factory InspectorStock.empty() {
    return InspectorStock(
      id: 0,
      itemId: 0,
      quantity: 0,
      minimumQuantity: 0,
      createdAt: null,
      updatedAt: null,
    );
  }
}

// Complete InspectorSpareParts class
class InspectorSpareParts {
  final int id;
  final String name;
  final String description;
  final String unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int type;
  final int status;
  final DateTime? calibrationTime;
  final DateTime? lastCalibrationDate;
  final String condition;
  final String inventoryImage;
  final int? brandId;
  final String sku;
  final double liftingPrice;
  final String? remarks;
  final InspectorStock? stock;
  final List<dynamic>? calibrationHistory;
  final List<dynamic>? teams;

  InspectorSpareParts({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    this.createdAt,
    this.updatedAt,
    required this.type,
    required this.status,
    this.calibrationTime,
    this.lastCalibrationDate,
    required this.condition,
    required this.inventoryImage,
    this.brandId,
    required this.sku,
    required this.liftingPrice,
    this.remarks,
    this.stock,
    this.calibrationHistory,
    this.teams,
  });

  factory InspectorSpareParts.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing InspectorSpareParts from JSON: ${json.keys}");

      // Create a safe stock object (either from data or empty)
      InspectorStock? stockObj;
      if (json['stock'] != null) {
        try {
          stockObj = InspectorStock.fromJson(json['stock']);
          print("Stock parsed successfully: ${stockObj.quantity}");
        } catch (e) {
          print("Error parsing stock: $e. Creating empty stock.");
          stockObj = InspectorStock.empty();
        }
      } else {
        print("Stock is null in JSON. Creating empty stock.");
        stockObj = null;
      }

      // Parse optional DateTime fields safely
      DateTime? calibrationTime;
      if (json['calibration_time'] != null) {
        try {
          calibrationTime = _parseDateTime(json['calibration_time']);
        } catch (e) {
          print("Error parsing calibration_time: $e");
          calibrationTime = null;
        }
      }

      DateTime? lastCalibrationDate;
      if (json['last_calibration_date'] != null) {
        try {
          lastCalibrationDate = _parseDateTime(json['last_calibration_date']);
        } catch (e) {
          print("Error parsing last_calibration_date: $e");
          lastCalibrationDate = null;
        }
      }

      // More verbose parsing to catch any issues
      final double liftingPrice = _parseDouble(json['lifting_price']);
      print("Parsed lifting price: $liftingPrice");

      return InspectorSpareParts(
        id: _parseId(json['id']),
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        unit: json['unit'] ?? '',
        createdAt: json['created_at'] != null ? _parseDateTime(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
        type: _parseId(json['type']),
        status: _parseId(json['status']),
        calibrationTime: calibrationTime,
        lastCalibrationDate: lastCalibrationDate,
        condition: json['condition'] ?? '',
        inventoryImage: json['inventory_image'] ?? '',
        brandId: json['brand_id'] != null ? _parseId(json['brand_id']) : null,
        sku: json['sku'] ?? '',
        liftingPrice: liftingPrice,
        remarks: json['remarks'],
        stock: stockObj,
        calibrationHistory: json['calibration_history'] as List<dynamic>?,
        teams: json['teams'] as List<dynamic>?,
      );
    } catch (e) {
      print("Error in InspectorSpareParts.fromJson: $e");
      // Return a minimal valid object with empty data to prevent null errors
      return InspectorSpareParts(
        id: 0,
        name: 'Error loading data',
        description: '',
        unit: '',
        createdAt: null,
        updatedAt: null,
        type: 0,
        status: 0,
        calibrationTime: null,
        lastCalibrationDate: null,
        condition: '',
        inventoryImage: '',
        brandId: null,
        sku: '',
        liftingPrice: 0.0,
        stock: InspectorStock.empty(),
        calibrationHistory: [],
        teams: [],
      );
    }
  }
}

// Helper methods for parsing JSON values
int _parseId(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      print("Error parsing ID from string: $e");
      return 0;
    }
  }
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      print("Error parsing double from string: $e");
      return 0.0;
    }
  }
  return 0.0;
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      print("Error parsing DateTime: $e");
      return DateTime.now();
    }
  }
  return DateTime.now();
}



class InspectorSparePartsViewDetails extends StatefulWidget {
  final int itemId;

  const InspectorSparePartsViewDetails({Key? key, required this.itemId}) : super(key: key);

  @override
  _InspectorSparePartsViewDetailsState createState() => _InspectorSparePartsViewDetailsState();
}

class _InspectorSparePartsViewDetailsState extends State<InspectorSparePartsViewDetails> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic>? itemDetails;
  List<Map<String, dynamic>> calibrationData = [];


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
    testImageUrl();
  }

  void testImageUrl() async {
    final token = await getToken();
    final url = Uri.parse('https://minio.johkasou-erp.com/daiki/image');
    final response = await http.get(
      url,
      headers: {
        'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',
        'Accept': '*/*',
      },
    );
    print('Test image response status: ${response.statusCode}');
    print('Test image response headers: ${response.headers}');
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Not available';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> fetchItemDetails() async {
    final String url = '${DaikiAPI.api_key}/api/v1/inventory/${widget.itemId}';

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> history = data['data']['calibration_history'] ?? [];

          final List<Map<String, dynamic>> calibrationHistory = history.map((entry) {
            return {
              'last_calibration_date': entry['last_calibration_date'],
              'next_calibration_date': entry['calibration_time'],
              'calibrated_by': entry['user']?['name'] ?? 'Unknown',
              'status': entry['status'] == 1 ? 'Completed' : 'Pending',
              'remarks': entry['remarks'] ?? 'No remarks',
            };
          }).toList();

          setState(() {
            itemDetails = data['data'];
            calibrationData = calibrationHistory;
            isLoading = false;
            hasError = false;
          });
        } else {
          throw Exception('Invalid response: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load item details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }



  Widget buildUserAvatar(Map<String, dynamic> user) {
    if (user['photo'] != null) {
      // Try both potential URL formats
      final String photoUrl1 = Uri.encodeFull(
          'https://minio.johkasou-erp.com/daiki/image/${user['inventory_image']}'
      );
      final String photoUrl2 = Uri.encodeFull(
          'https://minio.johkasou-erp.com/daiki/image/${user['inventory_image']}'
      );

      print('Debug - Photo URL 1: $photoUrl1');
      print('Debug - Photo URL 2: $photoUrl2');

      return FutureBuilder<String?>(
        future: getToken(),
        builder: (context, tokenSnapshot) {
          if (!tokenSnapshot.hasData) {
            print('Debug - No token available');
            return CircleAvatar(child: Icon(Icons.person));
          }

          final token = tokenSnapshot.data;
          print('Debug - Token: $token');

          final headers = {'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',};
          print('Debug - Headers: $headers');

          // Try making a direct HTTP request to check the URL
          http.get(Uri.parse(photoUrl1), headers: headers).then((response) {
            print('Debug - HTTP Response status for URL1: ${response.statusCode}');
          });

          return CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              photoUrl1,  // Try with the first URL format
              headers: headers,
            ),
            onBackgroundImageError: (exception, stackTrace) {
              print('Debug - Avatar Error: $exception');
              print('Debug - Stack trace: $stackTrace');
              return null;  // Return null to show the child
            },
            child: Icon(Icons.person),  // Fallback icon
          );
        },
      );
    }
    return CircleAvatar(child: Icon(Icons.person));
  }

  Widget buildImage(String? token) {
    if (itemDetails?['inventory_image'] == null) {
      return const Icon(Icons.image, size: 200, color: Colors.grey);
    }

    final String encodedImageUrl = Uri.encodeFull('${DaikiAPI.api_key}/daiki/image/${itemDetails!['inventory_image']}');

    return Container(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: encodedImageUrl,
          fit: BoxFit.cover,
          httpHeaders: {
            'Authorization': token?.startsWith('Bearer ') ?? false ? token! : 'Bearer $token',
          },
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) {
            print('Image Error: $error');
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red, size: 40),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                color: TizaraaColors.Tizara,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),),
                )),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildBasicDetails() {
    return buildSection(
      'Basic Details',
      [
        buildDetailRow('Name', itemDetails?['name']),
        buildDetailRow('Description', itemDetails?['description']),
        buildDetailRow('Condition', itemDetails?['condition']),
        buildDetailRow('Unit', itemDetails?['unit']),
        buildDetailRow('Created At', formatDate(itemDetails?['created_at'])),
        buildDetailRow('Updated At', formatDate(itemDetails?['updated_at'])),
        buildDetailRow('Type', itemDetails!['type'] == 1 ? 'Type 1' : 'Type 2'),
        buildDetailRow('Status', itemDetails!['status'] == 1 ? 'Active' : 'Inactive'),
        buildDetailRow('Calibration Time', formatDate(itemDetails!['calibration_time'])),
        buildDetailRow('Last Calibration Date', formatDate(itemDetails!['last_calibration_date'])),
        buildDetailRow('SKU', itemDetails!['sku']),
        buildDetailRow('Lifting Price', '${itemDetails!['lifting_price']}'),
        buildDetailRow('Remarks', itemDetails!['remarks']),
        buildDetailRow('Stock Quantity', itemDetails!['stock']?['quantity']?.toString() ?? 'N/A'),
        buildDetailRow('Stock Minimum Quantity', itemDetails!['stock']?['minimum_quantity']?.toString() ?? 'N/A'),
        buildDetailRow('Stock Created At', formatDate(itemDetails!['stock']?['created_at'])),
        buildDetailRow('Stock Updated At', formatDate(itemDetails!['stock']?['updated_at'])),
      ],
    );
  }



// Build Team Details
  Widget buildTeamDetails() {
    if (itemDetails?['teams'] == null || (itemDetails!['teams'] as List).isEmpty) {
      return Container();
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: TizaraaColors.Tizara,
            width: MediaQuery.of(context).size.width/1.2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Team Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),),
              )),
          const SizedBox(height: 8),
          ...List<Widget>.from(
            (itemDetails!['teams'] as List).map((team) {
              final String teamId = team?['id']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(team?['name'] ?? 'Unknown Team'),
                  subtitle: Text('Stock: ${team?['pivot']?['stock'] ?? 'N/A'}'),
                  children: [

                    // Projects Section
                    if (team?['projects'] != null && (team!['projects'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Projects:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (team!['projects'] as List).map((project) {
                                final safeProject = project ?? {}; // Prevent null errors
                                return ListTile(
                                  title: Text(safeProject['project_name'] ?? 'Unknown Project'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Location: ${safeProject['location'] ?? 'N/A'}'),
                                      Text('Status: ${safeProject['project_status'] ?? 'N/A'}'),
                                      Text('Capacity: ${safeProject['capacity'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                    // Assign Project History
                    if (team?['assign_project_history'] != null && (team!['assign_project_history'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assign Project History:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ...List<Widget>.from(
                              (team!['assign_project_history'] as List).map((history) {
                                final project = history?['project'] ?? {}; // Prevent null errors
                                final assignedBy = history?['assigned_by'] ?? {}; // Prevent null errors
                                return ListTile(
                                  title: Text('Project: ${project['project_name'] ?? 'Unknown'}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Assigned By: ${assignedBy['name'] ?? 'Unknown'}'),
                                      Text('Assigned At: ${history?['assigned_at'] ?? 'N/A'}'),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget buildInspectorHistory() {
    if (itemDetails?['assign_inspector_history'] == null ||
        (itemDetails!['assign_inspector_history'] as List).isEmpty) {
      return Container();
    }

    return buildSection(
      'Inspector Assignment History',
      [
        ...List<Widget>.from(
          (itemDetails!['assign_inspector_history'] as List).map((history) {
            final inspector = history['inspector'] ?? {}; // Prevent null errors

            return Card(
              child: ListTile(
                title: Text('Inspector: ${inspector['name'] ?? 'Unknown Inspector'}'),
                subtitle: Text('Date: ${formatDate(history['created_at'] ?? '')}'),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildProjects() {
    if (itemDetails?['projects'] == null ||
        (itemDetails!['projects'] as List).isEmpty) {
      return Container();
    }

    return buildSection(
      'Related Projects',
      [
        ...List<Widget>.from(
          (itemDetails!['projects'] as List).map((project) {
            final safeProject = project ?? {}; // Prevent null errors

            return Card(
              child: ListTile(
                title: Text(safeProject['name'] ?? 'Unknown Project'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${safeProject['status'] ?? 'N/A'}'),
                    Text('Created: ${formatDate(safeProject['created_at'] ?? '')}'),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }


  Widget buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'Not available'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TizaraaColors.Tizara,
        title: Text(itemDetails != null ? itemDetails!['name'] : 'Loading...',style: TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<String?>(
        future: getToken(),
        builder: (context, tokenSnapshot) {
          if (tokenSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text('Failed to load item details'),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        hasError = false;
                        errorMessage = '';
                      });
                      fetchItemDetails();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: fetchItemDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildImage(tokenSnapshot.data),
                  const SizedBox(height: 16),
                  buildBasicDetails(),
                  buildTeamDetails(),
                  buildInspectorHistory(),
                  buildProjects(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
