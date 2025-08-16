

// Option Model
class Option {
  final int id;
  final int questionId;
  final String text;
  final String value;
  final List<Option> options;
  final String? type; // Nullable to handle missing values
  final int? required; // Nullable to handle missing values

  Option({
    required this.id,
    required this.questionId,
    required this.text,
    required this.value,
    this.type,
    this.required,
    required this.options,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 0, // Provide default value if null
      questionId: json['question_id'] ?? 0, // Provide default value if null
      text: json['text']?.toString() ?? '', // Convert to String and provide default
      value: json['value']?.toString() ?? '', // Convert to String and provide default
      type: (json['type'] as String?)?.isEmpty == true || json['type'] == null ? 'text' : json['type'] as String,
      required: json['required'] == null ? 0 : (json['required'] as int),
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => Option.fromJson(option as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class Question {
  final int id;
  final int categoryId;
  final String text;
  final String type;
  final String? unit;
  int required;
  final List<Option> options;
  final int? min;
  final int? max;

  Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.type,
    this.unit,
    this.required = 0,
    required this.options,
    this.min,
    this.max,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Handle options list
    List<Option> optionsList = [];
    if (json['options'] != null && json['options'] is List) {
      optionsList = (json['options'] as List)
          .map((option) => Option.fromJson(option as Map<String, dynamic>))
          .toList();
    }

    return Question(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      text: json['text']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text', // Default type if null
      unit: json['unit']?.toString(), // Keep nullable
      required: json['required'] as int? ?? 0,
      options: optionsList,
      min: json['min'] != null ? int.tryParse(json['min'].toString()) : null,
      max: json['max'] != null ? int.tryParse(json['max'].toString()) : null,
    );
  }
}

class Category {
  final int id;
  final String name;
  final List<Question> questions;

  Category({
    required this.id,
    required this.name,
    required this.questions,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle questions list
    List<Question> questionsList = [];
    if (json['questions'] != null && json['questions'] is List) {
      questionsList = (json['questions'] as List)
          .map((question) => Question.fromJson(question as Map<String, dynamic>))
          .toList();
    }

    return Category(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      questions: questionsList,
    );
  }
}


class QuestionOption {
  final String value;
  final String text;

  QuestionOption({required this.value, required this.text});
}