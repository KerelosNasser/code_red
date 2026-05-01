
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/timer_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen timer overlay — covers nav bar, cannot be escaped accidentally.
/// Long-press anywhere or tap the subtle exit button → confirmation dialog.
class FullscreenTimerScreen extends ConsumerStatefulWidget {
  const FullscreenTimerScreen({super.key});

  @override
  ConsumerState<FullscreenTimerScreen> createState() =>
      _FullscreenTimerScreenState();
}

class _FullscreenTimerScreenState extends ConsumerState<FullscreenTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _showExit = false;

  @override
  void initState() {
    super.initState();
    // Force landscape-preferred or keep portrait
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Exit Fullscreen?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'The timer will continue running in the background.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondaryGold,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Exit'),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background glow ────────────────────────────────────────
              if (isCritical)
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.timerCritical
                              .withValues(alpha: 0.15 * _pulseCtrl.value),
                          Colors.transparent,
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),

              // ── Main content ───────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode label
                    Text(
                      _modeLabel(state.mode),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (state.presetLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          state.presetLabel!.toUpperCase(),
                          style: TextStyle(
                            color: displayColor.withValues(alpha: 0.8),
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Giant digit display
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: _fontSize(context),
                        fontWeight: FontWeight.bold,
                        color: displayColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
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
                                ? AppColors.timerCritical.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // ── Minimal controls ───────────────────────────────
                    if (state.mode != TimerMode.clock)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FsButton(
                            icon: isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isRunning
                                ? AppColors.timerWarning
                                : AppColors.secondaryGold,
                            onTap: isRunning ? notifier.pause : notifier.start,
                          ),
                          const SizedBox(width: 24),
                          _FsButton(
                            icon: Icons.refresh_rounded,
                            color: Colors.white38,
                            onTap: notifier.reset,
                          ),
                        ],
                      ),

                    if (isFinished) ...[
                      const SizedBox(height: 16),
                      Text(
                        '✓ TIME\'S UP',
                        style: TextStyle(
                          color: AppColors.timerCritical,
                          fontSize: 18,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().scale(),
                    ],
                  ],
                ),
              ),

              // ── Subtle exit button (top-right) ─────────────────────────
              Positioned(
                top: 48,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showExit = !_showExit);
                    if (_showExit) {
                      Future.delayed(
                        const Duration(seconds: 4),
                        () => mounted ? setState(() => _showExit = false) : null,
                      );
                    }
                  },
                  child: AnimatedOpacity(
                    opacity: _showExit ? 1.0 : 0.08,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: _showExit ? _tryExit : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fullscreen_exit_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _fontSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w > 600 ? 120 : 80;
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

  const _FsButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
