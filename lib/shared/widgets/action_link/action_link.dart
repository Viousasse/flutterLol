import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Bouton d'action secondaire, teinté à l'accent : une icône et un libellé court.
class ActionLink extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Phrase lue par les lecteurs d'écran, quand le libellé seul ne suffit pas.
  final String semanticLabel;
  final VoidCallback onTap;

  const ActionLink({
    super.key,
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppColors.accent),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.mono(size: 11, color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
