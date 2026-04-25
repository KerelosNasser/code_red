import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'calculator_provider.g.dart';

@riverpod
class Calculator extends _$Calculator {
  @override
  Map<String, int> build() => {};

  void updateScore(String ruleId, int delta) {
    state = {...state, ruleId: (state[ruleId] ?? 0) + delta};
  }

  int get totalScore {
    // Logic to multiply state values by Rule points
    return 0; // Simplified for plan
  }
}
