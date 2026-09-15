import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class ItemDetailHeader extends StatelessWidget {
  final Item item;
  final VoidCallback? onBack;

  const ItemDetailHeader({super.key, required this.item, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          IconButton(
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
            tooltip: 'Revenir à l\'objet précédent',
            icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.textMuted),
          ),
          const SizedBox(width: 2),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.imageUrl,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                color: AppColors.background,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: AppTheme.serif(size: 20)),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.circle, size: 9, color: AppColors.accent),
                  const SizedBox(width: 5),
                  Text(
                    '${item.gold} or',
                    style: AppTheme.mono(size: 12, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
