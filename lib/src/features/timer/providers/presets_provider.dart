import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timer_preset.dart';

const _kBoxKey = 'presets';

class TimerPresetsNotifier extends StateNotifier<List<TimerPreset>> {
  TimerPresetsNotifier() : super([]) {
    _load();
  }

  Box get _box => Hive.box('timerPresets');

  void _load() {
    final raw = _box.get(_kBoxKey);
    if (raw == null || (raw as List).isEmpty) {
      state = kDefaultPresets;
      _persist();
    } else {
      final list = raw;
      state = list
          .map((e) => TimerPreset.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  Future<void> _persist() async {
    await _box.put(_kBoxKey, state.map((p) => p.toMap()).toList());
  }

  Future<void> addPreset(TimerPreset preset) async {
    state = [...state, preset];
    await _persist();
  }

  Future<void> deletePreset(int index) async {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
    await _persist();
  }

  Future<void> updatePreset(int index, TimerPreset preset) async {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated[index] = preset;
    state = updated;
    await _persist();
  }
}

final timerPresetsProvider =
    StateNotifierProvider<TimerPresetsNotifier, List<TimerPreset>>(
  (ref) => TimerPresetsNotifier(),
);
