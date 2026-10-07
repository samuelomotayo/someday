import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:someday/shared/widgets/verdict_badge.dart';
import 'package:someday/domain/entities/verdict_type.dart';

void main() {
  testWidgets('VerdictBadge renders correct label for each verdict type',
      (WidgetTester tester) async {
    for (final verdict in VerdictType.values) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: VerdictBadge(verdict: verdict)),
          ),
        ),
      );

      expect(find.byKey(Key('verdict_badge_${verdict.name}')), findsOneWidget);
    }
  });
}
