import 'package:flutter/material.dart';
import 'package:someday/domain/entities/verdict_type.dart';

class VerdictBadge extends StatelessWidget {
  const VerdictBadge({required this.verdict, super.key});

  final VerdictType verdict;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _style(verdict);
    return Chip(
      key: Key('verdict_badge_${verdict.name}'),
      label: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: bg,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  static (String, Color, Color) _style(VerdictType v) => switch (v) {
        VerdictType.secondChance => (
            'Second Chance',
            const Color(0xFF1A3A2A),
            const Color(0xFF6EE7A0),
          ),
        VerdictType.sunsetConfirmed => (
            'Sunset Confirmed',
            const Color(0xFF3A1A1A),
            const Color(0xFFF9A8A8),
          ),
        VerdictType.needsMoreContext => (
            'Needs Context',
            const Color(0xFF2A2A1A),
            const Color(0xFFFBE08A),
          ),
        VerdictType.notYetAnalysed => (
            'Not Yet Analysed',
            const Color(0xFFEAE7E2),
            const Color(0xFF5A6A5E),
          ),
      };
}
