import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_utils.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  /// Uses a positional constructor to prevent "no matching constructor" errors
  /// during hot reload or complex shell builds.
  const AppShell(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    // Determine current index based on route
    int currentIndex = 0;
    if (location.startsWith('/timer')) {
      currentIndex = 1;
    } else if (location.startsWith('/manual')) {
      currentIndex = 2;
    } else if (location.startsWith('/matches')) {
      currentIndex = 3;
    } else if (location.startsWith('/schedule')) {
      currentIndex = 4;
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: CircleNavBar(
        activeIcons: [
          Icon(
            Icons.calculate,
            color: Colors.white,
            size: context.scaleFont(24),
          ),
          Icon(Icons.timer, color: Colors.white, size: context.scaleFont(24)),
          Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: context.scaleFont(24),
          ),
          Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: context.scaleFont(24),
          ),
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: context.scaleFont(24),
          ),
        ],
        inactiveIcons: [
          Text(
            "Calc",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.scaleFont(12),
            ),
          ),
          Text(
            "Timer",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.scaleFont(12),
            ),
          ),
          Text(
            "Manual",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.scaleFont(12),
            ),
          ),
          Text(
            "Matches",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.scaleFont(12),
            ),
          ),
          Text(
            "Sched",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.scaleFont(12),
            ),
          ),
        ],
        color: AppColors.primaryBlueDark,
        circleColor: AppColors.secondaryGold,
        height: 70,
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
              context.go('/manual');
              break;
            case 3:
              context.go('/matches');
              break;
            case 4:
              context.go('/schedule');
              break;
          }
        },
        padding: EdgeInsets.only(
          left: context.scaleWidth(16),
          right: context.scaleWidth(16),
          bottom: 20,
        ),
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
          colors: [AppColors.accentMaroon, AppColors.accentMaroon],
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
