import 'package:flutter/material.dart';

/// Best practice responsive utility for mobile-first Android apps (2026).
/// Provides easy access to dimensions and safe scaling for different phone sizes.
extension ResponsiveContext on BuildContext {
  /// The total width of the screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The total height of the screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// The safe area top padding (e.g., notches, status bars).
  double get safeAreaTop => MediaQuery.paddingOf(this).top;

  /// The safe area bottom padding (e.g., navigation gesture areas).
  double get safeAreaBottom => MediaQuery.paddingOf(this).bottom;

  /// Returns true if the device is extremely narrow (e.g., small phones like SE).
  bool get isSmallPhone => screenWidth < 360;

  /// Returns true if the device has a tablet-sized width.
  bool get isTablet => screenWidth >= 600;

  /// Scales a value based on the screen width relative to a standard 390px phone.
  /// This ensures elements aren't too small on large phones or too large on small phones.
  double scaleWidth(double value) {
    return (screenWidth / 390) * value;
  }

  /// Scales a font size safely, preventing it from becoming unreadably large on tablets.
  double scaleFont(double value) {
    double scaled = (screenWidth / 390) * value;
    // Cap font scaling at 1.25x so tablets don't get comically huge text.
    return scaled > (value * 1.25) ? (value * 1.25) : scaled;
  }
}
