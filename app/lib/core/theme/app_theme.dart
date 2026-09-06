import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Design tokens (spec §7, §8).
class AppRadius {
  AppRadius._();
  static const double largeCard = 20;
  static const double card = 16;
  static const double button = 12;
  static const double input = 12;
  static const double pill = 999;
}

class AppShadows {
  AppShadows._();
  // Extremely subtle (spec §8).
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 20, offset: Offset(0, 4)),
  ];
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double maxContentWidth = 1200;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    return _build(
      base: base,
      textTheme: textTheme,
      scaffold: AppColors.pageBackground,
      surface: AppColors.white,
      border: AppColors.border,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
    );
  }

  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    );
    return _build(
      base: base,
      textTheme: textTheme,
      scaffold: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      border: AppColors.darkBorder,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
    );
  }

  static ThemeData _build({
    required ThemeData base,
    required TextTheme textTheme,
    required Color scaffold,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: base.brightness,
      primary: AppColors.primaryGreen,
      surface: surface,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.primaryGreen,
        inactiveTrackColor: border,
        thumbColor: AppColors.primaryGreen,
        overlayColor: AppColors.primaryGreen.withValues(alpha: 0.12),
      ),
    );
  }
}
