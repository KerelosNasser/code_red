import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/timer_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen timer overlay — covers nav bar, cannot be escaped accidentally.
/// Long-press anywhere or tap the exit button → confirmation dialog.
class FullscreenTimerScreen extends ConsumerStatefulWidget {
  const FullscreenTimerScreen({super.key});

  @override
  ConsumerState<FullscreenTimerScreen> createState() =>
      _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends ConsumerState<FullscreenTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    // Force landscape-preferred or keep portrait full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _tryExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.primaryBlueDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit Fullscreen?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'The timer will continue running in the background.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryGold,
              foregroundColor: AppColors.primaryBlueDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text(
              'Exit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    final isRunning = state.status == TimerStateStatus.running;
    final isCritical = state.isCritical;
    final isWarning = state.isWarning;
    final isFinished = state.status == TimerStateStatus.finished;

    final Color displayColor = isCritical
        ? AppColors.timerCritical
        : isWarning
        ? AppColors.timerWarning
        : Colors.white;

    return PopScope(
      canPop: false, // Prevent accidental back navigation
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onLongPress: _tryExit,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Premium Background Glow ────────────────────────────────
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final intensity = isCritical
                      ? 0.3 + (_pulseCtrl.value * 0.2)
                      : isWarning
                      ? 0.15
                      : 0.08;

                  final glowColor = isCritical
                      ? AppColors.timerCritical
                      : isWarning
                      ? AppColors.timerWarning
                      : AppColors.primaryBlue;

                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          glowColor.withValues(alpha: intensity),
                          Colors.black,
                        ],
                        radius: 1.5,
                        center: Alignment.center,
                      ),
                    ),
                  );
                },
              ),

              // ── Main content ───────────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    children: [
                      // Mode label & preset
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _modeLabel(state.mode),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (state.presetLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.presetLabel!.toUpperCase(),
                                style: TextStyle(
                                  color: displayColor.withValues(alpha: 0.9),
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const Spacer(),

                      // Giant digit display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize:
                                  220, // Large base size for FittedBox to scale safely
                              fontWeight: FontWeight.bold,
                              color: displayColor,
                              height: 1.0,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              shadows: [
                                Shadow(
                                  color: displayColor.withValues(
                                    alpha: isCritical ? 0.6 : 0.2,
                                  ),
                                  blurRadius: isCritical ? 24 : 12,
                                ),
                              ],
                            ),
                            child: Text(_displayText(state))
                                .animate(
                                  key: ValueKey(isCritical),
                                  autoPlay: isCritical,
                                )
                                .then()
                                .shimmer(
                                  duration: isCritical ? 800.ms : 0.ms,
                                  color: isCritical
                                      ? AppColors.timerCritical.withValues(
                                          alpha: 0.5,
                                        )
                                      : Colors.transparent,
                                ),
                          ),
                        ),
                      ),

                      if (isFinished) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'TIME\'S UP',
                          style: TextStyle(
                            color: AppColors.timerCritical,
                            fontSize: 24,
                            letterSpacing: 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn().scale().shimmer(delay: 400.ms),
                      ],

                      const Spacer(),

                      // ── Controls ─────────────────────────────────────────
                      if (state.mode != TimerMode.clock)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FsButton(
                              icon: Icons.refresh_rounded,
                              color: Colors.white70,
                              onTap: notifier.reset,
                              size: 56,
                            ),
                            const SizedBox(width: 32),
                            _FsButton(
                              icon: isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isRunning
                                  ? AppColors.timerWarning
                                  : AppColors.secondaryGold,
                              onTap: isRunning
                                  ? notifier.pause
                                  : notifier.start,
                              size: 80,
                              isPrimary: true,
                            ),
                            const SizedBox(width: 32),
                            const SizedBox(width: 56), // Visual balance
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // ── Subtle exit button (top-right) ─────────────────────────
              Positioned(
                top: MediaQuery.paddingOf(context).top + 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white54,
                    size: 32,
                  ),
                  onPressed: _tryExit,
                  tooltip: 'Exit Fullscreen',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _modeLabel(TimerMode mode) => switch (mode) {
    TimerMode.countdown => 'COUNTDOWN',
    TimerMode.stopwatch => 'STOPWATCH',
    TimerMode.clock => 'CURRENT TIME',
    TimerMode.preService => 'SERVICE STARTS IN',
  };

  String _displayText(TimerState state) {
    return switch (state.mode) {
      TimerMode.countdown => _fmt(state.durationRemaining),
      TimerMode.stopwatch => _fmt(state.elapsed),
      TimerMode.clock => _clock(state.clockNow),
      TimerMode.preService => _fmt(state.durationRemaining),
    };
  }

  String _fmt(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _clock(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m:$s $ampm';
  }
}

class _FsButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final bool isPrimary;

  const _FsButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 64,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: isPrimary ? 0.2 : 0.1),
          border: Border.all(
            color: color.withValues(alpha: isPrimary ? 0.8 : 0.4),
            width: isPrimary ? 2.5 : 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}
