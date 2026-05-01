import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../timer/providers/timer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

enum SegmentType { worship, message, prayer, offering, announcements, other }

enum SegmentStatus { pending, active, done }

class ServiceSegment {
  final String id;
  String name;
  int durationMinutes;
  SegmentType type;
  SegmentStatus status;

  ServiceSegment({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.type,
    this.status = SegmentStatus.pending,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Default rundown
// ─────────────────────────────────────────────────────────────────────────────

List<ServiceSegment> _defaultRundown() => [
      ServiceSegment(id: '1', name: 'Welcome & Announcements', durationMinutes: 10, type: SegmentType.announcements),
      ServiceSegment(id: '2', name: 'Worship Set', durationMinutes: 25, type: SegmentType.worship),
      ServiceSegment(id: '3', name: 'Offering', durationMinutes: 5, type: SegmentType.offering),
      ServiceSegment(id: '4', name: 'Message', durationMinutes: 45, type: SegmentType.message),
      ServiceSegment(id: '5', name: 'Prayer & Ministry', durationMinutes: 15, type: SegmentType.prayer),
      ServiceSegment(id: '6', name: 'Altar Call', durationMinutes: 10, type: SegmentType.prayer),
      ServiceSegment(id: '7', name: 'Closing Worship', durationMinutes: 10, type: SegmentType.worship),
    ];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late List<ServiceSegment> _segments;

  @override
  void initState() {
    super.initState();
    _segments = _defaultRundown();
  }

  int get _totalMinutes => _segments.fold(0, (sum, s) => sum + s.durationMinutes);

  int get _doneCount => _segments.where((s) => s.status == SegmentStatus.done).length;

  void _advanceStatus(ServiceSegment seg) {
    setState(() {
      switch (seg.status) {
        case SegmentStatus.pending:
          // Mark any currently active as done first
          for (final s in _segments) {
            if (s.status == SegmentStatus.active) s.status = SegmentStatus.done;
          }
          seg.status = SegmentStatus.active;
        case SegmentStatus.active:
          seg.status = SegmentStatus.done;
        case SegmentStatus.done:
          seg.status = SegmentStatus.pending;
      }
    });
  }

  void _launchTimer(ServiceSegment seg) {
    ref.read(timerNotifierProvider.notifier)
        .setPreset(seg.durationMinutes * 60, label: seg.name);
    context.go('/timer');
  }

  void _resetAll() {
    setState(() {
      for (final s in _segments) {
        s.status = SegmentStatus.pending;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service Rundown'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset all',
            onPressed: _resetAll,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add segment',
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary bar ─────────────────────────────────────────────────
          _SummaryBar(
            total: _segments.length,
            done: _doneCount,
            totalMinutes: _totalMinutes,
          ),

          // ── Drag-to-reorder list ────────────────────────────────────────
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _segments.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _segments.removeAt(oldIndex);
                  _segments.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final seg = _segments[index];
                return _SegmentCard(
                  key: ValueKey(seg.id),
                  segment: seg,
                  index: index + 1,
                  onStatusTap: () => _advanceStatus(seg),
                  onLaunchTimer: () => _launchTimer(seg),
                  onDelete: () => setState(() => _segments.removeAt(index)),
                ).animate().fadeIn(delay: (60 * index).ms).slideX(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '10');
    var selectedType = SegmentType.other;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Segment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Segment Name',
                  hintText: 'e.g. Special Song',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SegmentType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: SegmentType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Icon(_iconFor(t), size: 16, color: _colorFor(t)),
                              const SizedBox(width: 8),
                              Text(_labelFor(t)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedType = v!),
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
                final name = nameCtrl.text.trim();
                final mins = int.tryParse(durationCtrl.text) ?? 10;
                if (name.isNotEmpty) {
                  setState(() {
                    _segments.add(ServiceSegment(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      durationMinutes: mins,
                      type: selectedType,
                    ));
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int total;
  final int done;
  final int totalMinutes;

  const _SummaryBar({
    required this.total,
    required this.done,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.primaryBlueDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$done / $total segments done',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: Colors.white54, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${totalMinutes ~/ 60}h ${totalMinutes % 60}m total',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.secondaryGold : AppColors.secondaryGold,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Segment Card
// ─────────────────────────────────────────────────────────────────────────────

class _SegmentCard extends StatelessWidget {
  final ServiceSegment segment;
  final int index;
  final VoidCallback onStatusTap;
  final VoidCallback onLaunchTimer;
  final VoidCallback onDelete;

  const _SegmentCard({
    super.key,
    required this.segment,
    required this.index,
    required this.onStatusTap,
    required this.onLaunchTimer,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(segment.type);
    final isDone = segment.status == SegmentStatus.done;
    final isActive = segment.status == SegmentStatus.active;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.08)
              : isDone
                  ? AppColors.background
                  : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color : AppColors.divider,
            width: isActive ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: _StatusDot(status: segment.status, color: color, onTap: onStatusTap),
          title: Text(
            segment.name,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isDone ? AppColors.textSecondary : AppColors.primaryBlueDark,
              decoration: isDone ? TextDecoration.lineThrough : null,
              fontSize: 15,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(_iconFor(segment.type), size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                '${_labelFor(segment.type)} · ${segment.durationMinutes} min',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Launch timer button
              IconButton(
                icon: Icon(
                  Icons.timer_outlined,
                  color: isDone ? AppColors.textSecondary : AppColors.primaryBlue,
                  size: 20,
                ),
                tooltip: 'Load in Timer (${segment.durationMinutes} min)',
                onPressed: isDone ? null : onLaunchTimer,
                padding: const EdgeInsets.all(8),
              ),
              // Delete
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                onPressed: onDelete,
                padding: const EdgeInsets.all(8),
              ),
              // Drag handle
              const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final SegmentStatus status;
  final Color color;
  final VoidCallback onTap;

  const _StatusDot({required this.status, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: switch (status) {
            SegmentStatus.pending => Colors.transparent,
            SegmentStatus.active => color,
            SegmentStatus.done => AppColors.success.withValues(alpha: 0.15),
          },
          border: Border.all(
            color: switch (status) {
              SegmentStatus.pending => AppColors.divider,
              SegmentStatus.active => color,
              SegmentStatus.done => AppColors.success,
            },
            width: 2,
          ),
        ),
        child: Icon(
          switch (status) {
            SegmentStatus.pending => Icons.circle_outlined,
            SegmentStatus.active => Icons.play_arrow_rounded,
            SegmentStatus.done => Icons.check_rounded,
          },
          size: 18,
          color: switch (status) {
            SegmentStatus.pending => AppColors.divider,
            SegmentStatus.active => Colors.white,
            SegmentStatus.done => AppColors.success,
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _colorFor(SegmentType t) => switch (t) {
      SegmentType.worship => AppColors.primaryBlue,
      SegmentType.message => AppColors.accentMaroon,
      SegmentType.prayer => const Color(0xFF6B4DA0),
      SegmentType.offering => AppColors.secondaryGold,
      SegmentType.announcements => const Color(0xFF2E7D6B),
      SegmentType.other => AppColors.textSecondary,
    };

IconData _iconFor(SegmentType t) => switch (t) {
      SegmentType.worship => Icons.music_note_rounded,
      SegmentType.message => Icons.menu_book_rounded,
      SegmentType.prayer => Icons.volunteer_activism_rounded,
      SegmentType.offering => Icons.favorite_rounded,
      SegmentType.announcements => Icons.campaign_rounded,
      SegmentType.other => Icons.more_horiz_rounded,
    };

String _labelFor(SegmentType t) => switch (t) {
      SegmentType.worship => 'Worship',
      SegmentType.message => 'Message',
      SegmentType.prayer => 'Prayer',
      SegmentType.offering => 'Offering',
      SegmentType.announcements => 'Announcements',
      SegmentType.other => 'Other',
    };
