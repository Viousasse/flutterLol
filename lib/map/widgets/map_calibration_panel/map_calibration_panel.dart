import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Affiche les coordonnées relatives d'un appui, pour replacer un lieu sans
/// tâtonner : on touche l'endroit voulu sur la carte et on recopie les deux
/// nombres dans map_landmarks.dart.
class MapCalibrationPanel extends StatelessWidget {
  final Offset? point;

  const MapCalibrationPanel({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    final tapped = point;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calibrage', style: AppTheme.serif(size: 16)),
          const SizedBox(height: 6),
          Text(
            tapped == null
                ? 'Touchez un endroit de la carte pour lire ses coordonnées.'
                : 'x: ${tapped.dx.toStringAsFixed(3)}   '
                    'y: ${tapped.dy.toStringAsFixed(3)}',
            style: AppTheme.mono(size: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
