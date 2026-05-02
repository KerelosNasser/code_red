import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:audioplayers/audioplayers.dart';

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
  static const int _defaultDuration = 600; // 10 minutes static duration
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _lastPlayedSecond;

  // High-quality Remote Sound URLs
  static const String _warningUrl = 'https://assets.mixkit.co/sfx/preview/mixkit-software-interface-start-2574.mp3';
  static const String _finishedUrl = 'https://assets.mixkit.co/sfx/preview/mixkit-game-success-alert-2039.mp3';

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _audioPlayer.dispose();
    });
    return TimerState(
      mode: TimerMode.countdown,
      status: TimerStateStatus.initial,
      durationRemaining: _defaultDuration,
      totalDuration: _defaultDuration,
      elapsed: 0,
      clockNow: DateTime.now(),
    );
  }

  // ── Mode switching ─────────────────────────────────────────────────────────

  void setMode(TimerMode mode) {
    reset();
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  void start() {
    if (state.status == TimerStateStatus.running) return;
    _startCountdown();
  }

  void pause() {
    if (state.status != TimerStateStatus.running) return;
    _timer?.cancel();
    state = state.copyWith(status: TimerStateStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    _lastPlayedSecond = null;
    state = TimerState(
      mode: TimerMode.countdown,
      status: TimerStateStatus.initial,
      durationRemaining: _defaultDuration,
      totalDuration: _defaultDuration,
      elapsed: 0,
      clockNow: DateTime.now(),
    );
  }

  // ── Private tick implementations ───────────────────────────────────────────

  void _startCountdown() {
    final resuming = state.status == TimerStateStatus.paused;
    state = state.copyWith(
      status: TimerStateStatus.running,
      durationRemaining: resuming ? state.durationRemaining : _defaultDuration,
      totalDuration: resuming ? state.totalDuration : _defaultDuration,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.durationRemaining > 0) {
        final nextValue = state.durationRemaining - 1;
        
        // ── Sound Triggers ─────────────────────────────────────────────────
        if (nextValue == 60 && _lastPlayedSecond != 60) {
          _playSound(_warningUrl); 
          _lastPlayedSecond = 60;
        }

        state = state.copyWith(
          durationRemaining: nextValue,
          clockNow: DateTime.now(),
        );
      } else {
        _timer?.cancel();
        if (_lastPlayedSecond != 0) {
          _playSound(_finishedUrl);
          _lastPlayedSecond = 0;
        }
        state = state.copyWith(
          durationRemaining: 0,
          status: TimerStateStatus.finished,
          clockNow: DateTime.now(),
        );
      }
    });
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      // Silently fail if audio play fails
    }
  }

  // ── Other modes (Unused in simplified version) ───────────────────────────

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
}
