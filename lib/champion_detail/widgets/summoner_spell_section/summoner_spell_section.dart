import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../summoner_spells/models/summoner_spell.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Les deux sorts d'invocateur conseillés, avec leur effet et leur recharge, et
/// la raison du choix.
class SummonerSpellSection extends StatelessWidget {
  final List<SummonerSpell> spells;
  final String reason;

  const SummonerSpellSection({
    super.key,
    required this.spells,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final spell in spells) _SpellRow(spell: spell),
        const SizedBox(height: 4),
        Text(
          reason,
          style: AppTheme.serif(
            size: 12.5,
            italic: true,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SpellRow extends StatelessWidget {
  final SummonerSpell spell;

  const _SpellRow({required this.spell});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: RemoteImage(url: spell.imageUrl, width: 44, height: 44),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(spell.name, style: AppTheme.serif(size: 16)),
                    const SizedBox(width: 8),
                    if (spell.cooldown > 0)
                      Text(
                        '${spell.cooldown} s',
                        style: AppTheme.mono(
                          size: 10,
                          color: AppColors.accent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  spell.description,
                  style: AppTheme.serif(
                    size: 13,
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
