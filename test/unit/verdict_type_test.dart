// test/unit/verdict_type_test.dart
//
// Unit tests for the VerdictType enum.
// Adjust the import path to match your actual package name.

import 'package:flutter_test/flutter_test.dart';
// import 'package:someday/domain/entities/verdict_type.dart';

// ---------------------------------------------------------------------------
// Inline definition — remove once the real import above is uncommented.
// ---------------------------------------------------------------------------
enum VerdictType {
  secondChance,
  sunsetConfirmed,
  needsMoreContext,
  notYetAnalysed;

  /// Human-readable label shown in the UI.
  String get label {
    switch (this) {
      case VerdictType.secondChance:
        return 'Second Chance';
      case VerdictType.sunsetConfirmed:
        return 'Sunset Confirmed';
      case VerdictType.needsMoreContext:
        return 'Needs More Context';
      case VerdictType.notYetAnalysed:
        return 'Not Yet Analysed';
    }
  }

  /// Whether the verdict was produced by the AI engine.
  bool get isAnalysed => this != VerdictType.notYetAnalysed;

  /// Maps the snake_case string returned by the Edge Function to the enum.
  static VerdictType fromApiString(String raw) {
    switch (raw) {
      case 'second_chance':
        return VerdictType.secondChance;
      case 'sunset_confirmed':
        return VerdictType.sunsetConfirmed;
      case 'needs_more_context':
        return VerdictType.needsMoreContext;
      default:
        throw ArgumentError('Unknown verdict string: $raw');
    }
  }
}
// ---------------------------------------------------------------------------

void main() {
  group('VerdictType enum', () {
    group('values coverage', () {
      test('has exactly 4 values', () {
        expect(VerdictType.values.length, 4);
      });

      test('all expected variants exist', () {
        expect(VerdictType.values, containsAll([
          VerdictType.secondChance,
          VerdictType.sunsetConfirmed,
          VerdictType.needsMoreContext,
          VerdictType.notYetAnalysed,
        ]));
      });
    });

    group('label getter', () {
      test('secondChance returns "Second Chance"', () {
        expect(VerdictType.secondChance.label, 'Second Chance');
      });

      test('sunsetConfirmed returns "Sunset Confirmed"', () {
        expect(VerdictType.sunsetConfirmed.label, 'Sunset Confirmed');
      });

      test('needsMoreContext returns "Needs More Context"', () {
        expect(VerdictType.needsMoreContext.label, 'Needs More Context');
      });

      test('notYetAnalysed returns "Not Yet Analysed"', () {
        expect(VerdictType.notYetAnalysed.label, 'Not Yet Analysed');
      });
    });

    group('isAnalysed getter', () {
      test('secondChance is analysed', () {
        expect(VerdictType.secondChance.isAnalysed, isTrue);
      });

      test('sunsetConfirmed is analysed', () {
        expect(VerdictType.sunsetConfirmed.isAnalysed, isTrue);
      });

      test('needsMoreContext is analysed', () {
        expect(VerdictType.needsMoreContext.isAnalysed, isTrue);
      });

      test('notYetAnalysed is NOT analysed', () {
        expect(VerdictType.notYetAnalysed.isAnalysed, isFalse);
      });
    });

    group('fromApiString()', () {
      test('maps "second_chance" → secondChance', () {
        expect(
          VerdictType.fromApiString('second_chance'),
          VerdictType.secondChance,
        );
      });

      test('maps "sunset_confirmed" → sunsetConfirmed', () {
        expect(
          VerdictType.fromApiString('sunset_confirmed'),
          VerdictType.sunsetConfirmed,
        );
      });

      test('maps "needs_more_context" → needsMoreContext', () {
        expect(
          VerdictType.fromApiString('needs_more_context'),
          VerdictType.needsMoreContext,
        );
      });

      test('throws ArgumentError for unknown string', () {
        expect(
          () => VerdictType.fromApiString('totally_unknown'),
          throwsArgumentError,
        );
      });

      test('throws for empty string', () {
        expect(
          () => VerdictType.fromApiString(''),
          throwsArgumentError,
        );
      });
    });

    group('enum identity / equality', () {
      test('same variant is identical', () {
        const a = VerdictType.secondChance;
        const b = VerdictType.secondChance;
        expect(identical(a, b), isTrue);
      });

      test('different variants are not equal', () {
        expect(VerdictType.secondChance, isNot(VerdictType.sunsetConfirmed));
      });
    });
  });
}
