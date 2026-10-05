import 'package:flutter/material.dart';

import '../../../items/constants/item_slots.dart';
import '../../../items/models/item.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';

/// Les objets équipés par un champion, sous son portrait : chaque objet se
/// retire d'un appui, et une case « + » permet d'en ajouter jusqu'à six.
class CompareItemSlots extends StatelessWidget {
  static const _slotSize = 40.0;

  final List<Item> items;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveAt;

  const CompareItemSlots({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onRemoveAt,
  });

  bool get _canAdd => items.length < maxItemSlots;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var index = 0; index < items.length; index++)
          _FilledSlot(
            item: items[index],
            size: _slotSize,
            onRemove: () => onRemoveAt(index),
          ),
        if (_canAdd) _AddSlot(size: _slotSize, onTap: onAdd),
      ],
    );
  }
}

class _FilledSlot extends StatelessWidget {
  final Item item;
  final double size;
  final VoidCallback onRemove;

  const _FilledSlot({
    required this.item,
    required this.size,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retirer ${item.name}',
      excludeSemantics: true,
      onTap: onRemove,
      child: GestureDetector(
        onTap: onRemove,
        child: Tooltip(
          message: 'Retirer ${item.name}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RemoteImage(url: item.imageUrl, width: size, height: size),
          ),
        ),
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const _AddSlot({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajouter un objet',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
          ),
          child: const Icon(Icons.add, size: 18, color: AppColors.accent),
        ),
      ),
    );
  }
}
