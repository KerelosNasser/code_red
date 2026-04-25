import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/timer/presentation/timer_screen.dart';
import '../../features/matches/presentation/matches_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';

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
        color: Colors.white,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,
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
        shadowColor: Colors.yellow.shade800,
        circleShadowColor: Colors.yellow.shade800,
        elevation: 4,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
        circleGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/matches',
  routes: [
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
