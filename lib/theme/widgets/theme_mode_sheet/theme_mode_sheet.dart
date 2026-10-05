import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../app_theme.dart';
import '../../theme_service.dart';

class _ModeOption {
  final ThemeMode mode;
  final String label;
  final String hint;
  final IconData icon;

  const _ModeOption(this.mode, this.label, this.hint, this.icon);
}

const _options = [
  _ModeOption(
    ThemeMode.system,
    'Automatique',
    "Suit le réglage de l'appareil",
    Icons.brightness_auto,
  ),
  _ModeOption(
    ThemeMode.light,
    'Clair',
    'Fond clair, lisible en plein jour',
    Icons.light_mode_outlined,
  ),
  _ModeOption(
    ThemeMode.dark,
    'Sombre',
    'Fond sombre, reposant le soir',
    Icons.dark_mode_outlined,
  ),
];

/// Choix du mode d'affichage : automatique, clair ou sombre.
class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ThemeModeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.mode,
          builder: (context, current, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text('Affichage', style: AppTheme.serif(size: 20)),
              ),
              for (final option in _options)
                ListTile(
                  onTap: () => ThemeService.setMode(option.mode),
                  leading: Icon(option.icon, color: AppColors.accent),
                  title: Text(option.label, style: AppTheme.serif(size: 16)),
                  subtitle: Text(
                    option.hint,
                    style: AppTheme.serif(
                      size: 12.5,
                      italic: true,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: current == option.mode
                      ? Icon(Icons.check, color: AppColors.accent)
                      : null,
                  selected: current == option.mode,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
