// test/unit/idea_entity_test.dart
//
// Unit tests for the Idea domain entity, focusing on validation logic.
// Adjust import to match your actual package name.

import 'package:flutter_test/flutter_test.dart';
// import 'package:someday/domain/entities/idea.dart';

// ---------------------------------------------------------------------------
// Inline entity — remove once real import is in place.
// ---------------------------------------------------------------------------

/// Represents the result of validating an Idea's fields.
class IdeaValidationResult {
  final bool isValid;
  final Map<String, String> errors; // field → error message

  const IdeaValidationResult({
    required this.isValid,
    required this.errors,
  });
}

class Idea {
  static const int maxTitleLength = 120;
  static const int maxDescriptionLength = 2000;
  static const int maxEmotionalNoteLength = 500;

  final String? id;
  final String title;
  final String description;
  final String? timePeriod;        // e.g. "2019-2020"
  final String? reasonForStopping;
  final String? emotionalNote;
  final DateTime createdAt;

  const Idea({
    this.id,
    required this.title,
    required this.description,
    this.timePeriod,
    this.reasonForStopping,
    this.emotionalNote,
    required this.createdAt,
  });

  /// Returns validation errors. Empty map = valid.
  IdeaValidationResult validate() {
    final errors = <String, String>{};

    if (title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.length > maxTitleLength) {
      errors['title'] = 'Title must be $maxTitleLength characters or fewer';
    }

    if (description.trim().isEmpty) {
      errors['description'] = 'Description is required';
    } else if (description.length > maxDescriptionLength) {
      errors['description'] =
          'Description must be $maxDescriptionLength characters or fewer';
    }

    if (emotionalNote != null && emotionalNote!.length > maxEmotionalNoteLength) {
      errors['emotionalNote'] =
          'Emotional note must be $maxEmotionalNoteLength characters or fewer';
    }

    return IdeaValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  Idea copyWith({
    String? id,
    String? title,
    String? description,
    String? timePeriod,
    String? reasonForStopping,
    String? emotionalNote,
    DateTime? createdAt,
  }) {
    return Idea(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timePeriod: timePeriod ?? this.timePeriod,
      reasonForStopping: reasonForStopping ?? this.reasonForStopping,
      emotionalNote: emotionalNote ?? this.emotionalNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
// ---------------------------------------------------------------------------

// Helpers
Idea _validIdea({
  String title = 'My startup idea',
  String description = 'An app that does something useful.',
  String? emotionalNote,
}) {
  return Idea(
    title: title,
    description: description,
    emotionalNote: emotionalNote,
    createdAt: DateTime(2024, 1, 15),
  );
}

void main() {
  group('Idea entity — validation', () {
    group('title validation', () {
      test('valid title passes', () {
        final result = _validIdea(title: 'Valid title').validate();
        expect(result.isValid, isTrue);
        expect(result.errors.containsKey('title'), isFalse);
      });

      test('empty title fails', () {
        final result = _validIdea(title: '').validate();
        expect(result.isValid, isFalse);
        expect(result.errors['title'], isNotNull);
        expect(result.errors['title'], contains('required'));
      });

      test('whitespace-only title fails', () {
        final result = _validIdea(title: '   ').validate();
        expect(result.isValid, isFalse);
        expect(result.errors['title'], contains('required'));
      });

      test('title exactly at max length (${Idea.maxTitleLength}) passes', () {
        final title = 'A' * Idea.maxTitleLength;
        final result = _validIdea(title: title).validate();
        expect(result.errors.containsKey('title'), isFalse);
      });

      test('title one character over max length fails', () {
        final title = 'A' * (Idea.maxTitleLength + 1);
        final result = _validIdea(title: title).validate();
        expect(result.isValid, isFalse);
        expect(result.errors['title'], contains(Idea.maxTitleLength.toString()));
      });

      test('title 200 chars over limit fails', () {
        final title = 'B' * (Idea.maxTitleLength + 200);
        final result = _validIdea(title: title).validate();
        expect(result.isValid, isFalse);
      });

      test('single-character title is valid', () {
        final result = _validIdea(title: 'X').validate();
        expect(result.errors.containsKey('title'), isFalse);
      });
    });

    group('description validation', () {
      test('valid description passes', () {
        final result = _validIdea(
          description: 'A thoughtful description.',
        ).validate();
        expect(result.errors.containsKey('description'), isFalse);
      });

      test('empty description fails', () {
        final result = _validIdea(description: '').validate();
        expect(result.isValid, isFalse);
        expect(result.errors['description'], contains('required'));
      });

      test('whitespace-only description fails', () {
        final result = _validIdea(description: '\t\n  ').validate();
        expect(result.isValid, isFalse);
        expect(result.errors['description'], contains('required'));
      });

      test('description exactly at max length passes', () {
        final desc = 'D' * Idea.maxDescriptionLength;
        final result = _validIdea(description: desc).validate();
        expect(result.errors.containsKey('description'), isFalse);
      });

      test('description one char over max length fails', () {
        final desc = 'D' * (Idea.maxDescriptionLength + 1);
        final result = _validIdea(description: desc).validate();
        expect(result.isValid, isFalse);
        expect(
          result.errors['description'],
          contains(Idea.maxDescriptionLength.toString()),
        );
      });
    });

    group('emotionalNote validation', () {
      test('null emotional note is valid', () {
        final result = _validIdea(emotionalNote: null).validate();
        expect(result.errors.containsKey('emotionalNote'), isFalse);
      });

      test('emotional note within limit is valid', () {
        final result = _validIdea(emotionalNote: 'Felt hopeful.').validate();
        expect(result.errors.containsKey('emotionalNote'), isFalse);
      });

      test('emotional note exactly at max length passes', () {
        final note = 'E' * Idea.maxEmotionalNoteLength;
        final result = _validIdea(emotionalNote: note).validate();
        expect(result.errors.containsKey('emotionalNote'), isFalse);
      });

      test('emotional note over max length fails', () {
        final note = 'E' * (Idea.maxEmotionalNoteLength + 1);
        final result = _validIdea(emotionalNote: note).validate();
        expect(result.isValid, isFalse);
        expect(result.errors['emotionalNote'], isNotNull);
      });
    });

    group('multiple field failures', () {
      test('both title and description empty produces two errors', () {
        final idea = Idea(
          title: '',
          description: '',
          createdAt: DateTime(2024),
        );
        final result = idea.validate();
        expect(result.isValid, isFalse);
        expect(result.errors.keys, containsAll(['title', 'description']));
        expect(result.errors.length, 2);
      });

      test('all three fields invalid produces three errors', () {
        final idea = Idea(
          title: '',
          description: '',
          emotionalNote: 'E' * (Idea.maxEmotionalNoteLength + 1),
          createdAt: DateTime(2024),
        );
        final result = idea.validate();
        expect(result.errors.length, 3);
      });
    });

    group('copyWith', () {
      test('copyWith title produces new instance with updated title', () {
        final original = _validIdea(title: 'Old title');
        final updated = original.copyWith(title: 'New title');
        expect(updated.title, 'New title');
        expect(updated.description, original.description);
      });

      test('copyWith does not mutate original', () {
        final original = _validIdea(title: 'Old title');
        original.copyWith(title: 'New title');
        expect(original.title, 'Old title');
      });
    });

    group('metadata', () {
      test('createdAt is stored correctly', () {
        final date = DateTime(2023, 6, 15);
        final idea = Idea(
          title: 'Test',
          description: 'Test desc',
          createdAt: date,
        );
        expect(idea.createdAt, date);
      });

      test('id defaults to null for new ideas', () {
        final idea = _validIdea();
        expect(idea.id, isNull);
      });
    });
  });
}
