// test/unit/analysis_state_test.dart
//
// Unit tests for the AnalysisState sealed class and all sub-states.
// Adjust the import path to match your actual package name.

import 'package:flutter_test/flutter_test.dart';
// import 'package:someday/domain/state/analysis_state.dart';

// ---------------------------------------------------------------------------
// Inline sealed class definitions — remove once real imports are in place.
// ---------------------------------------------------------------------------
sealed class AnalysisState {
  const AnalysisState();

  /// Convenience: true only for the loading state.
  bool get isLoading => this is AnalysisLoading;

  /// Convenience: true when a final verdict is available.
  bool get hasVerdict =>
      this is SecondChanceDetected ||
      this is SunsetConfirmed ||
      this is NeedsMoreContext;

  /// Returns the error message when in error state, null otherwise.
  String? get errorMessage =>
      this is AnalysisError ? (this as AnalysisError).message : null;
}

final class AnalysisIdle extends AnalysisState {
  const AnalysisIdle();

  @override
  bool operator ==(Object other) => other is AnalysisIdle;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AnalysisLoading extends AnalysisState {
  const AnalysisLoading();

  @override
  bool operator ==(Object other) => other is AnalysisLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class SecondChanceDetected extends AnalysisState {
  final List<String> signals;
  final List<String> nextSteps;
  final double confidence;

  const SecondChanceDetected({
    required this.signals,
    required this.nextSteps,
    this.confidence = 1.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecondChanceDetected &&
          signals.toString() == other.signals.toString() &&
          nextSteps.toString() == other.nextSteps.toString() &&
          confidence == other.confidence;

  @override
  int get hashCode => Object.hash(signals, nextSteps, confidence);
}

final class SunsetConfirmed extends AnalysisState {
  final List<String> reasons;
  final double confidence;

  const SunsetConfirmed({
    required this.reasons,
    this.confidence = 1.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SunsetConfirmed &&
          reasons.toString() == other.reasons.toString() &&
          confidence == other.confidence;

  @override
  int get hashCode => Object.hash(reasons, confidence);
}

final class NeedsMoreContext extends AnalysisState {
  final List<String> questions;
  final double confidence;

  const NeedsMoreContext({
    required this.questions,
    this.confidence = 1.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeedsMoreContext &&
          questions.toString() == other.questions.toString() &&
          confidence == other.confidence;

  @override
  int get hashCode => Object.hash(questions, confidence);
}

final class AnalysisError extends AnalysisState {
  final String message;
  final Object? cause;

  const AnalysisError(this.message, {this.cause});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisError && message == other.message;

  @override
  int get hashCode => message.hashCode;
}
// ---------------------------------------------------------------------------

void main() {
  group('AnalysisState sealed class', () {
    // ── AnalysisIdle ─────────────────────────────────────────────────────────
    group('AnalysisIdle', () {
      test('is an AnalysisState', () {
        expect(const AnalysisIdle(), isA<AnalysisState>());
      });

      test('isLoading is false', () {
        expect(const AnalysisIdle().isLoading, isFalse);
      });

      test('hasVerdict is false', () {
        expect(const AnalysisIdle().hasVerdict, isFalse);
      });

      test('errorMessage is null', () {
        expect(const AnalysisIdle().errorMessage, isNull);
      });

      test('two AnalysisIdle instances are equal', () {
        expect(const AnalysisIdle(), equals(const AnalysisIdle()));
      });

      test('AnalysisIdle is not equal to AnalysisLoading', () {
        expect(const AnalysisIdle(), isNot(equals(const AnalysisLoading())));
      });
    });

    // ── AnalysisLoading ───────────────────────────────────────────────────────
    group('AnalysisLoading', () {
      test('is an AnalysisState', () {
        expect(const AnalysisLoading(), isA<AnalysisState>());
      });

      test('isLoading is true', () {
        expect(const AnalysisLoading().isLoading, isTrue);
      });

      test('hasVerdict is false', () {
        expect(const AnalysisLoading().hasVerdict, isFalse);
      });

      test('errorMessage is null', () {
        expect(const AnalysisLoading().errorMessage, isNull);
      });

      test('two AnalysisLoading instances are equal', () {
        expect(const AnalysisLoading(), equals(const AnalysisLoading()));
      });
    });

    // ── SecondChanceDetected ──────────────────────────────────────────────────
    group('SecondChanceDetected', () {
      const state = SecondChanceDetected(
        signals: ['Market timing improved', 'New tech unlocks this'],
        nextSteps: ['Run a survey', 'Build an MVP'],
        confidence: 0.85,
      );

      test('is an AnalysisState', () {
        expect(state, isA<AnalysisState>());
      });

      test('isLoading is false', () {
        expect(state.isLoading, isFalse);
      });

      test('hasVerdict is true', () {
        expect(state.hasVerdict, isTrue);
      });

      test('exposes signals list', () {
        expect(state.signals, hasLength(2));
        expect(state.signals.first, 'Market timing improved');
      });

      test('exposes nextSteps list', () {
        expect(state.nextSteps, hasLength(2));
        expect(state.nextSteps.last, 'Build an MVP');
      });

      test('exposes confidence', () {
        expect(state.confidence, closeTo(0.85, 0.001));
      });

      test('equality holds for identical data', () {
        const same = SecondChanceDetected(
          signals: ['Market timing improved', 'New tech unlocks this'],
          nextSteps: ['Run a survey', 'Build an MVP'],
          confidence: 0.85,
        );
        expect(state, equals(same));
      });

      test('equality fails for different signals', () {
        const different = SecondChanceDetected(
          signals: ['Different signal'],
          nextSteps: ['Run a survey', 'Build an MVP'],
          confidence: 0.85,
        );
        expect(state, isNot(equals(different)));
      });

      test('default confidence is 1.0', () {
        const s = SecondChanceDetected(signals: [], nextSteps: []);
        expect(s.confidence, 1.0);
      });
    });

    // ── SunsetConfirmed ───────────────────────────────────────────────────────
    group('SunsetConfirmed', () {
      const state = SunsetConfirmed(
        reasons: ['Market saturated', 'Core assumption disproved'],
        confidence: 0.92,
      );

      test('is an AnalysisState', () {
        expect(state, isA<AnalysisState>());
      });

      test('hasVerdict is true', () {
        expect(state.hasVerdict, isTrue);
      });

      test('isLoading is false', () {
        expect(state.isLoading, isFalse);
      });

      test('exposes reasons list', () {
        expect(state.reasons, hasLength(2));
      });

      test('exposes confidence', () {
        expect(state.confidence, closeTo(0.92, 0.001));
      });

      test('equality holds for identical data', () {
        const same = SunsetConfirmed(
          reasons: ['Market saturated', 'Core assumption disproved'],
          confidence: 0.92,
        );
        expect(state, equals(same));
      });

      test('equality fails when confidence differs', () {
        const different = SunsetConfirmed(
          reasons: ['Market saturated', 'Core assumption disproved'],
          confidence: 0.50,
        );
        expect(state, isNot(equals(different)));
      });
    });

    // ── NeedsMoreContext ──────────────────────────────────────────────────────
    group('NeedsMoreContext', () {
      const state = NeedsMoreContext(
        questions: ['Who was your target user?', 'Why did you stop?'],
        confidence: 0.40,
      );

      test('is an AnalysisState', () {
        expect(state, isA<AnalysisState>());
      });

      test('hasVerdict is true', () {
        expect(state.hasVerdict, isTrue);
      });

      test('isLoading is false', () {
        expect(state.isLoading, isFalse);
      });

      test('exposes questions list', () {
        expect(state.questions, hasLength(2));
        expect(state.questions.first, 'Who was your target user?');
      });

      test('exposes confidence', () {
        expect(state.confidence, closeTo(0.40, 0.001));
      });

      test('equality holds for identical data', () {
        const same = NeedsMoreContext(
          questions: ['Who was your target user?', 'Why did you stop?'],
          confidence: 0.40,
        );
        expect(state, equals(same));
      });
    });

    // ── AnalysisError ─────────────────────────────────────────────────────────
    group('AnalysisError', () {
      const state = AnalysisError('Edge function timed out');

      test('is an AnalysisState', () {
        expect(state, isA<AnalysisState>());
      });

      test('isLoading is false', () {
        expect(state.isLoading, isFalse);
      });

      test('hasVerdict is false', () {
        expect(state.hasVerdict, isFalse);
      });

      test('errorMessage returns the message', () {
        expect(state.errorMessage, 'Edge function timed out');
      });

      test('equality holds when messages match', () {
        const same = AnalysisError('Edge function timed out');
        expect(state, equals(same));
      });

      test('equality fails when messages differ', () {
        const different = AnalysisError('Network error');
        expect(state, isNot(equals(different)));
      });

      test('can carry a cause object', () {
        final cause = Exception('timeout');
        final s = AnalysisError('timeout', cause: cause);
        expect(s.cause, same(cause));
      });
    });

    // ── Pattern-matching exhaustiveness ──────────────────────────────────────
    group('exhaustive switch', () {
      String describeState(AnalysisState s) => switch (s) {
            AnalysisIdle() => 'idle',
            AnalysisLoading() => 'loading',
            SecondChanceDetected() => 'second_chance',
            SunsetConfirmed() => 'sunset',
            NeedsMoreContext() => 'needs_context',
            AnalysisError() => 'error',
          };

      test('idle maps to "idle"', () {
        expect(describeState(const AnalysisIdle()), 'idle');
      });

      test('loading maps to "loading"', () {
        expect(describeState(const AnalysisLoading()), 'loading');
      });

      test('SecondChanceDetected maps to "second_chance"', () {
        expect(
          describeState(const SecondChanceDetected(signals: [], nextSteps: [])),
          'second_chance',
        );
      });

      test('SunsetConfirmed maps to "sunset"', () {
        expect(
          describeState(const SunsetConfirmed(reasons: [])),
          'sunset',
        );
      });

      test('NeedsMoreContext maps to "needs_context"', () {
        expect(
          describeState(const NeedsMoreContext(questions: [])),
          'needs_context',
        );
      });

      test('AnalysisError maps to "error"', () {
        expect(describeState(const AnalysisError('oops')), 'error');
      });
    });
  });
}
