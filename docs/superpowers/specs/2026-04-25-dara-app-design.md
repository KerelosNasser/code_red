# Design Doc: DARA Robotics Competition App

**Date:** 2026-04-25
**Topic:** M&P Didaskalia Advanced Robotics Association (DARA) Event Management App
**Status:** Approved

## 1. Executive Summary
A production-ready Flutter application designed for the DARA Robotics Association. The app serves as a "Command Center" for referees, coaches, and organizers during high-intensity robotics competitions. It prioritizes one-handed usability, state resilience, and a premium "sports/event" aesthetic.

## 2. Architecture: State-Driven Modular
- **State Management:** Riverpod (with `riverpod_generator`) for high-performance, predictable state.
- **Routing:** GoRouter for deep-linking and clean navigation.
- **Persistence:** Hive for lightweight, fast local storage of timer states and calculator rules.
- **Structure:** Feature-First Clean Architecture.
  - `lib/src/features/timer`: Countdown/stopwatch logic and presets.
  - `lib/src/features/calculator`: Rule engine and scoring logic.
  - `lib/src/features/matches`: Match listing and filtering.
  - `lib/src/features/leaderboard`: Team rankings and stats.
  - `lib/src/features/schedule`: Team-centric and global timelines.
  - `lib/src/core`: Theme, routing, and shared utilities.

## 3. Visual Identity
- **Primary Color:** DARA Blue (#003366 - adjusted for premium feel).
- **Secondary Color:** Golden Lion (#D4AF37).
- **Accent Color:** Maroon (#800000) for alerts/penalties.
- **Typography:** 
  - Serif (e.g., Playfair Display) for headers to match the DARA logo.
  - Sans-Serif (e.g., Inter/Roboto) for data and body text.
- **Aesthetics:** Large tap targets, subtle shadows, and high-contrast layouts for visibility under competition lights.

## 4. Feature Specifications

### 4.1 Game Calculator (Rule Engine)
- **Engine:** JSON-based rule definitions allowing for runtime configuration of points.
- **Input Types:** Toggles, Counters (+/-), and Pickers.
- **Validation:** Rule-based constraints to prevent data entry errors.
- **UX:** Haptic feedback on every score change; live total sticky footer.

### 4.2 Game Timer
- **Resilience:** Timer state is decoupled from the UI, persisting through app restarts or backgrounding.
- **Modes:** Presets (Match, Auto, Teleop) + Manual Mode.
- **Controls:** Oversized "Start/Pause/Reset" buttons optimized for thumb access.
- **Alerts:** Sound and vibration notifications for phase transitions.

### 4.3 Schedule Map ("My Team" Focus)
- **Default View:** Filtered timeline of the user's selected team.
- **Global View:** Toggle to see the full event schedule.
- **Location Awareness:** Clear labeling of fields, pits, and stations.

### 4.4 Matches & Leaderboard
- **Matches:** Real-time status badges (Live, Upcoming, Finished).
- **Leaderboard:** Dynamic ranking with "Top 3" visual distinction.

## 5. Technical Requirements
- Responsive design for all mobile aspect ratios.
- Clean separation of Mock Data and Services to allow for future API integration.
- Standardized error handling and loading states.
- Support for Light/Dark modes.
