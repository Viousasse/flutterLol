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
  /// Les teintes du client de League of Legends : bleu nuit presque noir, or
  /// pâle pour l'accent, parchemin pour le texte.
  static const dark = AppPalette(
    background: Color(0xFF010A13),
    surface: Color(0xFF0A1428),
    accent: Color(0xFFC8AA6E),
    textPrimary: Color(0xFFF0E6D2),
    textSecondary: Color.fromRGBO(240, 230, 210, 0.62),
    textMuted: Color.fromRGBO(240, 230, 210, 0.55),
    border: Color.fromRGBO(200, 170, 110, 0.22),
    accentSoft: Color.fromRGBO(200, 170, 110, 0.14),
  );

  /// Parchemin et encre bleu nuit. L'or est assombri : l'or clair du mode
  /// sombre ne tiendrait pas le contraste 4,5:1 sur un fond clair.
  static const light = AppPalette(
    background: Color(0xFFF3EEE2),
    surface: Color(0xFFFBF8F1),
    accent: Color(0xFF7A5C1E),
    textPrimary: Color(0xFF0A1428),
    textSecondary: Color.fromRGBO(10, 20, 40, 0.74),
    textMuted: Color.fromRGBO(10, 20, 40, 0.64),
    border: Color.fromRGBO(120, 90, 40, 0.28),
    accentSoft: Color.fromRGBO(122, 92, 30, 0.12),
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
