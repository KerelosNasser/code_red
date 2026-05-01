import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/timer_provider.dart';
import '../providers/presets_provider.dart';
import '../models/timer_preset.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dara_app_bar.dart';
import '../../../core/utils/responsive_utils.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);
    final presets = ref.watch(timerPresetsProvider);

    final displayColor = timerState.isCritical
        ? AppColors.timerCritical
        : timerState.isWarning
        ? AppColors.timerWarning
        : AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DaraAppBar(
        title: 'TIMER',
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded),
            tooltip: 'Fullscreen mode',
            onPressed: () => context.push('/timer/fullscreen'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Main Timer Display ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _TimerDisplay(
                    state: timerState,
                    color: displayColor,
                    onModeChanged: notifier.setMode,
                  ),
                  const SizedBox(height: 8),
                  if (timerState.presetLabel != null)
                    Text(
                      timerState.presetLabel!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: displayColor,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(),
                  const SizedBox(height: 24),
                  // ── Presets (countdown only) ──────────────────────────
                  if (timerState.mode == TimerMode.countdown ||
                      timerState.mode == TimerMode.preService) ...[
                    if (timerState.mode == TimerMode.countdown)
                      _PresetsPanel(
                        presets: presets,
                        activeSeconds:
                            timerState.durationRemaining ==
                                timerState.totalDuration
                            ? timerState.totalDuration
                            : -1,
                        onSelect: (p) =>
                            notifier.setPreset(p.seconds, label: p.label),
                        notifier: ref.read(timerPresetsProvider.notifier),
                      ),
                    if (timerState.mode == TimerMode.preService)
                      _PreServicePicker(
                        current: timerState.preServiceTarget,
                        onPick: notifier.setPreServiceTarget,
                      ),
                    const SizedBox(height: 24),
                  ],
                  // ── Controls ─────────────────────────────────────────
                  if (timerState.mode != TimerMode.clock)
                    _Controls(state: timerState, notifier: notifier),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer Display (circular arc + digits)
// ─────────────────────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final TimerState state;
  final Color color;
  final ValueChanged<TimerMode> onModeChanged;

  const _TimerDisplay({
    required this.state,
    required this.color,
    required this.onModeChanged,
  });

  String _formatDuration(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _displayText {
    return switch (state.mode) {
      TimerMode.countdown => _formatDuration(state.durationRemaining),
      TimerMode.stopwatch => _formatDuration(state.elapsed),
      TimerMode.clock => _formatClock(state.clockNow),
      TimerMode.preService => _formatDuration(state.durationRemaining),
    };
  }

  String _formatClock(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m:$s $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final showArc =
        state.mode == TimerMode.countdown || state.mode == TimerMode.preService;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure the timer fits on smaller screens
        final maxAllowed = context.isSmallPhone
            ? context.screenWidth - 32
            : 320.0;
        final maxSize = constraints.maxWidth < maxAllowed
            ? constraints.maxWidth
            : maxAllowed;
        final arcSize =
            maxSize *
            0.75; // Timer arc is 75% of the total area to leave room for buttons

        return Center(
          child: SizedBox(
            width: maxSize,
            height: maxSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showArc)
                  SizedBox(
                    width: arcSize,
                    height: arcSize,
                    child: AnimatedBuilder(
                      animation: const AlwaysStoppedAnimation(0),
                      builder: (_, __) => CustomPaint(
                        painter: _ArcPainter(
                          progress: state.progress,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(showArc ? 30 : 0),
                  child:
                      Text(
                            _displayText,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: state.mode == TimerMode.clock
                                  ? maxSize * 0.13
                                  : maxSize * 0.16,
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          )
                          .animate(key: ValueKey(state.isCritical))
                          .then()
                          .shimmer(
                            duration: state.isCritical ? 800.ms : 0.ms,
                            color: state.isCritical
                                ? AppColors.timerCritical.withValues(alpha: 0.6)
                                : Colors.transparent,
                          ),
                ),
                if (state.status == TimerStateStatus.finished)
                  Positioned(
                    bottom: maxSize * 0.15,
                    child: Text(
                      '✓ TIME\'S UP',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.timerCritical,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn().scale(),
                  ),
                // Mode Floating Buttons
                _buildModeButton(
                  context,
                  TimerMode.countdown,
                  const Alignment(-0.95, -0.95),
                  Icons.timer_outlined,
                  'Countdown',
                ),
                _buildModeButton(
                  context,
                  TimerMode.stopwatch,
                  const Alignment(0.95, -0.95),
                  Icons.av_timer_rounded,
                  'Stopwatch',
                ),
                _buildModeButton(
                  context,
                  TimerMode.clock,
                  const Alignment(-0.95, 0.95),
                  Icons.access_time_rounded,
                  'Clock',
                ),
                _buildModeButton(
                  context,
                  TimerMode.preService,
                  const Alignment(0.95, 0.95),
                  Icons.alarm_rounded,
                  'Pre-Service',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    TimerMode mode,
    Alignment alignment,
    IconData icon,
    String tooltip,
  ) {
    final isActive = state.mode == mode;
    return Align(
      alignment: alignment,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () => onModeChanged(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
                  ? const LinearGradient(
                      colors: [
                        AppColors.secondaryGold,
                        AppColors.secondaryGoldDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isActive ? null : AppColors.cardBg,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.secondaryGold.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppColors.primaryBlueDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const startAngle = -1.5707963267948966; // -π/2 (12 o'clock)

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progress * 2 * 3.141592653589793,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Presets Panel
// ─────────────────────────────────────────────────────────────────────────────

class _PresetsPanel extends StatelessWidget {
  final List<TimerPreset> presets;
  final int activeSeconds;
  final ValueChanged<TimerPreset> onSelect;
  final TimerPresetsNotifier notifier;

  const _PresetsPanel({
    required this.presets,
    required this.activeSeconds,
    required this.onSelect,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('PRESETS', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlueDark,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: presets.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final selected = p.seconds == activeSeconds;
            return InputChip(
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.surface
                          : AppColors.primaryBlueDark,
                    ),
                  ),
                  Text(
                    p.formattedDuration,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? AppColors.surface
                          : AppColors.accentMaroon,
                    ),
                  ),
                ],
              ),
              selected: selected,
              showCheckmark: false,
              onPressed: () => onSelect(p),
              onDeleted: p.isDefault ? null : () => notifier.deletePreset(i),
              backgroundColor: AppColors.cardBg,
              selectedColor: AppColors.secondaryGoldDark,
              side: BorderSide(
                color: selected
                    ? AppColors.textSecondary
                    : AppColors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final minsCtrl = TextEditingController();
    final secsCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('New Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: secsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Seconds'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final mins = int.tryParse(minsCtrl.text) ?? 0;
              final secs = int.tryParse(secsCtrl.text) ?? 0;
              final total = mins * 60 + secs;
              if (labelCtrl.text.isNotEmpty && total > 0) {
                notifier.addPreset(
                  TimerPreset(label: labelCtrl.text, seconds: total),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pre-Service Time Picker
// ─────────────────────────────────────────────────────────────────────────────

class _PreServicePicker extends StatelessWidget {
  final DateTime? current;
  final ValueChanged<DateTime> onPick;

  const _PreServicePicker({this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final label = current == null
        ? 'Tap to set service start time'
        : 'Service starts at ${_format(current!)}';

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: current != null
              ? TimeOfDay.fromDateTime(current!)
              : TimeOfDay.now(),
        );
        if (picked != null) {
          final now = DateTime.now();
          var target = DateTime(
            now.year,
            now.month,
            now.day,
            picked.hour,
            picked.minute,
          );
          if (target.isBefore(now)) {
            target = target.add(const Duration(days: 1));
          }
          onPick(target);
        }
      },
      icon: const Icon(Icons.alarm_rounded),
      label: Text(label),
    );
  }

  String _format(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controls
// ─────────────────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final TimerState state;
  final TimerNotifier notifier;

  const _Controls({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isRunning = state.status == TimerStateStatus.running;
    final isStopwatch = state.mode == TimerMode.stopwatch;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play / Pause
        IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                colors: isRunning
                    ? [
                        AppColors.timerWarning,
                        AppColors.timerWarning.withValues(alpha: 0.8),
                      ]
                    : [AppColors.secondaryGold, AppColors.secondaryGoldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isRunning
                              ? AppColors.timerWarning
                              : AppColors.secondaryGold)
                          .withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isRunning ? notifier.pause : notifier.start,
                borderRadius: BorderRadius.circular(32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRunning ? 'PAUSE' : 'START',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Reset (show for all except clock)
        IconButton.filledTonal(
          onPressed: notifier.reset,
          icon: const Icon(Icons.refresh_rounded),
          padding: const EdgeInsets.all(16),
          tooltip: isStopwatch ? 'Reset to 0' : 'Reset',
        ),
      ],
    );
  }
}
