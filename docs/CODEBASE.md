# DaRa Codebase Documentation

> **M&P Didaskalia Advanced Robotics Association**  
> Flutter mobile application — internal technical reference

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Architecture](#3-architecture)
4. [Directory Structure](#4-directory-structure)
5. [Screens & Features](#5-screens--features)
6. [Design System](#6-design-system)
7. [State Management](#7-state-management)
8. [Routing](#8-routing)
9. [Data & Persistence](#9-data--persistence)
10. [Adding a New Feature](#10-adding-a-new-feature)

---

## 1. Project Overview

**DaRa** is the official mobile companion app for the M&P Didaskalia Advanced Robotics Association. It is also used by the church as an **event operations tool** for hosting and streaming events for partner churches. The app gives operators a single handset tool to manage:

- Live match scores and team standings
- Multi-purpose countdown timers for event segments
- Event schedule and service rundown
- Score calculation for competition phases

**Flutter app name (pubspec):** `code_red`  
**Display title (main.dart):** `DaRa Robotics`  
**Min Android SDK:** 21  
**Dart SDK:** `^3.11.0`

---

## 2. Tech Stack

| Concern | Package | Notes |
|---|---|---|
| UI Framework | Flutter (stable) | Material 3 |
| State Management | `flutter_riverpod ^2.5.1` + `riverpod_annotation ^2.3.5` | Code-gen with `@riverpod` |
| Navigation | `go_router ^13.2.0` | Shell route with bottom nav |
| Local Persistence | `hive ^2.2.3` + `hive_flutter ^1.1.0` | Not yet wired; ready for use |
| Typography | `google_fonts ^6.2.1` | Playfair Display + Inter |
| Animations | `flutter_animate ^4.5.0` | Declarative chained animations |
| Bottom Nav | `circle_nav_bar ^2.2.0` | Circle-highlight nav bar |
| Code Generation | `riverpod_generator`, `build_runner`, `hive_generator` | Dev deps |

---

## 3. Architecture

The project follows a **feature-first, layered** architecture:

```
lib/
└── src/
    ├── core/           # App-wide infrastructure
    │   ├── routing/    # GoRouter config + ScaffoldWithNavBar
    │   └── theme/      # AppColors + AppTheme (Material 3)
    ├── features/       # One folder per vertical feature slice
    │   ├── calculator/ # data/ | models/ | presentation/ | providers/
    │   ├── timer/      # presentation/ | providers/
    │   ├── matches/    # presentation/
    │   ├── leaderboard/# presentation/  (placeholder)
    │   └── schedule/   # presentation/
    └── shared/
        └── widgets/    # Reusable brand widgets (DaraCard, DaraButton)
```

Each feature slice contains only the layers it needs:
- **`data/`** — static data sources (e.g. `game_rules.dart`)
- **`models/`** — pure Dart model classes
- **`providers/`** — Riverpod notifiers (`@riverpod` annotated)
- **`presentation/`** — Flutter widgets / screens

---

## 4. Directory Structure

```
code_red/
├── assets/
│   ├── background.jpg                  ← App icon + brand reference
│   ├── Dara-main logo.png
│   ├── Dara-main-logo--transparent.png
│   ├── Secondary-logo.png
│   ├── icon-dara-logo.png
│   └── text-dara-logo.png
├── lib/
│   ├── main.dart                       ← Entry: ProviderScope + MaterialApp.router
│   └── src/
│       ├── core/
│       │   ├── routing/app_router.dart ← GoRouter + ScaffoldWithNavBar
│       │   └── theme/
│       │       ├── app_colors.dart     ← Brand color constants
│       │       └── app_theme.dart      ← Material 3 ThemeData
│       ├── features/
│       │   ├── calculator/
│       │   │   ├── data/game_rules.dart
│       │   │   ├── models/rule.dart
│       │   │   ├── presentation/calculator_screen.dart
│       │   │   └── providers/calculator_provider.dart
│       │   ├── timer/
│       │   │   ├── presentation/timer_screen.dart
│       │   │   └── providers/timer_provider.dart
│       │   ├── matches/
│       │   │   └── presentation/matches_screen.dart
│       │   ├── leaderboard/
│       │   │   └── presentation/leaderboard_screen.dart
│       │   └── schedule/
│       │       └── presentation/schedule_screen.dart
│       └── shared/
│           └── widgets/
│               ├── dara_card.dart      ← Branded card container
│               └── dara_button.dart    ← Branded button wrapper
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 5. Screens & Features

### 5.1 Calculator (`/calculator`)

**File:** `features/calculator/presentation/calculator_screen.dart`  
**Provider:** `calculatorProvider` (StateNotifier)  
**Data:** `game_rules.dart` — `daraGamePhases` list

A score-tally tool for DaRa robotics match phases:

| Phase | Rules |
|---|---|
| Autonomous | High Goal (6 pts), Low Goal (2 pts), Mobility toggle (3 pts) |
| Teleop | High Goal (3 pts), Low Goal (1 pt) |
| Endgame | Climb L1 (5), L2 (10), L3 (15) — toggles |

Rules have two types defined in `models/rule.dart`:
- `RuleType.counter` — +/– buttons with maxValue cap
- `RuleType.toggle` — Switch widget (0 or pointsPerUnit)

**Key widgets:** `_ScoreSummary`, `_PhaseSection`, `_RuleItem`, `_ControlBtn`

---

### 5.2 Timer (`/timer`)

**File:** `features/timer/presentation/timer_screen.dart`  
**Provider:** `timerNotifierProvider` → `TimerNotifier` extends `_$TimerNotifier`

A countdown match timer with:
- **States:** `initial` | `running` | `paused` | `finished`
- **Presets:** 2:30 (150s), 2:00 (120s), 0:30 (30s) — hard-coded chips
- **Controls:** Play/Pause (FilledButton), Reset (IconButton.filledTonal)
- **Responsive:** font size scales between narrow/wide and short/tall constraints

**Provider methods:**
```dart
notifier.start()      // starts or resumes from current duration
notifier.pause()      // pauses; preserves durationRemaining
notifier.reset()      // resets to _initialDuration
notifier.setPreset(int seconds)  // changes duration and resets
```

**TimerState fields:**
```dart
int durationRemaining   // seconds left
TimerStateStatus status // initial | running | paused | finished
```

> ⚠️ **Planned enhancement:** Multi-mode timer (Countdown / Stopwatch / Clock / Pre-Service) with named Hive-persisted presets, full-screen overlay mode, and warning thresholds.

---

### 5.3 Matches (`/matches`)

**File:** `features/matches/presentation/matches_screen.dart`  
**Data:** In-line mock `List<MatchModel>` — no provider yet

Displays match cards with:
- Status badge: `Live` (red) | `Final` (green) | `Upcoming` (blue)
- Red vs Blue alliance columns with team numbers and scores
- Field label per match

**MatchModel fields:** `matchNumber`, `redTeams`, `blueTeams`, `field`, `status`, `redScore?`, `blueScore?`

---

### 5.4 Leaderboard (`/leaderboard`)

**File:** `features/leaderboard/presentation/leaderboard_screen.dart`  
**Status:** 🚧 Placeholder — renders "Leaderboard Placeholder" text only.

---

### 5.5 Schedule (`/schedule`)

**File:** `features/schedule/presentation/schedule_screen.dart`  
**State:** Local `StatefulWidget` — `_showMyTeamOnly` bool toggle

Timeline view of the day's events with:
- Toggle: **My Team** (filters to `isMyTeam == true` items + general items) / **Global** (all items)
- Timeline dot: gold for `isMyTeam` items, blue for general
- Animated container toggle buttons with shadow on active state

**ScheduleItem fields:** `time`, `description`, `teamNumber?`, `isMyTeam`

---

## 6. Design System

### 6.1 Color Palette

Extracted from the official DaRa brand logo (`assets/background.jpg`):

| Token | Hex | Usage |
|---|---|---|
| `primaryBlue` | `#4A6FA5` | Steel blue from DaRa logotype — primary actions, links |
| `primaryBlueDark` | `#2C4A7C` | Deep navy — AppBar, text headings |
| `secondaryGold` | `#F5A623` | Amber gold from lion icon — secondary actions, highlights |
| `secondaryGoldDark` | `#D4881A` | Rich gold — pressed/hover states |
| `accentMaroon` | `#8B1A1A` | Deep maroon from subtitle — errors, danger states |
| `background` | `#F5F0E8` | Warm cream — scaffold background |
| `surface` | `#FFFFFF` | Card / modal surfaces |
| `cardBg` | `#FBF8F3` | Tinted card background |
| `divider` | `#E0D8CC` | Warm divider / borders |
| `textPrimary` | `#1C2B40` | Body text |
| `textSecondary` | `#6B7280` | Subtitles, captions |

**Timer semantic colors:**
- Normal → `timerNormal` = `primaryBlue`
- Last 5 min warning → `timerWarning` = `secondaryGold`
- Last 1 min critical → `timerCritical` = `accentMaroon`

### 6.2 Typography

| Style | Font | Weight | Size |
|---|---|---|---|
| `displayLarge` | Playfair Display | Bold | 96px — timer digits |
| `displayMedium` | Playfair Display | Bold | 60px |
| `titleLarge` | Playfair Display | SemiBold | 22px — screen titles |
| `titleMedium` | Inter | SemiBold | 16px — card titles |
| `bodyLarge` | Inter | Regular | 16px |
| `bodyMedium` | Inter | Regular | 14px |
| `labelLarge` | Inter | SemiBold | 14px + letter-spacing — caps labels |

### 6.3 Shared Widgets

#### `DaraCard`
```dart
DaraCard(child: yourWidget)
// → Card with elevation 2, 12px radius, 16px padding
```

#### `DaraButton`
Located at `shared/widgets/dara_button.dart` — branded button wrapper.

---

## 7. State Management

**Pattern:** Riverpod code-generation with `@riverpod` annotation.

### TimerNotifier

```dart
@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;
  int _initialDuration = 150;
  // ...
}
```
Generated file: `timer_provider.g.dart` (do not edit manually)

### CalculatorProvider

Located at `features/calculator/providers/calculator_provider.dart`.  
Tracks `Map<String, int>` of rule IDs → counts.

### Running Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
# or watch mode during development:
dart run build_runner watch --delete-conflicting-outputs
```

---

## 8. Routing

**Router:** `appRouter` (GoRouter instance in `core/routing/app_router.dart`)  
**Initial location:** `/matches`  
**Shell:** `ScaffoldWithNavBar` wraps all routes — provides the bottom `CircleNavBar`

| Path | Screen | Nav Index |
|---|---|---|
| `/calculator` | CalculatorScreen | 0 |
| `/timer` | TimerScreen | 1 |
| `/matches` | MatchesScreen | 2 |
| `/leaderboard` | LeaderboardScreen | 3 |
| `/schedule` | ScheduleScreen | 4 |

The nav bar active index is derived from `GoRouterState.of(context).matchedLocation` — no additional state needed.

---

## 9. Data & Persistence

### Static Data
- `game_rules.dart` — Hardcoded `List<GamePhase>` for the score calculator.
- Match/Schedule screens use inline mock data (no API layer yet).

### Hive (Ready, Not Yet Wired)
Packages `hive` and `hive_flutter` are installed. Planned use:
- Persist custom named timer presets (label + duration)
- Persist team number for schedule filtering

**Setup template for a new Hive box:**
```dart
// In main():
await Hive.initFlutter();
await Hive.openBox('timerPresets');
```

---

## 10. Adding a New Feature

1. **Create the feature folder:**
   ```
   lib/src/features/my_feature/
   ├── data/          (if needed)
   ├── models/        (if needed)
   ├── providers/
   │   └── my_provider.dart   (@riverpod annotated)
   └── presentation/
       └── my_screen.dart
   ```

2. **Add the route** in `core/routing/app_router.dart`:
   ```dart
   GoRoute(
     path: '/my-feature',
     builder: (context, state) => const MyScreen(),
   ),
   ```

3. **Add the nav entry** in `ScaffoldWithNavBar` — update `activeIcons`, `inactiveIcons`, `onTap`, and the location `if` chain.

4. **Run code generation** if you added a `@riverpod` provider:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Use brand tokens** — always import `AppColors` for colors and rely on `Theme.of(context).textTheme` for text styles. Never use raw `Colors.blue` or hard-coded hex values.
