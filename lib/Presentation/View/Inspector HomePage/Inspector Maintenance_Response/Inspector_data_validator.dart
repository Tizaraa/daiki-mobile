import 'Inspector_quiz_model.dart';


class DataValidator {
  static void validateAndLogQuestions(
      List<Category> categories,
      String source, {
        required int maintenanceScheduleId,
        required int johkasouId,
      }) {
    print('Validating questions from $source for maintenanceScheduleId: $maintenanceScheduleId, johkasouId: $johkasouId');
    int totalQuestions = 0;
    int missingRequired = 0;
    int emptyOptions = 0;
    int invalidType = 0;

    for (var category in categories) {
      print('Category: ${category.name} (ID: ${category.id})');
      for (var question in category.questions) {
        totalQuestions++;
        // Log question details
        print('  Question: ${question.text} (ID: ${question.id}, Type: ${question.type}, Required: ${question.required}, Options: ${question.options.length})');

        // Check for missing required field
        if (question.required == null) {
          missingRequired++;
          print('    Warning: Missing required field for question ${question.id}. Expected 0 or 1.');
        }

        // Check for empty options
        if (question.options.isEmpty && !['text', 'number', 'String'].contains(question.type)) {
          emptyOptions++;
          print('    Warning: Empty options for non-text/number question ${question.id}');
        }

        // Validate type
        if (question.type == null || question.type!.isEmpty) {
          invalidType++;
          print('    Warning: Invalid type for question ${question.id}. Expected non-null/non-empty type.');
        }
      }
    }

    print('Validation Summary ($source):');
    print('  Total Questions: $totalQuestions');
    print('  Questions with missing required field: $missingRequired');
    print('  Questions with empty options (non-text/number): $emptyOptions');
    print('  Questions with invalid type: $invalidType');
  }
}