import 'package:flutter/material.dart';

/// STEMWISE brand palette (spec §5). Do not introduce colors outside this set.
class AppColors {
  AppColors._();

  static const Color primaryDarkGreen = Color(0xFF062D28);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color darkGreen = Color(0xFF047857);
  static const Color lightGreen = Color(0xFFDFF7EA);
  static const Color veryLightGreen = Color(0xFFF0FDF4);

  static const Color white = Color(0xFFFFFFFF);
  static const Color pageBackground = Color(0xFFF8FAFC);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color purple = Color(0xFF7C3AED);

  // Dark theme surfaces (dedicated, not inverted — spec §44, §96).
  static const Color darkBackground = Color(0xFF03201C);
  static const Color darkSurface = Color(0xFF0A2E29);
  static const Color darkBorder = Color(0xFF1C4A43);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94B8AF);

  /// Debt-burden / score band colors — always paired with text, never color alone.
  static Color bandColor(String band) {
    switch (band) {
      case 'low':
        return success;
      case 'moderate':
        return primaryGreen;
      case 'elevated':
        return warning;
      case 'high':
        return danger;
      default:
        return textSecondary;
    }
  }

  static Color scoreColor(String classification) {
    switch (classification) {
      case 'strong':
        return success;
      case 'manageable':
        return primaryGreen;
      case 'attention':
        return warning;
      case 'pressure':
        return danger;
      default:
        return textSecondary;
    }
  }
}
