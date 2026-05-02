import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/timer/presentation/timer_screen.dart';
import '../../features/timer/presentation/fullscreen_timer_screen.dart';
import '../../features/matches/presentation/matches_screen.dart';
import '../../features/manual/presentation/manual_screen.dart';
import '../../features/schedule/presentation/schedule_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
          return AppShell(child);
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
            builder: (context, state) => const ManualScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
        ],
      ),
    ],
  );
});
