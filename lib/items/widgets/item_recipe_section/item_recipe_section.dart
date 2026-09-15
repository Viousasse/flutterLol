import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import '../../models/item.dart';
import '../../models/item_stack.dart';
import '../../../theme/app_colors.dart';
import '../item_relation_tile/item_relation_tile.dart';

class ItemRecipeSection extends StatelessWidget {
  final String title;
  final List<ItemStack> stacks;
  final ValueChanged<Item> onSelect;

  const ItemRecipeSection({
    super.key,
    required this.title,
    required this.stacks,
    required this.onSelect,
  });

  /// Le compteur annonce le nombre de pièces à acheter, pas le nombre de
  /// vignettes : deux Armures d'étoffe comptent pour deux.
  int get _pieceCount {
    return stacks.fold(0, (total, stack) => total + stack.count);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '$_pieceCount',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: stacks.map((stack) {
            return ItemRelationTile(
              stack: stack,
              onTap: () => onSelect(stack.item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
