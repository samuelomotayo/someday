// test/widget/verdict_badge_test.dart
//
// Widget tests for VerdictBadge: renders correct label and colour for
// each VerdictType value.
//
// Adjust imports and colour constants to match your actual theme.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:someday/domain/entities/verdict_type.dart';
// import 'package:someday/shared/widgets/verdict_badge.dart';

// ---------------------------------------------------------------------------
// Inline VerdictType (same as in verdict_type_test.dart)
// ---------------------------------------------------------------------------
enum VerdictType {
  secondChance,
  sunsetConfirmed,
  needsMoreContext,
  notYetAnalysed;

  String get label {
    switch (this) {
      case VerdictType.secondChance:      return 'Second Chance';
      case VerdictType.sunsetConfirmed:   return 'Sunset Confirmed';
      case VerdictType.needsMoreContext:  return 'Needs More Context';
      case VerdictType.notYetAnalysed:    return 'Not Yet Analysed';
    }
  }
}

// ── Colour tokens — replace with your actual theme values ─────────────────
class _VerdictColors {
  static const secondChance     = Color(0xFF4CAF50); // green
  static const sunsetConfirmed  = Color(0xFFF44336); // red
  static const needsMoreContext = Color(0xFFFF9800); // amber
  static const notYetAnalysed   = Color(0xFF9E9E9E); // grey
}

// ---------------------------------------------------------------------------
// Inline VerdictBadge widget — remove once real widget import is added.
// ---------------------------------------------------------------------------
class VerdictBadge extends StatelessWidget {
  final VerdictType verdict;

  const VerdictBadge({super.key, required this.verdict});

  Color get _backgroundColor {
    switch (verdict) {
      case VerdictType.secondChance:      return _VerdictColors.secondChance;
      case VerdictType.sunsetConfirmed:   return _VerdictColors.sunsetConfirmed;
      case VerdictType.needsMoreContext:  return _VerdictColors.needsMoreContext;
      case VerdictType.notYetAnalysed:    return _VerdictColors.notYetAnalysed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(verdict.label),
      backgroundColor: _backgroundColor,
      // Expose testability: key based on verdict name.
      key: Key('verdict_badge_${verdict.name}'),
    );
  }
}
// ---------------------------------------------------------------------------

Widget _pump(VerdictType verdict) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: VerdictBadge(verdict: verdict)),
    ),
  );
}

/// Returns the background color of the first [Chip] in the tree.
Color? _chipColor(WidgetTester tester) {
  final chip = tester.widget<Chip>(find.byType(Chip));
  return chip.backgroundColor;
}

void main() {
  group('VerdictBadge widget', () {
    // ── secondChance ─────────────────────────────────────────────────────────
    group('VerdictType.secondChance', () {
      testWidgets('renders "Second Chance" label', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.secondChance));
        expect(find.text('Second Chance'), findsOneWidget);
      });

      testWidgets('uses green background colour', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.secondChance));
        expect(_chipColor(tester), _VerdictColors.secondChance);
      });

      testWidgets('has testability key "verdict_badge_secondChance"',
          (tester) async {
        await tester.pumpWidget(_pump(VerdictType.secondChance));
        expect(
          find.byKey(const Key('verdict_badge_secondChance')),
          findsOneWidget,
        );
      });
    });

    // ── sunsetConfirmed ───────────────────────────────────────────────────────
    group('VerdictType.sunsetConfirmed', () {
      testWidgets('renders "Sunset Confirmed" label', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.sunsetConfirmed));
        expect(find.text('Sunset Confirmed'), findsOneWidget);
      });

      testWidgets('uses red background colour', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.sunsetConfirmed));
        expect(_chipColor(tester), _VerdictColors.sunsetConfirmed);
      });

      testWidgets('has testability key "verdict_badge_sunsetConfirmed"',
          (tester) async {
        await tester.pumpWidget(_pump(VerdictType.sunsetConfirmed));
        expect(
          find.byKey(const Key('verdict_badge_sunsetConfirmed')),
          findsOneWidget,
        );
      });
    });

    // ── needsMoreContext ──────────────────────────────────────────────────────
    group('VerdictType.needsMoreContext', () {
      testWidgets('renders "Needs More Context" label', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.needsMoreContext));
        expect(find.text('Needs More Context'), findsOneWidget);
      });

      testWidgets('uses amber background colour', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.needsMoreContext));
        expect(_chipColor(tester), _VerdictColors.needsMoreContext);
      });

      testWidgets('has testability key "verdict_badge_needsMoreContext"',
          (tester) async {
        await tester.pumpWidget(_pump(VerdictType.needsMoreContext));
        expect(
          find.byKey(const Key('verdict_badge_needsMoreContext')),
          findsOneWidget,
        );
      });
    });

    // ── notYetAnalysed ────────────────────────────────────────────────────────
    group('VerdictType.notYetAnalysed', () {
      testWidgets('renders "Not Yet Analysed" label', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.notYetAnalysed));
        expect(find.text('Not Yet Analysed'), findsOneWidget);
      });

      testWidgets('uses grey background colour', (tester) async {
        await tester.pumpWidget(_pump(VerdictType.notYetAnalysed));
        expect(_chipColor(tester), _VerdictColors.notYetAnalysed);
      });
    });

    // ── Coverage: each VerdictType renders exactly one badge ─────────────────
    testWidgets('each VerdictType renders exactly one Chip', (tester) async {
      for (final verdict in VerdictType.values) {
        await tester.pumpWidget(_pump(verdict));
        expect(
          find.byType(Chip),
          findsOneWidget,
          reason: '$verdict should render exactly one Chip',
        );
        await tester.pumpWidget(const SizedBox.shrink()); // clear
      }
    });

    // ── Labels are unique ──────────────────────────────────────────────────────
    test('all VerdictType labels are distinct', () {
      final labels = VerdictType.values.map((v) => v.label).toList();
      final distinct = labels.toSet();
      expect(distinct.length, labels.length);
    });
  });
}
