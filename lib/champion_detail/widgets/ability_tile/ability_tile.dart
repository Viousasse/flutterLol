import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../champions/models/champion_detail.dart';
import '../../../theme/app_colors.dart';
import 'ability_icon.dart';

class AbilityTile extends StatelessWidget {
  final String label;
  final ChampionAbility ability;

  const AbilityTile({super.key, required this.label, required this.ability});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AbilityIcon(label: label, imageUrl: ability.imageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ability.name,
                  style: GoogleFonts.instrumentSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ability.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}