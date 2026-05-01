import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/timer/presentation/timer_screen.dart';
import '../../features/timer/presentation/fullscreen_timer_screen.dart';
import '../../features/matches/presentation/matches_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';
import '../theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/timer')) {
      currentIndex = 1;
    } else if (location.startsWith('/matches')) {
      currentIndex = 2;
    } else if (location.startsWith('/leaderboard')) {
      currentIndex = 3;
    } else if (location.startsWith('/schedule')) {
      currentIndex = 4;
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.calculate, color: Colors.white),
          Icon(Icons.timer, color: Colors.white),
          Icon(Icons.emoji_events, color: Colors.white),
          Icon(Icons.leaderboard, color: Colors.white),
          Icon(Icons.calendar_today, color: Colors.white),
        ],
        inactiveIcons: const [
          Text("Calc", style: TextStyle(color: Colors.white)),
          Text("Timer", style: TextStyle(color: Colors.white)),
          Text("Matches", style: TextStyle(color: Colors.white)),
          Text("Board", style: TextStyle(color: Colors.white)),
          Text("Sched", style: TextStyle(color: Colors.white)),
        ],
        color: AppColors.primaryBlueDark,
        circleColor: AppColors.secondaryGold,
        height: 60,
        circleWidth: 62,
        activeIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/calculator');
              break;
            case 1:
              context.go('/timer');
              break;
            case 2:
              context.go('/matches');
              break;
            case 3:
              context.go('/leaderboard');
              break;
            case 4:
              context.go('/schedule');
              break;
          }
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: AppColors.secondaryGold.withValues(alpha: 0.4),
        circleShadowColor: AppColors.secondaryGoldDark.withValues(alpha: 0.5),
        elevation: 6,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlueDark, AppColors.accentMaroon],
        ),
        circleGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryGold, AppColors.secondaryGoldDark],
        ),
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/matches',
  routes: [
    // ── Fullscreen timer: outside shell so nav bar is hidden ──────────────
    GoRoute(
      path: '/timer/fullscreen',
      builder: (context, state) => const FullscreenTimerScreen(),
    ),
    // ── Main shell with bottom nav ────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/calculator',
          builder: (context, state) => const CalculatorScreen(),
        ),
        GoRoute(
          path: '/timer',
          builder: (context, state) => const TimerScreen(),
        ),
        GoRoute(
          path: '/matches',
          builder: (context, state) => const MatchesScreen(),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleScreen(),
        ),
      ],
    ),
  ],
);
