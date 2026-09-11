import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

enum ItemSort { name, priceAsc, priceDesc }

class ItemSortButton extends StatelessWidget {
  final ItemSort current;
  final ValueChanged<ItemSort> onChanged;

  const ItemSortButton({
    super.key,
    required this.current,
    required this.onChanged,
  });

  String get _label {
    switch (current) {
      case ItemSort.name:
        return 'A-Z';
      case ItemSort.priceAsc:
        return 'Moins cher';
      case ItemSort.priceDesc:
        return 'Plus cher';
    }
  }

  IconData get _icon {
    switch (current) {
      case ItemSort.name:
        return Icons.sort_by_alpha;
      case ItemSort.priceAsc:
        return Icons.arrow_upward;
      case ItemSort.priceDesc:
        return Icons.arrow_downward;
    }
  }

  ItemSort get _next {
    switch (current) {
      case ItemSort.name:
        return ItemSort.priceAsc;
      case ItemSort.priceAsc:
        return ItemSort.priceDesc;
      case ItemSort.priceDesc:
        return ItemSort.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(_next),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(_icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 5),
            Text(_label, style: AppTheme.mono(size: 11, color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}
