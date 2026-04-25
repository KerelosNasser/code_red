import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_provider.g.dart';

enum TimerStateStatus { initial, running, paused, finished }

class TimerState {
  final int durationRemaining;
  final TimerStateStatus status;

  const TimerState({
    required this.durationRemaining,
    required this.status,
  });

  TimerState copyWith({
    int? durationRemaining,
    TimerStateStatus? status,
  }) {
    return TimerState(
      durationRemaining: durationRemaining ?? this.durationRemaining,
      status: status ?? this.status,
    );
  }
}

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;
  int _initialDuration = 150; // 2:30 default

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return TimerState(
      durationRemaining: _initialDuration,
      status: TimerStateStatus.initial,
    );
  }

  void start() {
    if (state.status == TimerStateStatus.running) return;

    if (state.status == TimerStateStatus.initial || state.status == TimerStateStatus.finished) {
      state = state.copyWith(
        durationRemaining: _initialDuration,
        status: TimerStateStatus.running,
      );
    } else if (state.status == TimerStateStatus.paused) {
      state = state.copyWith(status: TimerStateStatus.running);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.durationRemaining > 0) {
        state = state.copyWith(durationRemaining: state.durationRemaining - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(status: TimerStateStatus.finished);
      }
    });
  }

  void pause() {
    if (state.status == TimerStateStatus.running) {
      _timer?.cancel();
      state = state.copyWith(status: TimerStateStatus.paused);
    }
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(
      durationRemaining: _initialDuration,
      status: TimerStateStatus.initial,
    );
  }

  void setPreset(int seconds) {
    _initialDuration = seconds;
    _timer?.cancel();
    state = TimerState(
      durationRemaining: seconds,
      status: TimerStateStatus.initial,
    );
  }
}
