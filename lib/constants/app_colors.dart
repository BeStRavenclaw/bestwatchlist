import 'package:flutter/material.dart';

/// Centralized color definitions for the app
/// Provides consistent colors throughout the application
abstract class AppColors {
  // ============ Primary Colors ============
  /// Gold - Primary brand color
  static const Color gold = Color(0xFFD4AF37);

  /// Deep black - Secondary/accent color
  static const Color black = Color(0xFF1A1A1A);

  /// Very dark background for dark mode
  static const Color darkBackground = Color(0xFF0D0D0D);

  /// Subtle border color for dark mode cards
  static const Color darkBorder = Color(0xFF2A2A2A);

  // ============ Semantic Colors ============
  /// Destructive actions (delete, clear, etc.)
  static const Color destructive = Colors.red;

  /// Bookmark/watchlist active state
  static const Color bookmarkActive = Colors.deepPurple;

  /// Want to rewatch status
  static const Color rewatch = Colors.orange;

  /// Save for streaming status
  static const Color streaming = Colors.blue;

  // ============ Neutral Colors ============
  /// Unselected navigation items (light mode)
  static const Color unselectedLight = Color(0xFF888888);

  /// Unselected navigation items (dark mode)
  static const Color unselectedDark = Color(0xFF666666);

  // ============ Helper Methods ============
  /// Get gold color with specified opacity
  static Color goldWithOpacity(double opacity) =>
      gold.withValues(alpha: opacity);

  /// Get black color with specified opacity
  static Color blackWithOpacity(double opacity) =>
      black.withValues(alpha: opacity);
}
