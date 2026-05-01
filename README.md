<div align="center">

<img src="assets/background.jpg" alt="DARA Logo" width="480"/>

# DARA — M&P Didaskalia Advanced Robotics Association

**The official mobile companion app for DARA events and church operations**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00B4D8?logo=riverpod&logoColor=white)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Private-8B1A1A)](.)

</div>

---

## Overview

**DARA** is a Flutter-based mobile application that serves two core purposes:

1. **Robotics Competition Management** — Real-time match tracking, score calculation, leaderboard, and event schedules for DARA robotics tournaments.

2. **Church Event Operations** — A hands-on operator tool for the M&P Didaskalia church, enabling the tech team to manage timers, rundowns, and cues when hosting events for partner churches.

---

## Features

| Feature | Status | Description |
|---|---|---|
| 🏆 **Match Tracker** | ✅ Live | Live / Final / Upcoming match cards with red vs blue alliances |
| ⏱️ **Multi-Purpose Timer** | ✅ Live | Countdown timer with customizable presets and warning thresholds |
| 🧮 **Score Calculator** | ✅ Live | Phase-by-phase scoring (Autonomous, Teleop, Endgame) |
| 🗓️ **Event Schedule** | ✅ Live | Day-of timeline with My Team / Global filter |
| 🥇 **Leaderboard** | 🔜 Coming | Team rankings and standings |
| 📋 **Service Rundown** | 🔜 Planned | Church service order with segment timers |
| 🎵 **Song Set Tracker** | 🔜 Planned | Live worship set list for AV operators |
| 📢 **Operator Cues** | 🔜 Planned | Checkable cue sheet with auto-timestamps |

---

## Brand Colors

Derived directly from the official DARA logo:

| Swatch | Name | Hex | Usage |
|---|---|---|---|
| 🟦 | **Steel Blue** | `#4A6FA5` | Primary — buttons, links, active states |
| 🟨 | **Amber Gold** | `#F5A623` | Secondary — highlights, nav circle, warnings |
| 🟥 | **Deep Maroon** | `#8B1A1A` | Accent — errors, critical timer state |
| 🟫 | **Warm Cream** | `#F5F0E8` | Background — scaffold, canvas |

---

## Tech Stack

- **Flutter** (Material 3) — cross-platform UI
- **Riverpod** — reactive state management with code generation
- **GoRouter** — declarative navigation with shell routes
- **Hive** — lightweight local persistence (timer presets, settings)
- **Google Fonts** — Playfair Display (headings) + Inter (body)
- **flutter_animate** — declarative chained animations

---

## Project Structure

```
lib/
└── src/
    ├── core/
    │   ├── routing/        ← App router + bottom nav shell
    │   └── theme/          ← AppColors + AppTheme (brand tokens)
    ├── features/
    │   ├── calculator/     ← Score calc (data, models, providers, UI)
    │   ├── timer/          ← Match/event timer (providers, UI)
    │   ├── matches/        ← Live match cards
    │   ├── leaderboard/    ← Rankings (placeholder)
    │   └── schedule/       ← Event timeline
    └── shared/
        └── widgets/        ← DaraCard, DaraButton (brand components)
```

> 📄 See [`docs/CODEBASE.md`](docs/CODEBASE.md) for full internal documentation — architecture, screen references, design system, state management patterns, and a guide for adding new features.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.x` — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.11.0`
- Android Studio / VS Code with Flutter plugin

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd code_red

# Install dependencies
flutter pub get

# Generate Riverpod / Hive code
dart run build_runner build --delete-conflicting-outputs

# Run in debug mode
flutter run
```

### Generate Launcher Icons

The app icon is generated from `assets/background.jpg`:

```bash
dart run flutter_launcher_icons:main
```

---

## Development Workflow

```bash
# Watch mode for code generation (run alongside flutter run)
dart run build_runner watch --delete-conflicting-outputs

# Analyze for lint errors
flutter analyze

# Run tests
flutter test
```

---

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Follow the feature-first folder structure (see [`docs/CODEBASE.md`](docs/CODEBASE.md))
3. Always use `AppColors` tokens — never raw `Colors.blue` or hex literals
4. Run `flutter analyze` before committing — zero warnings policy
5. Submit a pull request with a clear description of changes

---

<div align="center">

Built with ❤️ by the M&P Didaskalia team

*"Equipping champions — in robotics and in faith."*

</div>
