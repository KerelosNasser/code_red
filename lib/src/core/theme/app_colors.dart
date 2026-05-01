import 'package:flutter/material.dart';

/// DARA Color Palette — extracted from the official brand logo (background.jpg)
///
/// Primary:   Steel Blue  — the "DARA" logotype
/// Secondary: Amber Gold  — the lion & gear icon
/// Accent:    Deep Maroon — "M&P Didaskalia" subtitle text
/// Surface:   Cream       — the warm off-white logo background
class AppColors {
  AppColors._();

  // ── Core Brand ──────────────────────────────────────────────────────────────
  /// Steel blue from the DARA logotype (#4A6FA5)
  static const Color primaryBlue = Color(0xFF4A6FA5);

  /// Deep navy — darker variant for text / appbar weight
  static const Color primaryBlueDark = Color(0xFF2C4A7C);

  /// Amber gold from the lion & gear icon (#F5A623)
  static const Color secondaryGold = Color(0xFFF5A623);

  /// Richer gold for hover / pressed states
  static const Color secondaryGoldDark = Color(0xFFD4881A);

  /// Deep maroon from the subtitle text (#8B1A1A)
  static const Color accentMaroon = Color(0xFF8B1A1A);

  // ── Surfaces ─────────────────────────────────────────────────────────────────
  /// Warm cream from the logo background (#F5F0E8)
  static const Color background = Color(0xFFF5F0E8);

  /// Pure white surface for cards / modals
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle warm card tint
  static const Color cardBg = Color(0xFFFBF8F3);

  // ── Utility ──────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0D8CC);
  static const Color textPrimary = Color(0xFF1C2B40);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF5A623); // reuse gold
  static const Color error = Color(0xFF8B1A1A);   // reuse maroon

  // ── Timer States ─────────────────────────────────────────────────────────────
  static const Color timerNormal = primaryBlue;
  static const Color timerWarning = secondaryGold;  // last 5 min
  static const Color timerCritical = accentMaroon;  // last 1 min
}
