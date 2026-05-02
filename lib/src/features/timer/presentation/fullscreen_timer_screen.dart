import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/timer_provider.dart';
import '../../../core/theme/app_colors.dart';

class FullscreenTimerScreen extends ConsumerStatefulWidget {
  const FullscreenTimerScreen({super.key});

  @override
  ConsumerState<FullscreenTimerScreen> createState() =>
      _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends ConsumerState<FullscreenTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _bgCtrl.dispose();
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

  String _formatDuration(int secs) {
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    final isRunning = state.status == TimerStateStatus.running;
    final displayColor = state.isCritical
        ? AppColors.timerCritical
        : state.isWarning
        ? AppColors.timerWarning
        : Colors.white;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onLongPress: _tryExit,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Animated Background Glow ───────────────────────────────
              AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          displayColor.withValues(
                            alpha: 0.15 + (_bgCtrl.value * 0.1),
                          ),
                          Colors.black,
                        ],
                        radius: 1.2 + (_bgCtrl.value * 0.4),
                        center: Alignment.center,
                      ),
                    ),
                  );
                },
              ),

              // ── Particles / Dust Effect ────────────────────────────────
              const Positioned.fill(
                child: IgnorePointer(child: _ParticlesOverlay()),
              ),

              // ── Main Content ───────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),

                    // Progress Ring (Subtle behind digits)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.width * 0.85,
                              child: CircularProgressIndicator(
                                value: state.progress,
                                strokeWidth: 10,
                                color: displayColor.withValues(alpha: 0.6),
                                backgroundColor: Colors.white10,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(duration: 3.seconds),

                        // Gigantic Timer Text
                        Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: FittedBox(
                                child: Hero(
                                  tag: 'timer_text',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      _formatDuration(state.durationRemaining),
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 100,
                                        fontWeight: FontWeight.bold,
                                        color: displayColor,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        shadows: [
                                          Shadow(
                                            color: displayColor.withValues(
                                              alpha: 0.6,
                                            ),
                                            blurRadius: 50,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate(target: state.isCritical ? 1 : 0)
                            .shimmer(duration: 800.ms, color: Colors.white24),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (state.status == TimerStateStatus.finished)
                      const Text(
                        'TIME\'S UP',
                        style: TextStyle(
                          color: AppColors.timerCritical,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 12,
                        ),
                      ).animate().fadeIn().scale().shimmer(duration: 2.seconds)
                    else
                      Text(
                        isRunning ? 'RUNNING' : 'PAUSED',
                        style: TextStyle(
                          color: displayColor.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                    const Spacer(),

                    // ── Subtle Controls ──────────────────────────────────
                    Padding(
                          padding: const EdgeInsets.only(bottom: 85),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SubtleFsButton(
                                onTap: notifier.reset,
                                icon: Icons.replay_rounded,
                                color: Colors.white24,
                              ),
                              const SizedBox(width: 60),
                              _SubtleFsButton(
                                onTap: isRunning
                                    ? notifier.pause
                                    : notifier.start,
                                icon: isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: isRunning
                                    ? AppColors.timerWarning
                                    : AppColors.secondaryGold,
                                isLarge: true,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),

              // Exit button
              Positioned(
                top: 30,
                right: 30,
                child: IconButton(
                  icon: const Icon(
                    Icons.fullscreen_exit_rounded,
                    color: Colors.white24,
                    size: 32,
                  ),
                  onPressed: _tryExit,
                ),
              ).animate().fadeIn(delay: 1.2.seconds),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticlesOverlay extends StatelessWidget {
  const _ParticlesOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(15, (i) {
        final random = (i * 137) % 1000 / 1000;
        return Positioned(
          left: (i * 73) % MediaQuery.of(context).size.width,
          top: (i * 149) % MediaQuery.of(context).size.height,
          child:
              Container(
                    width: 2 + (random * 4),
                    height: 2 + (random * 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.1 + (random * 0.2),
                      ),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(
                    begin: 0,
                    end: -100 - (random * 200),
                    duration: (5 + (random * 5)).seconds,
                    curve: Curves.linear,
                  )
                  .fadeOut(),
        );
      }),
    );
  }
}

class _SubtleFsButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _SubtleFsButton({
    required this.onTap,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            if (isLarge)
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Icon(icon, color: color, size: isLarge ? 50 : 32),
      ),
    );
  }
}
