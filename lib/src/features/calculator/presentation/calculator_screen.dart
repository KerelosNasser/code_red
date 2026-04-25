import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/calculator_provider.dart';
import '../data/game_rules.dart';
import '../models/rule.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final totalScore = notifier.totalScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.reset(),
          ).animate(key: const ValueKey('refresh_btn')).rotate(duration: 500.ms),
        ],
      ),
      body: Column(
        children: [
          _ScoreSummary(totalScore: totalScore),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daraGamePhases.length,
              itemBuilder: (context, index) {
                final phase = daraGamePhases[index];
                return _PhaseSection(
                  key: ValueKey('phase_${phase.title}'),
                  phase: phase,
                  scores: scores,
                  notifier: notifier,
                )
                    .animate(key: ValueKey('phase_anim_${phase.title}'))
                    .fadeIn(delay: (100 * index).ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  final int totalScore;

  const _ScoreSummary({super.key, required this.totalScore});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL SCORE',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalScore',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
          ).animate(key: ValueKey('score_text_$totalScore')).scale(duration: 200.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  final GamePhase phase;
  final Map<String, int> scores;
  final dynamic notifier;

  const _PhaseSection({
    super.key,
    required this.phase,
    required this.scores,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            phase.title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        ...phase.rules.map((rule) => _RuleItem(
              key: ValueKey(rule.id),
              rule: rule,
              value: scores[rule.id] ?? 0,
              onChanged: (delta) => notifier.updateScore(rule.id, delta),
            )),
        const Divider(height: 32),
      ],
    );
  }
}

class _RuleItem extends StatelessWidget {
  final GameRule rule;
  final int value;
  final Function(int) onChanged;

  const _RuleItem({
    super.key,
    required this.rule,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${rule.pointsPerUnit} points per unit',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (rule.type == RuleType.counter)
                Row(
                  children: [
                    _ControlBtn(
                      icon: Icons.remove,
                      onPressed: value > 0 ? () => onChanged(-1) : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _ControlBtn(
                      icon: Icons.add,
                      onPressed: value < rule.maxValue ? () => onChanged(1) : null,
                    ),
                  ],
                )
              else if (rule.type == RuleType.toggle)
                Switch(
                  value: value > 0,
                  onChanged: (val) => onChanged(val ? 1 : -1),
                  activeColor: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _ControlBtn({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        foregroundColor: Theme.of(context).primaryColor,
        disabledBackgroundColor: Colors.grey[100],
        disabledForegroundColor: Colors.grey[400],
      ),
    );
  }
}
