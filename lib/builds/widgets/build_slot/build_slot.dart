import 'package:flutter/material.dart';

import '../../../items/models/item.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Un des six emplacements d'une build : l'objet choisi avec un bouton pour le
/// retirer, ou une case vide qui invite à en choisir un.
class BuildSlot extends StatelessWidget {
  final Item? item;
  final int position;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const BuildSlot({
    super.key,
    required this.item,
    required this.position,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final chosen = item;
    final label = chosen == null
        ? 'Emplacement $position, vide, appuyer pour choisir un objet'
        : 'Emplacement $position, ${chosen.name}, appuyer pour changer';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 0.9,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: chosen == null ? AppColors.border : AppColors.accent,
              ),
            ),
            child: chosen == null
                ? Center(
                    child: Icon(
                      Icons.add,
                      color: AppColors.textMuted,
                      size: 26,
                    ),
                  )
                : _Filled(item: chosen, onClear: onClear),
          ),
        ),
      ),
    );
  }
}

class _Filled extends StatelessWidget {
  final Item item;
  final VoidCallback onClear;

  const _Filled({required this.item, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RemoteImage(url: item.imageUrl, width: 52, height: 52),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTheme.serif(size: 11),
            ),
          ],
        ),
        Positioned(
          top: -6,
          right: -6,
          child: IconButton(
            tooltip: 'Retirer ${item.name}',
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: Icon(Icons.close, size: 16, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
