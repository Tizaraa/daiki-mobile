

class InspectorTeam {
  final int id;
  final String name;
  final int status;
  int stock;
  DateTime? createdAt;
  DateTime? updatedAt;

  InspectorTeam({
    required this.id,
    required this.name,
    required this.status,
    required this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory InspectorTeam.fromJson(Map<String, dynamic> json, {int? stockFromPivot}) {
    return InspectorTeam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      stock: stockFromPivot ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

// Update InventoryItem model with null safety
class InspectorInventoryItem {
  final int id;
  final String name;
  final String description;
  final String unit;
  final String condition;
  final String sku;
  final int type;
  final int status;
  final String calibrationTime;
  final String lastCalibrationDate;
  final InspectorStock stock;
  final List<InspectorTeam> teams;
  final String projectName; // ✅ Add projectName field

  InspectorInventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.condition,
    required this.sku,
    required this.type,
    required this.status,
    required this.calibrationTime,
    required this.lastCalibrationDate,
    required this.stock,
    required this.teams,
    required this.projectName, // ✅ Include in constructor
  });

  factory InspectorInventoryItem.fromJson(Map<String, dynamic> json) {
    return InspectorInventoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      unit: json['unit'] ?? '',
      condition: json['condition'] ?? '',
      sku: json['sku'] ?? '',
      type: json['type'] ?? 0,
      status: json['status'] ?? 0,
      calibrationTime: json['calibration_time'] ?? '',
      lastCalibrationDate: json['last_calibration_date'] ?? '',
      stock: InspectorStock.fromJson(json['stock'] ?? {}),
      teams: (json['teams'] as List?)
          ?.map((team) => InspectorTeam.fromJson(
        team,
        stockFromPivot: team['pivot']?['stock'],
      ))
          .toList() ??
          [],
      projectName: json['project_name'] ?? 'Unknown Project', // ✅ Handle missing value
    );
  }
}




class InspectorStock {
  final int quantity;
  final int minimumQuantity;

  InspectorStock({
    required this.quantity,
    required this.minimumQuantity,
  });

  factory InspectorStock.fromJson(Map<String, dynamic> json) {
    return InspectorStock(
      quantity: json['quantity'] ?? 0,
      minimumQuantity: json['minimum_quantity'] ?? 0,
    );
  }
}



