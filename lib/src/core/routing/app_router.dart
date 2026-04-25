import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/timer/presentation/timer_screen.dart';
import '../../features/matches/presentation/matches_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/calculator',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calculator',
              builder: (context, state) => const CalculatorScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timer',
              builder: (context, state) => const TimerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/matches',
              builder: (context, state) => const MatchesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leaderboard',
              builder: (context, state) => const LeaderboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (context, state) => const ScheduleScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(label: 'Calculator', icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate)),
          NavigationDestination(label: 'Timer', icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer)),
          NavigationDestination(label: 'Matches', icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events)),
          NavigationDestination(label: 'Leaderboard', icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard)),
          NavigationDestination(label: 'Schedule', icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today)),
        ],
        onDestinationSelected: (int index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
