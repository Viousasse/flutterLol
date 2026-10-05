import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Une ligne de l'équipe : le rôle à tenir et le champion qui l'occupe, ou une
/// invitation à en choisir un.
class TeamSlot extends StatelessWidget {
  final String role;
  final Champion? champion;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const TeamSlot({
    super.key,
    required this.role,
    required this.champion,
    required this.isLoading,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final selected = champion;
    final label = selected == null
        ? '$role, vide, appuyer pour choisir un champion'
        : '$role, ${selected.name}, appuyer pour changer';

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            onTap: onTap,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == null
                        ? AppColors.border
                        : AppColors.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 62,
                      child: Text(
                        role.toUpperCase(),
                        style: AppTheme.mono(size: 9, color: AppColors.accent),
                      ),
                    ),
                    if (selected != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RemoteImage(
                          url: selected.imageUrl,
                          width: 40,
                          height: 40,
                        ),
                      )
                    else
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textMuted,
                        size: 28,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selected?.name ?? 'Choisir un champion',
                        style: AppTheme.serif(
                          size: 16,
                          color: selected == null
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (selected != null)
          IconButton(
            tooltip: 'Retirer ${selected.name}',
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}
