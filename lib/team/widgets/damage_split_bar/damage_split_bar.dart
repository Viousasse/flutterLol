import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

const _physicalColor = Color(0xFFE07A5F);
const _magicColor = Color(0xFF7AA2E0);

/// Répartition des dégâts de l'équipe entre physiques et magiques, en une barre
/// à deux couleurs et en pourcentages écrits.
class DamageSplitBar extends StatelessWidget {
  final double physicalShare;
  final double magicShare;

  const DamageSplitBar({
    super.key,
    required this.physicalShare,
    required this.magicShare,
  });

  int _percent(double share) => (share * 100).round();

  @override
  Widget build(BuildContext context) {
    final hasDamage = physicalShare + magicShare > 0;

    return Semantics(
      label:
          'Dégâts : ${_percent(physicalShare)} % physiques, '
          '${_percent(magicShare)} % magiques',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: hasDamage
                  ? Row(
                      children: [
                        // Un segment de 0 % n'est pas dessiné : un `Expanded` de
                        // flex 0 n'a pas de largeur définie.
                        if (_percent(physicalShare) > 0)
                          Expanded(
                            flex: _percent(physicalShare),
                            child: const ColoredBox(color: _physicalColor),
                          ),
                        if (_percent(magicShare) > 0)
                          Expanded(
                            flex: _percent(magicShare),
                            child: const ColoredBox(color: _magicColor),
                          ),
                      ],
                    )
                  : ColoredBox(
                      color: AppColors.textPrimary.withValues(alpha: 0.08),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Physiques ${_percent(physicalShare)} %',
                style: AppTheme.mono(size: 10, color: _physicalColor),
              ),
              Text(
                'Magiques ${_percent(magicShare)} %',
                style: AppTheme.mono(size: 10, color: _magicColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
