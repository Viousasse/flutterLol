import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/item_stack.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class ItemRelationTile extends StatelessWidget {
  final ItemStack stack;
  final VoidCallback onTap;

  const ItemRelationTile({super.key, required this.stack, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final item = stack.item;

    return SizedBox(
      width: 74,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          item.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              color: AppColors.background,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            );
                          },
                        ),
                      ),
                      if (!stack.isSingle)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _QuantityBadge(count: stack.count),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.gold}',
                  style: AppTheme.mono(size: 9.5, color: AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityBadge extends StatelessWidget {
  final int count;

  const _QuantityBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Text(
        '×$count',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.background,
        ),
      ),
    );
  }
}
