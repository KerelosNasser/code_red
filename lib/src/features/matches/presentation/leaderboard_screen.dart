import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/dara_app_bar.dart';

class TeamStats {
  final String teamNumber;
  final int skills;
  final int teamwork;
  final int strategy;
  final int points;

  TeamStats({
    required this.teamNumber,
    required this.skills,
    required this.teamwork,
    required this.strategy,
    required this.points,
  });
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      TeamStats(teamNumber: '123', skills: 85, teamwork: 90, strategy: 80, points: 255),
      TeamStats(teamNumber: '456', skills: 78, teamwork: 85, strategy: 82, points: 245),
      TeamStats(teamNumber: '789', skills: 92, teamwork: 75, strategy: 75, points: 242),
      TeamStats(teamNumber: '101', skills: 70, teamwork: 88, strategy: 80, points: 238),
      TeamStats(teamNumber: '202', skills: 82, teamwork: 80, strategy: 75, points: 237),
      TeamStats(teamNumber: '303', skills: 75, teamwork: 75, strategy: 85, points: 235),
      TeamStats(teamNumber: '404', skills: 80, teamwork: 70, strategy: 80, points: 230),
      TeamStats(teamNumber: '505', skills: 65, teamwork: 85, strategy: 75, points: 225),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DaraAppBar(title: 'LEADERBOARD'),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return _LeaderboardRow(
                  stats: stats[index],
                  rank: index + 1,
                  index: index,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                  .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.scaleWidth(12),
        horizontal: context.scaleWidth(16),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _headerCell('RK', width: 35),
          _headerCell('TEAM', expand: true),
          _headerCell('SKL', width: 45),
          _headerCell('TW', width: 45),
          _headerCell('ST', width: 45),
          _headerCell('PTS', width: 55, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {double? width, bool expand = false, TextAlign align = TextAlign.left}) {
    final cell = Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
    return expand ? Expanded(child: cell) : SizedBox(width: width, child: cell);
  }
}

class _LeaderboardRow extends StatelessWidget {
  final TeamStats stats;
  final int rank;
  final int index;

  const _LeaderboardRow({
    required this.stats,
    required this.rank,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTop3 = rank <= 3;
    final Color bgColor = index.isEven 
        ? AppColors.primaryBlue.withOpacity(0.03) 
        : Colors.transparent;

    return Container(
      height: context.scaleWidth(56),
      padding: EdgeInsets.symmetric(horizontal: context.scaleWidth(16)),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: isTop3 
              ? Icon(
                  Icons.emoji_events, 
                  size: 20, 
                  color: rank == 1 ? AppColors.secondaryGold : (rank == 2 ? Colors.grey[400] : Colors.brown[300])
                )
              : Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
          ),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    stats.teamNumber[0],
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Team ${stats.teamNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          _dataCell('${stats.skills}', width: 45),
          _dataCell('${stats.teamwork}', width: 45),
          _dataCell('${stats.strategy}', width: 45),
          _dataCell(
            '${stats.points}',
            width: 55,
            align: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.accentMaroon,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataCell(String text, {required double width, TextAlign align = TextAlign.left, TextStyle? style}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: style ?? TextStyle(
          color: Colors.grey[800],
          fontSize: 13,
        ),
      ),
    );
  }
}
