import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../../shared/widgets/app_filter_chip/app_filter_chip.dart';

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
          AppFilterChip(
            label: 'Tous',
            selected: selectedTier == null,
            onTap: () => onSelect(null),
          ),
          ...ItemTier.values.map((tier) {
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: AppFilterChip(
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
