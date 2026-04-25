# DARA Robotics App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a premium, production-ready robotics competition app for DARA with a rule-engine calculator and resilient timer.

**Architecture:** Feature-First Clean Architecture using Riverpod for state, GoRouter for navigation, and Hive for persistence.

**Tech Stack:** Flutter, Riverpod, GoRouter, Hive, Google Fonts, HapticFeedback.

---

### Task 1: Environment & Dependencies
**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependencies to pubspec.yaml**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  hive_generator: ^2.0.1
```

- [ ] **Step 2: Run flutter pub get**
Run: `flutter pub get`

- [ ] **Step 3: Commit**
```bash
git add pubspec.yaml
git commit -m "chore: add project dependencies"
```

### Task 2: Core Theme & Typography
**Files:**
- Create: `lib/src/core/theme/app_colors.dart`
- Create: `lib/src/core/theme/app_theme.dart`

- [ ] **Step 1: Define DARA Brand Colors**
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF003366);
  static const Color secondaryGold = Color(0xFFD4AF37);
  static const Color accentMaroon = Color(0xFF800000);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
}
```

- [ ] **Step 2: Create AppTheme with Playfair Display and Inter**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryGold,
        error: AppColors.accentMaroon,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**
```bash
git add lib/src/core/theme/
git commit -m "feat: implement premium DARA theme"
```

### Task 3: Calculator Rule Engine Model
**Files:**
- Create: `lib/src/features/calculator/models/rule.dart`

- [ ] **Step 1: Define Rule Engine Models**
```dart
enum RuleType { counter, toggle, selection }

class GameRule {
  final String id;
  final String label;
  final int pointsPerUnit;
  final RuleType type;
  final int maxValue;

  GameRule({
    required this.id,
    required this.label,
    required this.pointsPerUnit,
    this.type = RuleType.counter,
    this.maxValue = 99,
  });
}

class GamePhase {
  final String title;
  final List<GameRule> rules;

  GamePhase({required this.title, required this.rules});
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/src/features/calculator/models/rule.dart
git commit -m "feat: define rule engine models"
```

### Task 4: Calculator State Management
**Files:**
- Create: `lib/src/features/calculator/providers/calculator_provider.dart`

- [ ] **Step 1: Implement Calculator State with Riverpod**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'calculator_provider.g.dart';

@riverpod
class Calculator extends _$Calculator {
  @override
  Map<String, int> build() => {};

  void updateScore(String ruleId, int delta) {
    state = {...state, ruleId: (state[ruleId] ?? 0) + delta};
  }

  int get totalScore {
    // Logic to multiply state values by Rule points
    return 0; // Simplified for plan
  }
}
```

- [ ] **Step 2: Run build_runner**
Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Commit**
```bash
git add lib/src/features/calculator/providers/
git commit -m "feat: add calculator state provider"
```

### Task 5: Premium Shared Widgets
**Files:**
- Create: `lib/src/shared/widgets/dara_card.dart`
- Create: `lib/src/shared/widgets/dara_button.dart`

- [ ] **Step 1: Implement DARA Card**
```dart
import 'package:flutter/material.dart';

class DaraCard extends StatelessWidget {
  final Widget child;
  const DaraCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
```

- [ ] **Step 2: Implement Dara Button (Large Target)**
```dart
import 'package:flutter/material.dart';

class DaraButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const DaraButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```

- [ ] **Step 3: Commit**
```bash
git add lib/src/shared/widgets/
git commit -m "feat: add shared premium widgets"
```

### Task 6: Main UI Scaffolding & Routing
**Files:**
- Create: `lib/src/core/routing/app_router.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Set up GoRouter**
(Define routes for Calculator, Timer, Matches, Leaderboard, Schedule)

- [ ] **Step 2: Update main.dart with ProviderScope and Theme**

- [ ] **Step 3: Commit**
```bash
git add lib/src/core/routing/ lib/main.dart
git commit -m "feat: setup app routing and entry point"
```

### Task 7: Game Timer Implementation
**Files:**
- Create: `lib/src/features/timer/providers/timer_provider.dart`
- Create: `lib/src/features/timer/presentation/timer_screen.dart`

- [ ] **Step 1: Implement State-Resilient Timer Logic**
- [ ] **Step 2: Build Timer UI with large digits and preset buttons**
- [ ] **Step 3: Commit**

### Task 8: Matches & Schedule UI (Mock Data)
**Files:**
- Create: `lib/src/features/matches/presentation/matches_screen.dart`
- Create: `lib/src/features/schedule/presentation/schedule_screen.dart`

- [ ] **Step 1: Implement Match List UI**
- [ ] **Step 2: Implement Team Schedule Timeline**
- [ ] **Step 3: Commit**

### Task 9: Final Polish & Asset Integration
**Files:**
- Modify: `lib/src/core/theme/app_theme.dart`

- [ ] **Step 1: Add subtle animations (flutter_animate)**
- [ ] **Step 2: Final theme tweaks for production feel**
- [ ] **Step 3: Commit**
