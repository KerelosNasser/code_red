import 'package:flutter/material.dart';
import '../../../shared/widgets/dara_card.dart';
import '../../../core/theme/app_colors.dart';

class ScheduleItem {
  final String time;
  final String description;
  final String? teamNumber;
  final bool isMyTeam;

  ScheduleItem({
    required this.time,
    required this.description,
    this.teamNumber,
    this.isMyTeam = false,
  });
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _showMyTeamOnly = true;

  final List<ScheduleItem> _allScheduleItems = [
    ScheduleItem(time: '08:00 AM', description: 'Opening Ceremony'),
    ScheduleItem(time: '09:00 AM', description: 'Qualification 1'),
    ScheduleItem(time: '09:45 AM', description: 'Qualification 12', teamNumber: '123', isMyTeam: true),
    ScheduleItem(time: '11:00 AM', description: 'Qualification 24', teamNumber: '123', isMyTeam: true),
    ScheduleItem(time: '12:00 PM', description: 'Lunch Break'),
    ScheduleItem(time: '01:30 PM', description: 'Qualification 45', teamNumber: '123', isMyTeam: true),
    ScheduleItem(time: '03:00 PM', description: 'Qualification 60'),
    ScheduleItem(time: '04:30 PM', description: 'Closing Remarks'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _showMyTeamOnly
        ? _allScheduleItems.where((item) => item.isMyTeam || item.teamNumber == null).toList()
        : _allScheduleItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SCHEDULE',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBlue,
                letterSpacing: 1.2,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: 'My Team',
                    isSelected: _showMyTeamOnly,
                    onTap: () => setState(() => _showMyTeamOnly = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToggleButton(
                    label: 'Global',
                    isSelected: !_showMyTeamOnly,
                    onTap: () => setState(() => _showMyTeamOnly = false),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _TimelineItem(
                  item: item,
                  isLast: index == filteredItems.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;

  const _TimelineItem({
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.isMyTeam ? AppColors.secondaryGold : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: DaraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    if (item.teamNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Team ${item.teamNumber}',
                        style: TextStyle(
                          color: item.isMyTeam ? AppColors.secondaryGold : Colors.grey[600],
                          fontWeight: item.isMyTeam ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
