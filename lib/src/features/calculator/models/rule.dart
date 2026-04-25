enum RuleType { counter, toggle, selection }

class GameRule {
  final String id;
  final String label;
  final int pointsPerUnit;
  final RuleType type;
  final int maxValue;

  GameRule({
    required this.id,
    required this.label,
    required this.pointsPerUnit,
    this.type = RuleType.counter,
    this.maxValue = 99,
  });
}

class GamePhase {
  final String title;
  final List<GameRule> rules;

  GamePhase({required this.title, required this.rules});
}
