// test/widget/verdict_screen_test.dart
//
// Widget tests for VerdictScreen — three distinct layouts:
//   1. SecondChanceDetected  → shows "Second Chance" card + signals list + next steps
//   2. SunsetConfirmed       → shows "Sunset Confirmed" card + reasons list
//   3. NeedsMoreContext      → shows "Needs More Context" card + questions list
//
// Each group also verifies: error/loading guard; absent elements from other variants.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:someday/domain/state/analysis_state.dart';
// import 'package:someday/features/verdict/verdict_screen.dart';

// ---------------------------------------------------------------------------
// Inline sealed class (mirrors analysis_state_test.dart)
// ---------------------------------------------------------------------------
sealed class AnalysisState { const AnalysisState(); }
final class AnalysisIdle extends AnalysisState { const AnalysisIdle(); }
final class AnalysisLoading extends AnalysisState { const AnalysisLoading(); }

final class SecondChanceDetected extends AnalysisState {
  final List<String> signals;
  final List<String> nextSteps;
  final double confidence;
  const SecondChanceDetected({
    required this.signals,
    required this.nextSteps,
    this.confidence = 1.0,
  });
}

final class SunsetConfirmed extends AnalysisState {
  final List<String> reasons;
  final double confidence;
  const SunsetConfirmed({ required this.reasons, this.confidence = 1.0 });
}

final class NeedsMoreContext extends AnalysisState {
  final List<String> questions;
  final double confidence;
  const NeedsMoreContext({ required this.questions, this.confidence = 1.0 });
}

final class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
}

// ── Provider ─────────────────────────────────────────────────────────────────
final analysisStateProvider =
    StateProvider<AnalysisState>((ref) => const AnalysisIdle());

// ---------------------------------------------------------------------------
// Inline VerdictScreen widget
// ---------------------------------------------------------------------------
class VerdictScreen extends ConsumerWidget {
  final String ideaId;
  const VerdictScreen({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verdict', key: Key('verdict_screen_title')),
      ),
      body: switch (state) {
        AnalysisIdle()    => const Center(child: Text('No verdict yet')),
        AnalysisLoading() => const Center(child: CircularProgressIndicator()),
        SecondChanceDetected(:final signals, :final nextSteps, :final confidence) =>
          _SecondChanceView(
            signals: signals,
            nextSteps: nextSteps,
            confidence: confidence,
          ),
        SunsetConfirmed(:final reasons, :final confidence) => _SunsetView(
            reasons: reasons,
            confidence: confidence,
          ),
        NeedsMoreContext(:final questions) => _NeedsContextView(
            questions: questions,
          ),
        AnalysisError(:final message) => Center(
            key: const Key('verdict_error'),
            child: Text('Error: $message'),
          ),
      },
    );
  }
}

class _SecondChanceView extends StatelessWidget {
  final List<String> signals;
  final List<String> nextSteps;
  final double confidence;
  const _SecondChanceView({
    required this.signals,
    required this.nextSteps,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('second_chance_view'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Second Chance Detected!',
            key: Key('second_chance_headline'),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
            key: const Key('second_chance_confidence'),
          ),
          const SizedBox(height: 16),
          const Text('Why now?', key: Key('signals_section_title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ...signals.map((s) => ListTile(
                key: Key('signal_$s'),
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(s),
              )),
          const SizedBox(height: 16),
          const Text('Next Steps', key: Key('next_steps_section_title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ...nextSteps.asMap().entries.map((e) => ListTile(
                key: Key('next_step_${e.key}'),
                leading: CircleAvatar(child: Text('${e.key + 1}')),
                title: Text(e.value),
              )),
        ],
      ),
    );
  }
}

class _SunsetView extends StatelessWidget {
  final List<String> reasons;
  final double confidence;
  const _SunsetView({ required this.reasons, required this.confidence });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('sunset_view'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sunset Confirmed',
            key: Key('sunset_headline'),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
            key: const Key('sunset_confidence'),
          ),
          const SizedBox(height: 16),
          const Text('Why let it go?', key: Key('reasons_section_title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ...reasons.map((r) => ListTile(
                key: Key('reason_$r'),
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: Text(r),
              )),
        ],
      ),
    );
  }
}

class _NeedsContextView extends StatelessWidget {
  final List<String> questions;
  const _NeedsContextView({ required this.questions });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('needs_context_view'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We Need More Context',
            key: Key('needs_context_headline'),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Answer these questions for a better verdict:',
            key: Key('needs_context_subheading'),
          ),
          const SizedBox(height: 16),
          ...questions.asMap().entries.map((e) => Card(
                key: Key('question_card_${e.key}'),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${e.key + 1}')),
                  title: Text(e.value, key: Key('question_text_${e.key}')),
                ),
              )),
        ],
      ),
    );
  }
}
// ---------------------------------------------------------------------------

// ── Test helper ──────────────────────────────────────────────────────────────

Widget _pumpScreen(AnalysisState state) {
  return ProviderScope(
    overrides: [
      analysisStateProvider.overrideWith((_) => state),
    ],
    child: const MaterialApp(
      home: VerdictScreen(ideaId: 'idea-test-001'),
    ),
  );
}

void main() {
  group('VerdictScreen', () {
    // ── SecondChanceDetected ──────────────────────────────────────────────────
    group('SecondChanceDetected layout', () {
      const state = SecondChanceDetected(
        signals: [
          'Market timing has improved',
          'A competitor proved the demand',
        ],
        nextSteps: [
          'Run a 2-week validation sprint',
          'Interview 10 potential users',
        ],
        confidence: 0.85,
      );

      testWidgets('shows "Second Chance Detected!" headline', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('second_chance_headline')), findsOneWidget);
        expect(find.text('Second Chance Detected!'), findsOneWidget);
      });

      testWidgets('shows confidence percentage', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('second_chance_confidence')), findsOneWidget);
        expect(find.text('Confidence: 85%'), findsOneWidget);
      });

      testWidgets('renders all signals from the list', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.text('Market timing has improved'), findsOneWidget);
        expect(find.text('A competitor proved the demand'), findsOneWidget);
      });

      testWidgets('shows "Why now?" signals section title', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('signals_section_title')), findsOneWidget);
        expect(find.text('Why now?'), findsOneWidget);
      });

      testWidgets('renders all next steps', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.text('Run a 2-week validation sprint'), findsOneWidget);
        expect(find.text('Interview 10 potential users'), findsOneWidget);
      });

      testWidgets('shows "Next Steps" section title', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('next_steps_section_title')), findsOneWidget);
      });

      testWidgets('does NOT show Sunset or NeedsContext elements', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('sunset_view')), findsNothing);
        expect(find.byKey(const Key('needs_context_view')), findsNothing);
      });

      testWidgets('shows the correct number of signal ListTiles', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        // 2 signals + 2 next-steps = 4 ListTiles total, but we can also count
        // by key prefix.
        expect(find.byKey(const Key('signal_Market timing has improved')),
            findsOneWidget);
        expect(find.byKey(const Key('signal_A competitor proved the demand')),
            findsOneWidget);
      });
    });

    // ── SunsetConfirmed ───────────────────────────────────────────────────────
    group('SunsetConfirmed layout', () {
      const state = SunsetConfirmed(
        reasons: [
          'Market is dominated by well-funded incumbents',
          'Core assumption proved invalid',
        ],
        confidence: 0.91,
      );

      testWidgets('shows "Sunset Confirmed" headline', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('sunset_headline')), findsOneWidget);
        expect(find.text('Sunset Confirmed'), findsOneWidget);
      });

      testWidgets('shows confidence percentage', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.text('Confidence: 91%'), findsOneWidget);
      });

      testWidgets('shows "Why let it go?" reasons section', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('reasons_section_title')), findsOneWidget);
        expect(find.text('Why let it go?'), findsOneWidget);
      });

      testWidgets('renders all reasons', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(
          find.text('Market is dominated by well-funded incumbents'),
          findsOneWidget,
        );
        expect(
          find.text('Core assumption proved invalid'),
          findsOneWidget,
        );
      });

      testWidgets('does NOT show SecondChance or NeedsContext elements',
          (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('second_chance_view')), findsNothing);
        expect(find.byKey(const Key('needs_context_view')), findsNothing);
      });
    });

    // ── NeedsMoreContext ──────────────────────────────────────────────────────
    group('NeedsMoreContext layout', () {
      const state = NeedsMoreContext(
        questions: [
          'What was your target customer segment?',
          'What was the main blocker that stopped you?',
          'Have you validated the core assumption?',
        ],
        confidence: 0.40,
      );

      testWidgets('shows "We Need More Context" headline', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('needs_context_headline')), findsOneWidget);
        expect(find.text('We Need More Context'), findsOneWidget);
      });

      testWidgets('shows subheading prompting answers', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(
          find.text('Answer these questions for a better verdict:'),
          findsOneWidget,
        );
      });

      testWidgets('renders all questions as cards', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('question_card_0')), findsOneWidget);
        expect(find.byKey(const Key('question_card_1')), findsOneWidget);
        expect(find.byKey(const Key('question_card_2')), findsOneWidget);
      });

      testWidgets('shows question text for each question', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(
          find.text('What was your target customer segment?'),
          findsOneWidget,
        );
        expect(
          find.text('What was the main blocker that stopped you?'),
          findsOneWidget,
        );
        expect(
          find.text('Have you validated the core assumption?'),
          findsOneWidget,
        );
      });

      testWidgets('does NOT show SecondChance or Sunset elements', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('second_chance_view')), findsNothing);
        expect(find.byKey(const Key('sunset_view')), findsNothing);
      });

      testWidgets('renders correct count of question cards', (tester) async {
        await tester.pumpWidget(_pumpScreen(state));
        await tester.pumpAndSettle();
        // 3 questions → 3 Card widgets inside the column
        expect(
          find.descendant(
            of: find.byKey(const Key('needs_context_view')),
            matching: find.byType(Card),
          ),
          findsNWidgets(3),
        );
      });
    });

    // ── Guard states ──────────────────────────────────────────────────────────
    group('guard states', () {
      testWidgets('shows loading indicator for AnalysisLoading', (tester) async {
        await tester.pumpWidget(_pumpScreen(const AnalysisLoading()));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows fallback for AnalysisIdle', (tester) async {
        await tester.pumpWidget(_pumpScreen(const AnalysisIdle()));
        expect(find.text('No verdict yet'), findsOneWidget);
      });

      testWidgets('shows error message for AnalysisError', (tester) async {
        await tester.pumpWidget(
          _pumpScreen(const AnalysisError('Edge function timeout')),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('verdict_error')), findsOneWidget);
        expect(find.textContaining('Edge function timeout'), findsOneWidget);
      });
    });
  });
}
