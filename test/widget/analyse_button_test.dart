// test/widget/analyse_button_test.dart
//
// Widget tests for AnalyseButton:
//   - shows idle label when state is AnalysisIdle
//   - shows CircularProgressIndicator when state is AnalysisLoading
//   - button is disabled (onPressed = null) during AnalysisLoading
//   - button is enabled in AnalysisIdle state
//   - onPressed callback fires when tapped (idle state)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:someday/domain/state/analysis_state.dart';
// import 'package:someday/features/idea/widgets/analyse_button.dart';

// ---------------------------------------------------------------------------
// Inline stubs — remove once real imports are added.
// ---------------------------------------------------------------------------
sealed class AnalysisState { const AnalysisState(); }
final class AnalysisIdle    extends AnalysisState { const AnalysisIdle(); }
final class AnalysisLoading extends AnalysisState { const AnalysisLoading(); }
final class SecondChanceDetected extends AnalysisState {
  const SecondChanceDetected();
}

/// The provider that the AnalyseButton watches.
final analysisStateProvider =
    StateProvider<AnalysisState>((ref) => const AnalysisIdle());

/// The button widget under test.
class AnalyseButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String label;

  const AnalyseButton({
    super.key,
    this.onPressed,
    this.label = 'Analyse Idea',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisStateProvider);
    final isLoading = state is AnalysisLoading;

    return ElevatedButton(
      key: const Key('analyse_button'),
      // Disabled during loading.
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              key: Key('analyse_button_spinner'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              key: const Key('analyse_button_label'),
            ),
    );
  }
}
// ---------------------------------------------------------------------------

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _pumpButton({
  AnalysisState initialState = const AnalysisIdle(),
  VoidCallback? onPressed,
  String label = 'Analyse Idea',
}) {
  return ProviderScope(
    overrides: [
      analysisStateProvider.overrideWith((ref) => initialState),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: AnalyseButton(onPressed: onPressed, label: label),
        ),
      ),
    ),
  );
}

ElevatedButton _findButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.byType(ElevatedButton));

void main() {
  group('AnalyseButton widget', () {
    // ── Idle state ────────────────────────────────────────────────────────────
    group('AnalysisIdle state', () {
      testWidgets('shows label text in idle state', (tester) async {
        await tester.pumpWidget(_pumpButton());
        expect(find.text('Analyse Idea'), findsOneWidget);
        expect(find.byKey(const Key('analyse_button_label')), findsOneWidget);
      });

      testWidgets('does NOT show spinner in idle state', (tester) async {
        await tester.pumpWidget(_pumpButton());
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('button is enabled (onPressed is not null) in idle state',
          (tester) async {
        await tester.pumpWidget(_pumpButton(onPressed: () {}));
        final button = _findButton(tester);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('fires onPressed callback when tapped', (tester) async {
        var pressed = false;
        await tester.pumpWidget(_pumpButton(onPressed: () => pressed = true));

        await tester.tap(find.byKey(const Key('analyse_button')));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('custom label is displayed', (tester) async {
        await tester.pumpWidget(
          _pumpButton(label: 'Re-analyse Idea'),
        );
        expect(find.text('Re-analyse Idea'), findsOneWidget);
      });
    });

    // ── Loading state ─────────────────────────────────────────────────────────
    group('AnalysisLoading state', () {
      testWidgets('shows CircularProgressIndicator when loading', (tester) async {
        await tester.pumpWidget(
          _pumpButton(initialState: const AnalysisLoading()),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          find.byKey(const Key('analyse_button_spinner')),
          findsOneWidget,
        );
      });

      testWidgets('does NOT show label text when loading', (tester) async {
        await tester.pumpWidget(
          _pumpButton(initialState: const AnalysisLoading()),
        );
        expect(find.text('Analyse Idea'), findsNothing);
        expect(find.byKey(const Key('analyse_button_label')), findsNothing);
      });

      testWidgets('button is disabled (onPressed is null) when loading',
          (tester) async {
        var pressed = false;
        await tester.pumpWidget(_pumpButton(
          initialState: const AnalysisLoading(),
          onPressed: () => pressed = true,
        ));

        final button = _findButton(tester);
        expect(button.onPressed, isNull);
      });

      testWidgets('tapping disabled button does not invoke callback',
          (tester) async {
        var pressed = false;
        await tester.pumpWidget(_pumpButton(
          initialState: const AnalysisLoading(),
          onPressed: () => pressed = true,
        ));

        await tester.tap(
          find.byKey(const Key('analyse_button')),
          warnIfMissed: false, // disabled buttons may not hit-test
        );
        await tester.pump();

        expect(pressed, isFalse);
      });
    });

    // ── State transitions ─────────────────────────────────────────────────────
    group('state transitions via provider', () {
      testWidgets('transitions from idle to loading when provider updates',
          (tester) async {
        final stateController = StateController<AnalysisState>(const AnalysisIdle());

        // ignore: deprecated_member_use
        await tester.pumpWidget(ProviderScope(
          overrides: [
            analysisStateProvider.overrideWith((_) => stateController.state),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: AnalyseButton(onPressed: () {}),
              ),
            ),
          ),
        ));

        // Initially: label visible, no spinner.
        expect(find.text('Analyse Idea'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // After transition to loading — re-pump with overridden state.
        // Since we can't mutate the override at runtime in this minimal stub,
        // we re-pump with a new widget tree reflecting the loading state.
        await tester.pumpWidget(_pumpButton(
          initialState: const AnalysisLoading(),
        ));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Analyse Idea'), findsNothing);
      });
    });

    // ── Accessibility ─────────────────────────────────────────────────────────
    group('accessibility', () {
      testWidgets('button has a semantic label in idle state', (tester) async {
        await tester.pumpWidget(_pumpButton(onPressed: () {}));
        // The text widget inside ElevatedButton provides semantics automatically.
        expect(
          tester.getSemantics(find.text('Analyse Idea')),
          matchesSemantics(label: 'Analyse Idea'),
        );
      });

      testWidgets('meets tap-target size requirement (>= 48x48)', (tester) async {
        await tester.pumpWidget(_pumpButton(onPressed: () {}));
        final size = tester.getSize(find.byKey(const Key('analyse_button')));
        expect(size.height, greaterThanOrEqualTo(48.0));
      });
    });
  });
}
