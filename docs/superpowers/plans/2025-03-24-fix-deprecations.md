# Fix Deprecation Warnings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace deprecated Flutter APIs (`activeColor` in Switch and `withOpacity`) with their modern counterparts (`activeThumbColor` and `withValues(alpha: ...)`).

**Architecture:** Surgical replacement of deprecated methods/properties in presentation layer files.

**Tech Stack:** Flutter, Dart

---

### Task 1: Fix deprecations in `calculator_screen.dart`

**Files:**
- Modify: `lib/src/features/calculator/presentation/calculator_screen.dart`

- [ ] **Step 1: Replace `activeColor` with `activeThumbColor` in `Switch`**

```dart
<<<<
                Switch(
                  value: value > 0,
                  onChanged: (val) => onChanged(val ? 1 : -1),
                  activeColor: Theme.of(context).primaryColor,
                ),
====
                Switch(
                  value: value > 0,
                  onChanged: (val) => onChanged(val ? 1 : -1),
                  activeThumbColor: Theme.of(context).primaryColor,
                ),
>>>>
```

- [ ] **Step 2: Replace `withOpacity` with `withValues(alpha: ...)` in `_ControlBtn`**

```dart
<<<<
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
        foregroundColor: Theme.of(context).primaryColor,
====
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        foregroundColor: Theme.of(context).primaryColor,
>>>>
```

- [ ] **Step 3: Commit changes**

```bash
git add lib/src/features/calculator/presentation/calculator_screen.dart
git commit -m "chore: fix deprecation warnings in calculator_screen.dart"
```

---

### Task 2: Fix deprecations in `schedule_screen.dart`

**Files:**
- Modify: `lib/src/features/schedule/presentation/schedule_screen.dart`

- [ ] **Step 1: Replace `withOpacity` with `withValues(alpha: ...)` in `_ToggleButton`**

```dart
<<<<
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
====
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
>>>>
```

- [ ] **Step 2: Commit changes**

```bash
git add lib/src/features/schedule/presentation/schedule_screen.dart
git commit -m "chore: fix deprecation warnings in schedule_screen.dart"
```

---

### Task 3: Verification

- [ ] **Step 1: Run `dart analyze`**

Run: `dart analyze`
Expected: No issues found.

- [ ] **Step 2: Final Commit (if any cleanups needed)**
