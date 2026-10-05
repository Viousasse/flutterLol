import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/theme/app_colors.dart';

/// Mélange une couleur translucide sur son fond, comme à l'écran.
Color _over(Color foreground, Color background) {
  return Color.alphaBlend(foreground, background);
}

/// Rapport de contraste WCAG entre deux couleurs opaques.
double _contrast(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;

  return (lighter.computeLuminance() + 0.05) / (darker.computeLuminance() + 0.05);
}

/// Seuil du RGAA pour un texte courant.
const _minimumContrast = 4.5;

void main() {
  final palettes = {'sombre': AppPalette.dark, 'clair': AppPalette.light};

  for (final entry in palettes.entries) {
    final palette = entry.value;

    group('palette ${entry.key}', () {
      test('le texte principal est lisible sur le fond et sur les cartes', () {
        for (final background in [palette.background, palette.surface]) {
          expect(
            _contrast(_over(palette.textPrimary, background), background),
            greaterThanOrEqualTo(_minimumContrast),
          );
        }
      });

      test('les textes secondaire et discret tiennent 4,5:1', () {
        for (final background in [palette.background, palette.surface]) {
          for (final text in [palette.textSecondary, palette.textMuted]) {
            expect(
              _contrast(_over(text, background), background),
              greaterThanOrEqualTo(_minimumContrast),
              reason: 'sur ${background.toARGB32().toRadixString(16)}',
            );
          }
        }
      });

      test('l accent est lisible en texte sur le fond et sur les cartes', () {
        for (final background in [palette.background, palette.surface]) {
          expect(
            _contrast(palette.accent, background),
            greaterThanOrEqualTo(_minimumContrast),
          );
        }
      });
    });
  }

  test('le mode actif est celui demandé', () {
    AppColors.use(Brightness.light);
    expect(AppColors.isDark, isFalse);
    expect(AppColors.background, AppPalette.light.background);

    AppColors.use(Brightness.dark);
    expect(AppColors.isDark, isTrue);
    expect(AppColors.background, AppPalette.dark.background);
  });
}
