import 'package:flutter/material.dart';

/// Les neuf couleurs de l'interface pour un mode donné.
class AppPalette {
  final Color background;
  final Color surface;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color accentSoft;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.accentSoft,
  });

  /// À 0,5 d'opacité le texte atteint le rapport de contraste 4,5:1 exigé par
  /// le RGAA sur le fond sombre ; à 0,35 il restait à 3:1 environ.
  static const dark = AppPalette(
    background: Color(0xFF100C0B),
    surface: Color(0xFF191312),
    accent: Color(0xFFE07A5F),
    textPrimary: Color(0xFFF4EFEA),
    textSecondary: Color.fromRGBO(244, 239, 234, 0.55),
    textMuted: Color.fromRGBO(244, 239, 234, 0.5),
    border: Color.fromRGBO(244, 239, 234, 0.08),
    accentSoft: Color.fromRGBO(224, 122, 95, 0.14),
  );

  /// Fond chaud et encre sombre. L'accent est plus foncé que sur fond sombre :
  /// le corail clair ne tiendrait pas le contraste 4,5:1 sur un fond clair.
  static const light = AppPalette(
    background: Color(0xFFF7F2EC),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFFB8452B),
    textPrimary: Color(0xFF1B1412),
    textSecondary: Color.fromRGBO(27, 20, 18, 0.72),
    textMuted: Color.fromRGBO(27, 20, 18, 0.62),
    border: Color.fromRGBO(27, 20, 18, 0.12),
    accentSoft: Color.fromRGBO(184, 69, 43, 0.12),
  );
}

/// Couleurs de l'interface, lues à la volée dans la palette du mode actif.
///
/// Ce ne sont plus des constantes : elles changent avec le mode clair ou
/// sombre. Le changement de mode force la reconstruction de tout l'arbre (voir
/// `ThemeService`), ce qui fait relire ces valeurs partout.
class AppColors {
  static AppPalette _palette = AppPalette.dark;

  static void use(Brightness brightness) {
    _palette = brightness == Brightness.dark
        ? AppPalette.dark
        : AppPalette.light;
  }

  static bool get isDark => identical(_palette, AppPalette.dark);

  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get accent => _palette.accent;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get textMuted => _palette.textMuted;
  static Color get border => _palette.border;
  static Color get accentSoft => _palette.accentSoft;
}
