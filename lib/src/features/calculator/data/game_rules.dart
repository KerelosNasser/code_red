import '../models/rule.dart';

final List<GamePhase> daraGamePhases = [
  GamePhase(
    title: 'Autonomous Phase',
    rules: [
      GameRule(id: 'auto_high_goal', label: 'High Goal', pointsPerUnit: 6),
      GameRule(id: 'auto_low_goal', label: 'Low Goal', pointsPerUnit: 2),
      GameRule(id: 'auto_mobility', label: 'Mobility (Exit Zone)', pointsPerUnit: 3, type: RuleType.toggle),
    ],
  ),
  GamePhase(
    title: 'Teleop Phase',
    rules: [
      GameRule(id: 'tele_high_goal', label: 'High Goal', pointsPerUnit: 3),
      GameRule(id: 'tele_low_goal', label: 'Low Goal', pointsPerUnit: 1),
    ],
  ),
  GamePhase(
    title: 'Endgame',
    rules: [
      GameRule(id: 'climb_level_1', label: 'Climb Level 1', pointsPerUnit: 5, type: RuleType.toggle),
      GameRule(id: 'climb_level_2', label: 'Climb Level 2', pointsPerUnit: 10, type: RuleType.toggle),
      GameRule(id: 'climb_level_3', label: 'Climb Level 3', pointsPerUnit: 15, type: RuleType.toggle),
    ],
  ),
];
