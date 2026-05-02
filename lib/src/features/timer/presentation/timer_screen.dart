import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/timer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dara_app_bar.dart';
import '../../../core/utils/responsive_utils.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    final displayColor = timerState.isCritical
        ? AppColors.timerCritical
        : timerState.isWarning
        ? AppColors.timerWarning
        : AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DaraAppBar(title: 'TIMER'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // ── Animated Timer Display ───────────────────────────────────
            _AnimatedTimerCircle(state: timerState, color: displayColor),
            const Spacer(),
            // ── Controls ─────────────────────────────────────────────────
            _TimerControls(
              state: timerState,
              notifier: notifier,
              onPlay: () {
                notifier.start();
                context.push('/timer/fullscreen');
              },
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTimerCircle extends StatelessWidget {
  final TimerState state;
  final Color color;

  const _AnimatedTimerCircle({required this.state, required this.color});

  String _formatDuration(int secs) {
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = context.screenWidth * 0.75;

        return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBg,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse effect
                  if (state.status == TimerStateStatus.running)
                    Container(
                          width: size * 0.9,
                          height: size * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          duration: 1500.ms,
                          curve: Curves.easeOut,
                        )
                        .fadeOut(duration: 1500.ms),

                  // Progress Arc
                  SizedBox(
                    width: size * 0.85,
                    height: size * 0.85,
                    child: CircularProgressIndicator(
                      value: state.progress,
                      strokeWidth: 16,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.1),
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                  // Timer Text
                  Hero(
                    tag: 'timer_text',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        _formatDuration(state.durationRemaining),
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: size * 0.22,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(delay: 200.ms, curve: Curves.elasticOut, duration: 800.ms);
      },
    );
  }
}

class _TimerControls extends StatelessWidget {
  final TimerState state;
  final TimerNotifier notifier;
  final VoidCallback onPlay;

  const _TimerControls({
    required this.state,
    required this.notifier,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Repeat Button (Reset)
        _ControlButton(
          onTap: notifier.reset,
          icon: Icons.replay_rounded,
          label: 'REPEAT',
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 40),
        // Play Button
        _ControlButton(
          onTap: onPlay,
          icon: Icons.play_arrow_rounded,
          label: 'PLAY',
          color: AppColors.secondaryGold,
          isPrimary: true,
        ),
      ],
    ).animate().slideY(
      begin: 0.5,
      end: 0,
      duration: 600.ms,
      curve: Curves.easeOut,
    );
  }
}

class _ControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;

  const _ControlButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 80 : 64,
            height: isPrimary ? 80 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? color : AppColors.cardBg,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isPrimary ? 0.4 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
              border: !isPrimary
                  ? Border.all(color: color.withValues(alpha: 0.2), width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: isPrimary ? 40 : 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
