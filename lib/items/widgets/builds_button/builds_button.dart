import 'package:flutter/material.dart';

import '../../../builds/builds_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Raccourci de l'onglet Objets vers les builds enregistrées.
class BuildsButton extends StatelessWidget {
  const BuildsButton({super.key});

  void _open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BuildsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mes builds',
      excludeSemantics: true,
      onTap: () => _open(context),
      child: GestureDetector(
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 14, color: AppColors.accent),
              const SizedBox(width: 5),
              Text(
                'Builds',
                style: AppTheme.mono(size: 11, color: AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
