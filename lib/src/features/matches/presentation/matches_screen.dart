import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/dara_app_bar.dart';
import '../../../shared/widgets/dara_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../providers/matches_providers.dart';

class MatchModel {
  final String matchNumber;
  final List<String> redTeams;
  final List<String> blueTeams;
  final String field;
  final String status; // Live, Final, Upcoming
  final int? redScore;
  final int? blueScore;

  MatchModel({
    required this.matchNumber,
    required this.redTeams,
    required this.blueTeams,
    required this.field,
    required this.status,
    this.redScore,
    this.blueScore,
  });
}

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

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLeaderboard = ref.watch(leaderboardVisibleProvider);
    final showMap = ref.watch(mapVisibleProvider);

    final mockMatches = [
      MatchModel(
        matchNumber: 'Qualification 12',
        redTeams: ['123', '456'],
        blueTeams: ['789', '101'],
        field: 'Alpha Field',
        status: 'Live',
        redScore: 45,
        blueScore: 32,
      ),
      MatchModel(
        matchNumber: 'Qualification 11',
        redTeams: ['202', '303'],
        blueTeams: ['404', '505'],
        field: 'Beta Field',
        status: 'Final',
        redScore: 120,
        blueScore: 115,
      ),
      MatchModel(
        matchNumber: 'Qualification 13',
        redTeams: ['606', '707'],
        blueTeams: ['808', '909'],
        field: 'Alpha Field',
        status: 'Upcoming',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DaraAppBar(
        title: 'MATCHES',
        leading: IconButton(
          icon: const Icon(Icons.leaderboard),
          onPressed: () => ref.read(leaderboardVisibleProvider.notifier).state = true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => ref.read(mapVisibleProvider.notifier).state = true,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(context.scaleWidth(16)),
            itemCount: mockMatches.length,
            itemBuilder: (context, index) {
              final match = mockMatches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DaraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            match.matchNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          _StatusBadge(status: match.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.field,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: context.scaleFont(12),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _AllianceColumn(
                              teams: match.redTeams,
                              score: match.redScore,
                              isRed: true,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _AllianceColumn(
                              teams: match.blueTeams,
                              score: match.blueScore,
                              isRed: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (showLeaderboard) const _LeaderboardOverlay(),
          if (showMap) const _MapOverlay(),
        ],
      ),
    );
  }
}

class _LeaderboardOverlay extends ConsumerWidget {
  const _LeaderboardOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = [
      TeamStats(teamNumber: '123', skills: 85, teamwork: 90, strategy: 80, points: 255),
      TeamStats(teamNumber: '456', skills: 78, teamwork: 85, strategy: 82, points: 245),
      TeamStats(teamNumber: '789', skills: 92, teamwork: 75, strategy: 75, points: 242),
      TeamStats(teamNumber: '101', skills: 70, teamwork: 88, strategy: 80, points: 238),
      TeamStats(teamNumber: '202', skills: 82, teamwork: 80, strategy: 75, points: 237),
    ];

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(context.scaleWidth(20)),
          padding: EdgeInsets.all(context.scaleWidth(16)),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEADERBOARD',
                    style: TextStyle(
                      fontSize: context.scaleFont(20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlueDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(leaderboardVisibleProvider.notifier).state = false,
                  ),
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
                  columns: const [
                    DataColumn(label: Text('RANK')),
                    DataColumn(label: Text('TEAM')),
                    DataColumn(label: Text('SKILLS')),
                    DataColumn(label: Text('WORK')),
                    DataColumn(label: Text('STRAT')),
                    DataColumn(label: Text('PTS')),
                  ],
                  rows: stats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stat = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(stat.teamNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${stat.skills}')),
                      DataCell(Text('${stat.teamwork}')),
                      DataCell(Text('${stat.strategy}')),
                      DataCell(Text('${stat.points}', style: const TextStyle(color: AppColors.accentMaroon, fontWeight: FontWeight.bold))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapOverlay extends ConsumerWidget {
  const _MapOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.asset(
                'assets/background.jpg', // Placeholder image
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => ref.read(mapVisibleProvider.notifier).state = false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'live':
        color = Colors.red;
        break;
      case 'final':
        color = Colors.green;
        break;
      default:
        color = AppColors.primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: context.scaleFont(10),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AllianceColumn extends StatelessWidget {
  final List<String> teams;
  final int? score;
  final bool isRed;

  const _AllianceColumn({
    required this.teams,
    this.score,
    required this.isRed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? AppColors.accentMaroon : AppColors.primaryBlue;
    return Column(
      children: [
        if (score != null)
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: context.scaleFont(24),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: teams
              .map((t) => Text(
                    t,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
