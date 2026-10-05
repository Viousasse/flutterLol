import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/theme/app_colors.dart';

/// Rapport de contraste WCAG entre deux couleurs opaques.
double _contrast(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;

  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

/// Texte translucide posé sur son fond, tel qu'on le voit à l'écran.
double _textOn(Color text, Color background) =>
    _contrast(Color.alphaBlend(text, background), background);

void main() {
  const minimum = 4.5;
  final palettes = {'sombre': AppPalette.dark, 'clair': AppPalette.light};

  for (final entry in palettes.entries) {
    final palette = entry.value;

    test(
      'texte discret lisible sur fond, carte et puce choisie (${entry.key})',
      () {
        final selectedChip = Color.alphaBlend(
          palette.accentSoft,
          palette.background,
        );

        for (final background in [
          palette.background,
          palette.surface,
          selectedChip,
        ]) {
          expect(
            _textOn(palette.textMuted, background),
            greaterThanOrEqualTo(minimum),
          );
          expect(
            _textOn(palette.textSecondary, background),
            greaterThanOrEqualTo(minimum),
          );
        }
      },
    );

    test('l accent reste lisible sur une puce choisie (${entry.key})', () {
      final selectedChip = Color.alphaBlend(
        palette.accentSoft,
        palette.background,
      );

      expect(
        _contrast(palette.accent, selectedChip),
        greaterThanOrEqualTo(minimum),
      );
    });
  }
}
