import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = ThemeData.dark().textTheme.apply(
      fontFamily: AppFonts.sans,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.serif,
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerColor: AppColors.border,
    );
  }

  static TextStyle serif({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color? color,
    bool italic = false,
  }) {
    return TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: size,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle mono({
    double size = 10,
    Color? color,
    double letterSpacing = 1.0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: size,
      fontWeight: FontWeight.w500,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.textMuted,
    );
  }
}
