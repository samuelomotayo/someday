enum VerdictType {
  secondChance,
  sunsetConfirmed,
  needsMoreContext,
  notYetAnalysed;

  bool get isAnalysed => this != VerdictType.notYetAnalysed;

  String get label => switch (this) {
        VerdictType.secondChance => 'Second Chance',
        VerdictType.sunsetConfirmed => 'Sunset Confirmed',
        VerdictType.needsMoreContext => 'Needs More Context',
        VerdictType.notYetAnalysed => 'Not Yet Analysed',
      };

  static VerdictType fromApiString(String value) => switch (value) {
        'second_chance' => VerdictType.secondChance,
        'sunset_confirmed' => VerdictType.sunsetConfirmed,
        'needs_more_context' => VerdictType.needsMoreContext,
        _ => VerdictType.notYetAnalysed,
      };
}
