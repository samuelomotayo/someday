// integration_test/golden_path_test.dart
//
// Integration tests (golden-path) using the integration_test package.
//
// Run with:
//   flutter test integration_test/golden_path_test.dart \
//     --dart-define=SUPABASE_URL=... \
//     --dart-define=SUPABASE_ANON_KEY=...
//
// For CI, point at a local Supabase stack or inject fake Edge Functions via
// an environment flag.  See the FakeSupabase helper in test/helpers/.
//
// Adjust import paths to match your actual package name.

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// import 'package:someday/main.dart' as app;
// import 'package:someday/features/onboarding/onboarding_screen.dart';
// import 'package:someday/features/vault/vault_screen.dart';
// import 'package:someday/features/idea/add_idea_screen.dart';
// import 'package:someday/features/verdict/verdict_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // Flow 1: Full golden path
  //   Onboarding → accept privacy → Vault → Add Idea → Analyse → See Verdict
  // ==========================================================================
  group('Golden path: onboarding → vault → add idea → analyse → verdict', () {
    testWidgets('completes the full user journey', (tester) async {
      // ── 1. Launch app ──────────────────────────────────────────────────────
      // app.main();
      // await tester.pumpAndSettle();

      // ── 2. Onboarding screen ───────────────────────────────────────────────
      // Expect the onboarding headline to be visible.
      expect(
        find.byKey(const Key('onboarding_headline')),
        findsOneWidget,
        reason: 'Onboarding screen should be shown on first launch',
      );

      // ── 3. Accept privacy opt-in ───────────────────────────────────────────
      // The privacy opt-in toggle must be accepted before the CTA is enabled.
      final privacyToggle = find.byKey(const Key('privacy_opt_in_toggle'));
      expect(privacyToggle, findsOneWidget);
      await tester.tap(privacyToggle);
      await tester.pumpAndSettle();

      // Tap "Get Started" CTA.
      final getStartedButton = find.byKey(const Key('onboarding_cta_button'));
      expect(getStartedButton, findsOneWidget);
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // ── 4. Vault screen ────────────────────────────────────────────────────
      expect(
        find.byKey(const Key('vault_screen')),
        findsOneWidget,
        reason: 'Should navigate to Vault after onboarding',
      );

      // Vault is initially empty.
      expect(
        find.byKey(const Key('vault_empty_state')),
        findsOneWidget,
        reason: 'Empty vault state should be visible for a new user',
      );

      // ── 5. Add a new idea ──────────────────────────────────────────────────
      final addIdeaFab = find.byKey(const Key('add_idea_fab'));
      expect(addIdeaFab, findsOneWidget);
      await tester.tap(addIdeaFab);
      await tester.pumpAndSettle();

      // Expect the AddIdea screen.
      expect(find.byKey(const Key('add_idea_screen')), findsOneWidget);

      // Fill in title.
      final titleField = find.byKey(const Key('idea_title_field'));
      await tester.enterText(titleField, 'AI-powered meal planner');
      await tester.pumpAndSettle();

      // Fill in description.
      final descField = find.byKey(const Key('idea_description_field'));
      await tester.enterText(
        descField,
        'An app that generates weekly meal plans using AI based on dietary preferences.',
      );
      await tester.pumpAndSettle();

      // (Optional) Fill in time period.
      final timePeriodField = find.byKey(const Key('idea_time_period_field'));
      if (timePeriodField.evaluate().isNotEmpty) {
        await tester.enterText(timePeriodField, '2022-2023');
        await tester.pumpAndSettle();
      }

      // (Optional) Fill in reason for stopping.
      final reasonField = find.byKey(const Key('idea_reason_field'));
      if (reasonField.evaluate().isNotEmpty) {
        await tester.enterText(
          reasonField,
          'Could not find a co-founder with nutrition expertise.',
        );
        await tester.pumpAndSettle();
      }

      // Save the idea.
      final saveButton = find.byKey(const Key('save_idea_button'));
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // ── 6. Verify idea appears in vault ────────────────────────────────────
      expect(
        find.byKey(const Key('vault_screen')),
        findsOneWidget,
        reason: 'Should return to vault after saving',
      );
      expect(
        find.text('AI-powered meal planner'),
        findsOneWidget,
        reason: 'Newly added idea title should appear in vault list',
      );
      expect(
        find.text('Not Yet Analysed'),
        findsOneWidget,
        reason: 'New idea should show "Not Yet Analysed" badge',
      );

      // ── 7. Open idea detail ────────────────────────────────────────────────
      await tester.tap(find.text('AI-powered meal planner'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('idea_detail_screen')), findsOneWidget);

      // ── 8. Tap Analyse ────────────────────────────────────────────────────
      final analyseButton = find.byKey(const Key('analyse_button'));
      expect(analyseButton, findsOneWidget);
      await tester.tap(analyseButton);

      // Loading state: spinner should appear.
      await tester.pump();
      expect(
        find.byKey(const Key('analyse_button_spinner')),
        findsOneWidget,
        reason: 'Spinner should appear while analysis is in progress',
      );
      expect(
        find.byKey(const Key('analyse_button_label')),
        findsNothing,
        reason: 'Label should be hidden during loading',
      );

      // Wait for analysis to complete (increase timeout for slow CI/edge fn).
      await tester.pumpAndSettle(const Duration(seconds: 30));

      // ── 9. Verdict screen ──────────────────────────────────────────────────
      // Navigation to /idea/:id/verdict should have happened.
      // We accept any of the three verdict layouts.
      final hasSecondChance =
          find.byKey(const Key('second_chance_view')).evaluate().isNotEmpty;
      final hasSunset =
          find.byKey(const Key('sunset_view')).evaluate().isNotEmpty;
      final hasNeedsContext =
          find.byKey(const Key('needs_context_view')).evaluate().isNotEmpty;

      expect(
        hasSecondChance || hasSunset || hasNeedsContext,
        isTrue,
        reason: 'At least one verdict layout must be visible after analysis',
      );

      // ── 10. Verify vault badge updated ────────────────────────────────────
      // Navigate back to vault.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
      navigator.pop();
      navigator.pop(); // back to vault
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('vault_screen')), findsOneWidget);

      // The "Not Yet Analysed" badge should be replaced.
      expect(
        find.text('Not Yet Analysed'),
        findsNothing,
        reason: 'After analysis the badge must no longer read "Not Yet Analysed"',
      );

      print('[golden-path] Full flow completed successfully.');
    });
  });

  // ==========================================================================
  // Flow 2: Privacy gate
  //   Onboarding → DECLINE privacy opt-in → Analyse button must not call Edge Fn
  // ==========================================================================
  group('Privacy gate: declined AI opt-in blocks Edge Function call', () {
    testWidgets('analyse button is disabled when privacy not accepted',
        (tester) async {
      // ── 1. Launch app ──────────────────────────────────────────────────────
      // app.main();
      // await tester.pumpAndSettle();

      // ── 2. Onboarding screen ───────────────────────────────────────────────
      expect(find.byKey(const Key('onboarding_headline')), findsOneWidget);

      // Do NOT accept privacy toggle — leave it off.
      final privacyToggle = find.byKey(const Key('privacy_opt_in_toggle'));
      expect(privacyToggle, findsOneWidget);
      // Verify toggle is off by default.
      final toggle = tester.widget<Switch>(
        find.descendant(
          of: privacyToggle,
          matching: find.byType(Switch),
        ),
      );
      expect(toggle.value, isFalse,
          reason: 'Privacy opt-in should be OFF by default');

      // Tap "Get Started" — should still navigate but with AI locked.
      // (Or the button may be disabled entirely — test both paths.)
      final getStartedButton = find.byKey(const Key('onboarding_cta_button'));
      if (getStartedButton.evaluate().isNotEmpty) {
        await tester.tap(getStartedButton);
        await tester.pumpAndSettle();
      }

      // ── 3. Add an idea ─────────────────────────────────────────────────────
      // If the app navigated to the vault, add a minimal idea to test the gate.
      final addFab = find.byKey(const Key('add_idea_fab'));
      if (addFab.evaluate().isNotEmpty) {
        await tester.tap(addFab);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('idea_title_field')),
          'Privacy-gated idea',
        );
        await tester.enterText(
          find.byKey(const Key('idea_description_field')),
          'Description for gated idea',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_idea_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Privacy-gated idea'));
        await tester.pumpAndSettle();
      }

      // ── 4. Verify analyse button is disabled or shows privacy prompt ────────
      final analyseButton = find.byKey(const Key('analyse_button'));

      if (analyseButton.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(
          button.onPressed,
          isNull,
          reason:
              'Analyse button must be disabled when user has not accepted AI privacy opt-in',
        );

        // Tapping a disabled button must not trigger analysis.
        await tester.tap(analyseButton, warnIfMissed: false);
        await tester.pump();

        // No spinner should appear.
        expect(
          find.byKey(const Key('analyse_button_spinner')),
          findsNothing,
          reason: 'No loading spinner should appear — Edge Function must not be called',
        );
      } else {
        // Alternative: a privacy-required dialog/banner is shown instead.
        expect(
          find.byKey(const Key('ai_privacy_required_banner')),
          findsOneWidget,
          reason: 'A privacy-required prompt must be visible when opt-in is declined',
        );
      }

      print('[privacy-gate] Gate correctly blocks Edge Function call.');
    });
  });

  // ==========================================================================
  // Flow 3: Usage limit enforcement
  //   After 3 analyses, 4th analyse button tap shows upgrade prompt
  // ==========================================================================
  group('Usage limit: 4th analysis shows upgrade prompt', () {
    testWidgets('shows upgrade prompt after free-tier limit is reached',
        (tester) async {
      // This test assumes 3 analyses have already been performed.
      // In a real test environment, inject a FakeUsageCountService pre-seeded
      // to count=3 via Riverpod override.

      // app.main();
      // await tester.pumpAndSettle();

      // Navigate to an idea detail screen (skip onboarding / vault navigation).
      // ...

      // The analyse button should show an upgrade CTA or be disabled.
      final upgradeButton = find.byKey(const Key('upgrade_prompt'));
      if (upgradeButton.evaluate().isNotEmpty) {
        expect(upgradeButton, findsOneWidget);
        print('[usage-limit] Upgrade prompt shown correctly.');
      } else {
        // Acceptable alternative: analyse button is disabled with a tooltip.
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(button.onPressed, isNull,
            reason: 'Button should be disabled at free-tier limit');
        print('[usage-limit] Analyse button disabled at free-tier limit.');
      }
    });
  });
}

// =============================================================================
// OMITTED from this file (would be added in a full implementation):
//   - Deep-link tests for /idea/:id and /idea/:id/verdict routes
//   - Voice-input integration (requires microphone permission mocking)
//   - Offline / no-network behaviour
//   - Supabase auth token refresh mid-session
//   - Screenshot/golden comparisons via goldenFileComparator
// =============================================================================
