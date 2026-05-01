import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum TimerMode {
  countdown,   // Count down from a preset duration
  stopwatch,   // Count up from zero
  clock,       // Display current wall-clock time
  preService,  // Countdown to a specific target time of day
}

enum TimerStateStatus { initial, running, paused, finished }

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class TimerState {
  final TimerMode mode;
  final TimerStateStatus status;

  /// Seconds remaining (countdown / preService modes).
  final int durationRemaining;

  /// Original full duration — used for circular progress calculation.
  final int totalDuration;

  /// Elapsed seconds (stopwatch mode).
  final int elapsed;

  /// Current wall-clock snapshot — updated every second in all modes.
  final DateTime clockNow;

  /// Target wall-clock time for preService mode.
  final DateTime? preServiceTarget;

  /// Label from the selected preset, if any.
  final String? presetLabel;

  const TimerState({
    required this.mode,
    required this.status,
    required this.durationRemaining,
    required this.totalDuration,
    required this.elapsed,
    required this.clockNow,
    this.preServiceTarget,
    this.presetLabel,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Progress 1.0→0.0 for circular countdown arc.
  double get progress =>
      totalDuration > 0 ? (durationRemaining / totalDuration).clamp(0.0, 1.0) : 0.0;

  /// True when ≤ 5 min remain (countdown / preService only).
  bool get isWarning =>
      (mode == TimerMode.countdown || mode == TimerMode.preService) &&
      status == TimerStateStatus.running &&
      durationRemaining <= 300 &&
      durationRemaining > 60;

  /// True when ≤ 1 min remain (countdown / preService only).
  bool get isCritical =>
      (mode == TimerMode.countdown || mode == TimerMode.preService) &&
      status == TimerStateStatus.running &&
      durationRemaining > 0 &&
      durationRemaining <= 60;

  TimerState copyWith({
    TimerMode? mode,
    TimerStateStatus? status,
    int? durationRemaining,
    int? totalDuration,
    int? elapsed,
    DateTime? clockNow,
    DateTime? preServiceTarget,
    String? presetLabel,
    bool clearPresetLabel = false,
    bool clearTarget = false,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      durationRemaining: durationRemaining ?? this.durationRemaining,
      totalDuration: totalDuration ?? this.totalDuration,
      elapsed: elapsed ?? this.elapsed,
      clockNow: clockNow ?? this.clockNow,
      preServiceTarget: clearTarget ? null : (preServiceTarget ?? this.preServiceTarget),
      presetLabel: clearPresetLabel ? null : (presetLabel ?? this.presetLabel),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;
  int _initialDuration = 150; // default 2:30

  @override
  TimerState build() {
    ref.onDispose(() => _timer?.cancel());
    return TimerState(
      mode: TimerMode.countdown,
      status: TimerStateStatus.initial,
      durationRemaining: _initialDuration,
      totalDuration: _initialDuration,
      elapsed: 0,
      clockNow: DateTime.now(),
    );
  }

  // ── Mode switching ─────────────────────────────────────────────────────────

  void setMode(TimerMode mode) {
    _timer?.cancel();
    _initialDuration = 150;
    state = TimerState(
      mode: mode,
      status: TimerStateStatus.initial,
      durationRemaining: _initialDuration,
      totalDuration: _initialDuration,
      elapsed: 0,
      clockNow: DateTime.now(),
    );
    // Clock mode auto-starts ticking immediately
    if (mode == TimerMode.clock) _startClockTick();
  }

  // ── Preset loading ─────────────────────────────────────────────────────────

  void setPreset(int seconds, {String? label}) {
    _timer?.cancel();
    _initialDuration = seconds;
    state = TimerState(
      mode: state.mode == TimerMode.stopwatch ? TimerMode.countdown : state.mode,
      status: TimerStateStatus.initial,
      durationRemaining: seconds,
      totalDuration: seconds,
      elapsed: 0,
      clockNow: DateTime.now(),
      presetLabel: label,
    );
  }

  // ── Pre-service target ─────────────────────────────────────────────────────

  void setPreServiceTarget(DateTime target) {
    _timer?.cancel();
    final remaining = target.difference(DateTime.now()).inSeconds;
    state = state.copyWith(
      mode: TimerMode.preService,
      status: TimerStateStatus.initial,
      preServiceTarget: target,
      durationRemaining: remaining.clamp(0, 86400),
      totalDuration: remaining.clamp(0, 86400),
      elapsed: 0,
    );
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  void start() {
    if (state.status == TimerStateStatus.running) return;

    switch (state.mode) {
      case TimerMode.countdown:
        _startCountdown();
      case TimerMode.stopwatch:
        _startStopwatch();
      case TimerMode.clock:
        _startClockTick();
      case TimerMode.preService:
        _startPreService();
    }
  }

  void pause() {
    if (state.status != TimerStateStatus.running) return;
    _timer?.cancel();
    state = state.copyWith(status: TimerStateStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(
      mode: state.mode,
      status: state.mode == TimerMode.clock
          ? TimerStateStatus.running
          : TimerStateStatus.initial,
      durationRemaining: _initialDuration,
      totalDuration: _initialDuration,
      elapsed: 0,
      clockNow: DateTime.now(),
      preServiceTarget: state.preServiceTarget,
      presetLabel: state.presetLabel,
    );
    if (state.mode == TimerMode.clock) _startClockTick();
  }

  // ── Private tick implementations ───────────────────────────────────────────

  void _startCountdown() {
    final resuming = state.status == TimerStateStatus.paused;
    state = state.copyWith(
      status: TimerStateStatus.running,
      durationRemaining: resuming ? state.durationRemaining : _initialDuration,
      totalDuration: resuming ? state.totalDuration : _initialDuration,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.durationRemaining > 0) {
        state = state.copyWith(
          durationRemaining: state.durationRemaining - 1,
          clockNow: DateTime.now(),
        );
      } else {
        _timer?.cancel();
        state = state.copyWith(
          durationRemaining: 0,
          status: TimerStateStatus.finished,
          clockNow: DateTime.now(),
        );
      }
    });
  }

  void _startStopwatch() {
    state = state.copyWith(status: TimerStateStatus.running);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + 1,
        clockNow: DateTime.now(),
      );
    });
  }

  void _startClockTick() {
    state = state.copyWith(
      status: TimerStateStatus.running,
      clockNow: DateTime.now(),
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(clockNow: DateTime.now());
    });
  }

  void _startPreService() {
    final target = state.preServiceTarget;
    if (target == null) return;

    state = state.copyWith(status: TimerStateStatus.running);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = target.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        state = state.copyWith(
          durationRemaining: remaining,
          clockNow: DateTime.now(),
        );
      } else {
        _timer?.cancel();
        state = state.copyWith(
          durationRemaining: 0,
          status: TimerStateStatus.finished,
          clockNow: DateTime.now(),
        );
      }
    });
  }
}
