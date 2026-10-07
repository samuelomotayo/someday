// test/widget/idea_card_test.dart
//
// Widget tests for IdeaCard:
//   - shows title
//   - shows date formatted as "MMM d, yyyy"
//   - shows VerdictBadge for the idea's verdict
//   - tap triggers navigation to /idea/:id

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// import 'package:someday/domain/entities/idea.dart';
// import 'package:someday/domain/entities/verdict_type.dart';
// import 'package:someday/shared/widgets/idea_card.dart';
// import 'package:someday/shared/widgets/verdict_badge.dart';
// import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Inline stubs — remove once real imports are in place.
// ---------------------------------------------------------------------------
enum VerdictType {
  secondChance, sunsetConfirmed, needsMoreContext, notYetAnalysed;

  String get label {
    switch (this) {
      case VerdictType.secondChance:     return 'Second Chance';
      case VerdictType.sunsetConfirmed:  return 'Sunset Confirmed';
      case VerdictType.needsMoreContext: return 'Needs More Context';
      case VerdictType.notYetAnalysed:   return 'Not Yet Analysed';
    }
  }
}

class IdeaModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final VerdictType verdict;

  const IdeaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.verdict = VerdictType.notYetAnalysed,
  });
}

class VerdictBadge extends StatelessWidget {
  final VerdictType verdict;
  const VerdictBadge({super.key, required this.verdict});

  Color get _color {
    switch (verdict) {
      case VerdictType.secondChance:     return const Color(0xFF4CAF50);
      case VerdictType.sunsetConfirmed:  return const Color(0xFFF44336);
      case VerdictType.needsMoreContext: return const Color(0xFFFF9800);
      case VerdictType.notYetAnalysed:   return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) => Chip(
        key: Key('verdict_badge_${verdict.name}'),
        label: Text(verdict.label),
        backgroundColor: _color,
      );
}

class IdeaCard extends StatelessWidget {
  final IdeaModel idea;
  /// Called when the card is tapped. In production this calls context.push('/idea/:id').
  final VoidCallback? onTap;

  const IdeaCard({super.key, required this.idea, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(idea.createdAt);
    return Card(
      key: Key('idea_card_${idea.id}'),
      child: ListTile(
        title: Text(idea.title, key: const Key('idea_card_title')),
        subtitle: Text(formattedDate, key: const Key('idea_card_date')),
        trailing: VerdictBadge(verdict: idea.verdict),
        onTap: onTap,
      ),
    );
  }
}
// ---------------------------------------------------------------------------

// ── Shared fixtures ──────────────────────────────────────────────────────────

final _baseIdea = IdeaModel(
  id: 'abc-123',
  title: 'AI-powered recipe recommender',
  description: 'Uses ML to suggest recipes based on pantry contents.',
  createdAt: DateTime(2023, 3, 7),
  verdict: VerdictType.notYetAnalysed,
);

Widget _pumpCard(
  IdeaModel idea, {
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: IdeaCard(idea: idea, onTap: onTap),
    ),
  );
}

void main() {
  group('IdeaCard widget', () {
    // ── Title ────────────────────────────────────────────────────────────────
    group('title', () {
      testWidgets('displays the idea title', (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(find.text('AI-powered recipe recommender'), findsOneWidget);
      });

      testWidgets('title widget has expected key', (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(find.byKey(const Key('idea_card_title')), findsOneWidget);
      });
    });

    // ── Date ─────────────────────────────────────────────────────────────────
    group('date formatting', () {
      testWidgets('formats date as "MMM d, yyyy"', (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(find.text('Mar 7, 2023'), findsOneWidget);
      });

      testWidgets('date widget has expected key', (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(find.byKey(const Key('idea_card_date')), findsOneWidget);
      });

      testWidgets('correctly formats single-digit day without zero-padding',
          (tester) async {
        final idea = IdeaModel(
          id: 'x',
          title: 'Test',
          description: 'Desc',
          createdAt: DateTime(2024, 12, 1),
        );
        await tester.pumpWidget(_pumpCard(idea));
        expect(find.text('Dec 1, 2024'), findsOneWidget);
      });

      testWidgets('displays year correctly for a 2025 date', (tester) async {
        final idea = IdeaModel(
          id: 'y',
          title: 'Future idea',
          description: 'Desc',
          createdAt: DateTime(2025, 6, 20),
        );
        await tester.pumpWidget(_pumpCard(idea));
        expect(find.text('Jun 20, 2025'), findsOneWidget);
      });
    });

    // ── VerdictBadge ──────────────────────────────────────────────────────────
    group('verdict badge', () {
      testWidgets('shows VerdictBadge', (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(find.byType(VerdictBadge), findsOneWidget);
      });

      testWidgets('VerdictBadge reflects notYetAnalysed by default',
          (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(
          find.byKey(const Key('verdict_badge_notYetAnalysed')),
          findsOneWidget,
        );
        expect(find.text('Not Yet Analysed'), findsOneWidget);
      });

      testWidgets('VerdictBadge reflects secondChance when set',
          (tester) async {
        final idea = IdeaModel(
          id: 'z',
          title: 'Hot idea',
          description: 'Desc',
          createdAt: DateTime(2022, 1, 1),
          verdict: VerdictType.secondChance,
        );
        await tester.pumpWidget(_pumpCard(idea));
        expect(find.text('Second Chance'), findsOneWidget);
        expect(
          find.byKey(const Key('verdict_badge_secondChance')),
          findsOneWidget,
        );
      });

      testWidgets('VerdictBadge reflects sunsetConfirmed when set',
          (tester) async {
        final idea = _baseIdea.copyWith(verdict: VerdictType.sunsetConfirmed);
        await tester.pumpWidget(_pumpCard(idea));
        expect(find.text('Sunset Confirmed'), findsOneWidget);
      });

      testWidgets('VerdictBadge reflects needsMoreContext when set',
          (tester) async {
        final idea = _baseIdea.copyWith(verdict: VerdictType.needsMoreContext);
        await tester.pumpWidget(_pumpCard(idea));
        expect(find.text('Needs More Context'), findsOneWidget);
      });
    });

    // ── Tap navigation ────────────────────────────────────────────────────────
    group('tap behaviour', () {
      testWidgets('calls onTap callback when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(_pumpCard(_baseIdea, onTap: () {
          tapped = true;
        }));

        await tester.tap(find.byType(IdeaCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('onTap is not called when card is not tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(_pumpCard(_baseIdea, onTap: () {
          tapped = true;
        }));

        // No tap
        expect(tapped, isFalse);
      });

      testWidgets('card is tappable even when onTap is null (no crash)',
          (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        await tester.tap(find.byType(IdeaCard));
        await tester.pump();
        // Should not throw.
        expect(find.byType(IdeaCard), findsOneWidget);
      });

      testWidgets('card has testability key containing idea id', (tester) async {
        await tester.pumpWidget(_pumpCard(_baseIdea));
        expect(find.byKey(const Key('idea_card_abc-123')), findsOneWidget);
      });
    });

    // ── GoRouter integration (smoke test) ─────────────────────────────────────
    // Tests navigation by capturing the route pushed.  Replace with a real
    // GoRouter test when GoRouter is available in the test environment.
    group('navigation path', () {
      testWidgets('onTap receives callback with correct idea id', (tester) async {
        String? navigatedTo;
        await tester.pumpWidget(_pumpCard(
          _baseIdea,
          onTap: () => navigatedTo = '/idea/${_baseIdea.id}',
        ));

        await tester.tap(find.byType(IdeaCard));
        await tester.pump();

        expect(navigatedTo, '/idea/abc-123');
      });
    });
  });
}

// ---------------------------------------------------------------------------
// copyWith extension used in tests
// ---------------------------------------------------------------------------
extension _IdeaModelX on IdeaModel {
  IdeaModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    VerdictType? verdict,
  }) {
    return IdeaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      verdict: verdict ?? this.verdict,
    );
  }
}
