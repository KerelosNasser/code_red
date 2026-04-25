import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/game_rules.dart';
import '../models/rule.dart';
part 'calculator_provider.g.dart';

@riverpod
class Calculator extends _$Calculator {
  @override
  Map<String, int> build() => {};

  void updateScore(String ruleId, int delta) {
    final currentValue = state[ruleId] ?? 0;
    final newValue = currentValue + delta;
    
    // Find the rule to check maxValue
    GameRule? rule;
    for (var phase in daraGamePhases) {
      for (var r in phase.rules) {
        if (r.id == ruleId) {
          rule = r;
          break;
        }
      }
    }

    if (rule != null) {
      if (rule.type == RuleType.toggle) {
        state = {...state, ruleId: delta > 0 ? 1 : 0};
        return;
      }
      
      if (newValue >= 0 && newValue <= rule.maxValue) {
        state = {...state, ruleId: newValue};
      }
    } else {
      state = {...state, ruleId: newValue >= 0 ? newValue : 0};
    }
  }

  void reset() {
    state = {};
  }

  int get totalScore {
    int total = 0;
    for (var phase in daraGamePhases) {
      for (var rule in phase.rules) {
        final value = state[rule.id] ?? 0;
        total += value * rule.pointsPerUnit;
      }
    }
    return total;
  }
}
