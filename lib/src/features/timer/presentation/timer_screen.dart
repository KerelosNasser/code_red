import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/timer_provider.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    String formatDuration(int totalSeconds) {
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Timer'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          final isShort = constraints.maxHeight < 400;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 16 : 32,
                vertical: isShort ? 8 : 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section
                    Text(
                      'MATCH TIME',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 2,
                            color: Colors.grey[600],
                          ),
                    ).animate().fadeIn(),

                    // Timer Section - Responsive font size
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: isShort ? 4 : 16),
                      child: Text(
                        formatDuration(timerState.durationRemaining),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: isShort ? 60 : (isNarrow ? 80 : 120),
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                      ),
                    ),

                    // Presets Section - Flexible layout
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _PresetBtn(
                          label: '2:30',
                          onPressed: () => notifier.setPreset(150),
                          selected: timerState.durationRemaining == 150,
                        ),
                        _PresetBtn(
                          label: '2:00',
                          onPressed: () => notifier.setPreset(120),
                          selected: timerState.durationRemaining == 120,
                        ),
                        _PresetBtn(
                          label: '0:30',
                          onPressed: () => notifier.setPreset(30),
                          selected: timerState.durationRemaining == 30,
                        ),
                      ],
                    ),

                    SizedBox(height: isShort ? 16 : 40),

                    // Controls Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MainActionBtn(
                          isRunning: timerState.status == TimerStateStatus.running,
                          onPressed: timerState.status == TimerStateStatus.running
                              ? notifier.pause
                              : notifier.start,
                        ),
                        const SizedBox(width: 24),
                        IconButton.filledTonal(
                          onPressed: notifier.reset,
                          icon: const Icon(Icons.refresh_rounded),
                          padding: const EdgeInsets.all(16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PresetBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  const _PresetBtn({
    required this.label,
    required this.onPressed,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
      showCheckmark: false,
    );
  }
}

class _MainActionBtn extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onPressed;

  const _MainActionBtn({required this.isRunning, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isRunning ? Colors.orange : null,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      ),
      icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
      label: Text(isRunning ? 'PAUSE' : 'START'),
    );
  }
}
