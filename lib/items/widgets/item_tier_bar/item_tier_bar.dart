import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../../theme/app_colors.dart';

class ItemTierBar extends StatelessWidget {
  final ItemTier? selectedTier;
  final ValueChanged<ItemTier?> onSelect;

  const ItemTierBar({
    super.key,
    required this.selectedTier,
    required this.onSelect,
  });

  static const _labels = {
    ItemTier.basic: 'Base',
    ItemTier.epic: 'Épique',
    ItemTier.legendary: 'Légendaire',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Tous',
            selected: selectedTier == null,
            onTap: () => onSelect(null),
          ),
          ...ItemTier.values.map((tier) {
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: _Chip(
                label: _labels[tier]!,
                selected: selectedTier == tier,
                onTap: () => onSelect(selectedTier == tier ? null : tier),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
