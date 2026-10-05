# Contrat : API publique du thème

## `lib/theme/app_colors.dart`

```dart
class AppPalette {
  final Color background, surface, accent, textPrimary,
      textSecondary, textMuted, border, accentSoft;
  const AppPalette({required ...});
  static const AppPalette dark;
  static const AppPalette light;
}

class AppColors {
  static void use(Brightness brightness);   // change la palette active
  static bool get isDark;
  static Color get background, surface, accent, textPrimary,
      textSecondary, textMuted, border, accentSoft;
}
```

Les couleurs ne sont pas des constantes : tout widget les lit à la construction. `AppPalette.dark` peut être utilisée directement quand un widget doit rester sombre dans les deux modes (cas de `ChampionHeroCard`).

## `lib/theme/app_theme.dart`

```dart
class AppTheme {
  static ThemeData get theme;                       // thème du mode actif
  static ThemeData themeFor(Brightness brightness);
  static TextStyle serif({double size = 16, FontWeight weight = FontWeight.w400,
      Color? color, bool italic = false});
  static TextStyle mono({double size = 10, Color? color, double letterSpacing = 1.0});
}
```

## `lib/theme/theme_service.dart`

```dart
class ThemeService {
  static final ValueNotifier<ThemeMode> mode;       // défaut ThemeMode.system
  static Future<void> ensureLoaded();               // idempotent, tolère un stockage en panne
  static Future<void> setMode(ThemeMode next);      // applique puis persiste (clé 'theme_mode')
  static Brightness resolve(ThemeMode chosen, Brightness device);
}
```

## `lib/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart`

```dart
class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});
  static Future<void> show(BuildContext context);   // feuille modale « Affichage »
}
```

Contrat d'affichage : titre « Affichage » en en-tête sémantique, trois lignes (Automatique, Clair, Sombre), coche et `selected` sur le mode courant ; un appui appelle `ThemeService.setMode`.
