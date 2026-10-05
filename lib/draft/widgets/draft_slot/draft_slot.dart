import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Un rôle d'un camp : le champion choisi, ou une case vide. Quand [onTap] est
/// fourni, la case invite à choisir.
class DraftSlot extends StatelessWidget {
  final String role;
  final Champion? champion;
  final VoidCallback? onTap;

  const DraftSlot({
    super.key,
    required this.role,
    required this.champion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final picked = champion;
    final isPickable = onTap != null && picked == null;

    final label = picked != null
        ? '$role : ${picked.name}'
        : isPickable
        ? '$role, vide, appuyer pour choisir un champion'
        : '$role, pas encore choisi';

    return Semantics(
      button: isPickable,
      label: label,
      excludeSemantics: true,
      onTap: isPickable ? onTap : null,
      child: GestureDetector(
        onTap: isPickable ? onTap : null,
        child: Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPickable
                  ? AppColors.accent
                  : picked != null
                  ? AppColors.accent.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              if (picked != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: RemoteImage(
                    url: picked.imageUrl,
                    width: 34,
                    height: 34,
                  ),
                )
              else
                Icon(
                  isPickable ? Icons.add_circle_outline : Icons.more_horiz,
                  size: 24,
                  color: isPickable ? AppColors.accent : AppColors.textMuted,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.toUpperCase(),
                      style: AppTheme.mono(
                        size: 8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      picked?.name ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.serif(size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
