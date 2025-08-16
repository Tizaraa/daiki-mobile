// class InspectorSpareParts {
//   final int id;
//   final String name;
//   final String description;
//   final String unit;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final int type;
//   final int status;
//   final DateTime calibrationTime;
//   final DateTime lastCalibrationDate;
//   final String condition;
//   final String inventoryImage;
//   final int brandId;
//   final String sku;
//   final double liftingPrice;
//   final String? remarks;
//   final InspectorStock stock;
//
//   InspectorSpareParts({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.unit,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.type,
//     required this.status,
//     required this.calibrationTime,
//     required this.lastCalibrationDate,
//     required this.condition,
//     required this.inventoryImage,
//     required this.brandId,
//     required this.sku,
//     required this.liftingPrice,
//     this.remarks,
//     required this.stock,
//   });
//
//   factory InspectorSpareParts.fromJson(Map<String, dynamic> json) {
//     return InspectorSpareParts(
//       id: _parseId(json['id']),
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       unit: json['unit'] ?? '',
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//       type: _parseId(json['type']),
//       status: _parseId(json['status']),
//       calibrationTime: _parseDateTime(json['calibration_time']),
//       lastCalibrationDate: _parseDateTime(json['last_calibration_date']),
//       condition: json['condition'] ?? '',
//       inventoryImage: json['inventory_image'] ?? '',
//       brandId: _parseId(json['brand_id']),
//       sku: json['sku'] ?? '',
//       liftingPrice: json['lifting_price'].toDouble(),
//       remarks: json['remarks'],
//       stock: InspectorStock.fromJson(json['stock']),
//     );
//   }
//
//   static int _parseId(dynamic id) {
//     try {
//       if (id is int) return id;
//       if (id is String) return int.parse(id);
//       return 0;
//     } catch (e) {
//       print('Error parsing ID: $e');
//       return 0;
//     }
//   }
//
//   // Helper method to safely parse DateTime from a string or null
//   static DateTime _parseDateTime(dynamic value) {
//     try {
//       if (value == null || value == '') {
//         return DateTime(1900, 1, 1); // Default date when missing
//       }
//       if (value is String) {
//         return DateTime.parse(value);
//       }
//       if (value is DateTime) {
//         return value;
//       }
//       return DateTime(1900, 1, 1); // Default date if parsing fails
//     } catch (e) {
//       print('Error parsing DateTime: $e');
//       return DateTime(1900, 1, 1); // Default date if parsing fails
//     }
//   }
// }
//
// class InspectorStock {
//   final int id;
//   final int itemId;
//   final int quantity;
//   final int minimumQuantity;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   InspectorStock({
//     required this.id,
//     required this.itemId,
//     required this.quantity,
//     required this.minimumQuantity,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory InspectorStock.fromJson(Map<String, dynamic> json) {
//     return InspectorStock(
//       id: _parseInteger(json['id']),
//       itemId: _parseInteger(json['item_id']),
//       quantity: _parseInteger(json['quantity']),
//       minimumQuantity: _parseInteger(json['minimum_quantity']),
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//     );
//   }
//
//   static int _parseInteger(dynamic value) {
//     try {
//       if (value == null) return 0;
//       if (value is int) return value;
//       if (value is String) return int.parse(value);
//       return 0;
//     } catch (e) {
//       print('Error parsing integer: $e');
//       return 0;
//     }
//   }
// }
// //   ==============  //
//
//
// // Team Model
// class InspectorTeam {
//   final int id;
//   final String name;
//   int stock;
//
//   InspectorTeam({
//     required this.id,
//     required this.name,
//     this.stock = 0,
//   });
//
//   // Add fromJson factory constructor
//   factory InspectorTeam.fromJson(Map<String, dynamic> json) {
//     return InspectorTeam(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       stock: json['stock'] as int? ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'stock': stock,
//     };
//   }
// }


import 'package:flutter/cupertino.dart';

class InspectorStock {
  final int id;
  final int itemId;
  final int quantity;
  final int minimumQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectorStock({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.minimumQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InspectorStock.fromJson(Map<String, dynamic> json) {
    return InspectorStock(
      id: _parseInteger(json['id']),
      itemId: _parseInteger(json['item_id']),
      quantity: _parseInteger(json['quantity']),
      minimumQuantity: _parseInteger(json['minimum_quantity']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static int _parseInteger(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.parse(value);
      return 0;
    } catch (e) {
      print('Error parsing integer: $e');
      return 0;
    }
  }
}
//   ==============  //



class InspectorTeam {
  final int id;
  final String name;
  final int stock;

  InspectorTeam({
    required this.id,
    required this.name,
    required this.stock,
  });

  factory InspectorTeam.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing InspectorTeam: $json');
    final pivot = json['pivot'] as Map<String, dynamic>? ?? {};
    return InspectorTeam(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      stock: pivot['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
    };
  }
}

  //============//