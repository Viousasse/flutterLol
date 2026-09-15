import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF100C0B);
  static const surface = Color(0xFF191312);
  static const accent = Color(0xFFE07A5F);
  static const textPrimary = Color(0xFFF4EFEA);
  /// Déclinaisons translucides construites en `const` : `withOpacity`
  /// interdisait de marquer ces couleurs constantes, et par ricochet tous les
  /// widgets qui les utilisent.
  static const textSecondary = Color.fromRGBO(244, 239, 234, 0.55);
  static const textMuted = Color.fromRGBO(244, 239, 234, 0.35);
  static const border = Color.fromRGBO(244, 239, 234, 0.08);
  static const accentSoft = Color.fromRGBO(224, 122, 95, 0.14);
}
