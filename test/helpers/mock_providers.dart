// test/helpers/mock_providers.dart
//
// Riverpod ProviderContainer override helpers for unit and widget tests.
// Usage:
//   final container = makeContainer(overrides: [
//     resurrectionRepositoryProvider.overrideWith((ref) => MockResurrectionRepository()),
//   ]);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// ── Domain / repository interfaces ──────────────────────────────────────────

// Import your real provider declarations from the app.
// Adjust these import paths to match your actual lib/ layout.
//
// import 'package:someday/data/repositories/resurrection_repository.dart';
// import 'package:someday/data/repositories/idea_repository.dart';
// import 'package:someday/domain/services/usage_count_service.dart';

// ── Mock classes ─────────────────────────────────────────────────────────────

/// Paste-and-go mocks — extend as your interfaces grow.
///
/// Because these depend on your real classes the imports above must be
/// uncommented and point at the correct paths before running the suite.

// class MockResurrectionRepository extends Mock
//     implements ResurrectionRepository {}

// class MockIdeaRepository extends Mock implements IdeaRepository {}

// class MockUsageCountService extends Mock implements UsageCountService {}

// ── Container factory ─────────────────────────────────────────────────────────

/// Creates a fresh [ProviderContainer] with optional overrides and an
/// automatic [addTearDown] so tests never share state.
///
/// Example:
/// ```dart
/// final container = makeContainer(
///   ref,                              // WidgetTester / test ref
///   overrides: [
///     resurrectionRepositoryProvider
///         .overrideWith((_) => MockResurrectionRepository()),
///   ],
/// );
/// ```
ProviderContainer makeContainer({
  List<Override> overrides = const [],
  List<ProviderObserver> observers = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides,
    observers: observers,
  );
  // Automatically dispose after the current test completes.
  // Call addTearDown(container.dispose) in your test body, or wrap with
  // the helper below.
  return container;
}

/// Wraps [makeContainer] and registers disposal as a teardown automatically
/// when used inside a `test()` / `testWidgets()` body.
///
/// Usage:
/// ```dart
/// test('example', () {
///   final container = createContainer(overrides: [...]);
///   // container is auto-disposed at end of test
/// });
/// ```
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  // addTearDown is package:test's global teardown registration.
  addTearDown(container.dispose);
  return container;
}

// ── Widget-test pump helper ───────────────────────────────────────────────────

/// Returns a [ProviderScope] widget that wraps [child] with the given
/// [overrides].  Use this inside `testWidgets` with `tester.pumpWidget(...)`.
///
/// ```dart
/// await tester.pumpWidget(
///   testProviderScope(
///     overrides: [someProvider.overrideWithValue(fakeValue)],
///     child: const MyWidget(),
///   ),
/// );
/// ```
// ignore: always_use_package_imports
import 'package:flutter/material.dart';

Widget testProviderScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

// ── Listener recorder ─────────────────────────────────────────────────────────

/// Records every state emitted by a provider so you can assert on the
/// sequence without managing streams manually.
///
/// Usage:
/// ```dart
/// final recorder = ProviderStateRecorder<AnalysisState>();
/// container.listen(analysisNotifierProvider, recorder.call,
///                  fireImmediately: true);
/// await container.read(analysisNotifierProvider.notifier).analyse(idea);
/// expect(recorder.states, [
///   isA<AnalysisIdle>(),
///   isA<AnalysisLoading>(),
///   isA<SecondChanceDetected>(),
/// ]);
/// ```
class ProviderStateRecorder<T> {
  final List<T> states = [];

  void call(T? previous, T next) => states.add(next);
}
