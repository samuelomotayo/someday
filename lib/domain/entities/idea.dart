import 'package:someday/domain/entities/verdict_type.dart';

class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.timePeriod,
    this.reasonForStopping,
    this.emotionalNote,
    this.verdict = VerdictType.notYetAnalysed,
    this.aiOptIn = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? timePeriod;
  final String? reasonForStopping;
  final String? emotionalNote;
  final VerdictType verdict;
  final bool aiOptIn;

  static const int titleMaxLength = 120;
  static const int descriptionMaxLength = 2000;
  static const int emotionalNoteMaxLength = 500;

  List<String> validate() {
    final errors = <String>[];
    if (title.trim().isEmpty) errors.add('Title is required.');
    if (title.length > titleMaxLength) errors.add('Title must be $titleMaxLength characters or fewer.');
    if (description.trim().isEmpty) errors.add('Description is required.');
    if (description.length > descriptionMaxLength) {
      errors.add('Description must be $descriptionMaxLength characters or fewer.');
    }
    if (emotionalNote != null && emotionalNote!.length > emotionalNoteMaxLength) {
      errors.add('Emotional note must be $emotionalNoteMaxLength characters or fewer.');
    }
    return errors;
  }

  Idea copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? timePeriod,
    String? reasonForStopping,
    String? emotionalNote,
    VerdictType? verdict,
    bool? aiOptIn,
  }) {
    return Idea(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      timePeriod: timePeriod ?? this.timePeriod,
      reasonForStopping: reasonForStopping ?? this.reasonForStopping,
      emotionalNote: emotionalNote ?? this.emotionalNote,
      verdict: verdict ?? this.verdict,
      aiOptIn: aiOptIn ?? this.aiOptIn,
    );
  }
}
