// // Team Model
// class Team {
//   final int id;
//   final String name;
//   int stock;
//
//   Team({
//     required this.id,
//     required this.name,
//     this.stock = 0,
//   });
//
//   // Add fromJson factory constructor
//   factory Team.fromJson(Map<String, dynamic> json) {
//     return Team(
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


class Team {
  final int id;
  final String name;
  final int status;
  int stock;
  DateTime? createdAt;
  DateTime? updatedAt;

  Team({
    required this.id,
    required this.name,
    required this.status,
    required this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json, {int? stockFromPivot}) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      stock: stockFromPivot ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}



