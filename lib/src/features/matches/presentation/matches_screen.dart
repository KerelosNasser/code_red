import 'package:flutter/material.dart';
import '../../../shared/widgets/dara_app_bar.dart';
import '../../../shared/widgets/dara_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

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

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: const DaraAppBar(title: 'MATCHES'),
      body: ListView.builder(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: teams
              .map((t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      t,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
