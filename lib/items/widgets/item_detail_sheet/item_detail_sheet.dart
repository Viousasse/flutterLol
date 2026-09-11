import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/item.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class ItemDetailSheet extends StatelessWidget {
  final Item item;

  const ItemDetailSheet({super.key, required this.item});

  static void show(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ItemDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(item.imageUrl, width: 54, height: 54),
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
                        Icon(Icons.circle, size: 9, color: AppColors.accent),
                        const SizedBox(width: 5),
                        Text(
                          '${item.gold} or',
                          style:
                              AppTheme.mono(size: 12, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: GoogleFonts.instrumentSans(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
