/// A named timer preset (label + duration) persisted to Hive.
class TimerPreset {
  final String label;
  final int seconds;
  final bool isDefault;

  const TimerPreset({
    required this.label,
    required this.seconds,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'seconds': seconds,
        'isDefault': isDefault,
      };

  factory TimerPreset.fromMap(Map<String, dynamic> map) => TimerPreset(
        label: map['label'] as String,
        seconds: map['seconds'] as int,
        isDefault: (map['isDefault'] as bool?) ?? false,
      );

  TimerPreset copyWith({String? label, int? seconds, bool? isDefault}) =>
      TimerPreset(
        label: label ?? this.label,
        seconds: seconds ?? this.seconds,
        isDefault: isDefault ?? this.isDefault,
      );

  String get formattedDuration {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}

/// Church-specific default presets loaded on first run.
const List<TimerPreset> kDefaultPresets = [
  TimerPreset(label: 'Worship Set', seconds: 1500, isDefault: true),  // 25 min
  TimerPreset(label: 'Message', seconds: 2700, isDefault: true),       // 45 min
  TimerPreset(label: 'Offering', seconds: 300, isDefault: true),       // 5 min
  TimerPreset(label: 'Announcements', seconds: 180, isDefault: true),  // 3 min
  TimerPreset(label: 'Prayer Time', seconds: 600, isDefault: true),    // 10 min
  TimerPreset(label: 'Short Break', seconds: 600, isDefault: true),    // 10 min
];
