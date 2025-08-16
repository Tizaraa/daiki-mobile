class FAQ {
  final int? id;
  final String title;
  final String description;
  final int? userId;

  FAQ({
    this.id,
    required this.title,
    required this.description,
    this.userId,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'user_id': userId ?? 43,
    };
  }
}