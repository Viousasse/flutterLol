import 'package:flutter/material.dart';
import '../../constants/map_landmarks.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class MapLandmarkMarker extends StatelessWidget {
  final MapLandmark landmark;
  final bool selected;
  final VoidCallback onTap;

  const MapLandmarkMarker({
    super.key,
    required this.landmark,
    required this.selected,
    required this.onTap,
  });

  /// Largeur réservée à l'étiquette. Le point se trouve au centre horizontal
  /// et tout en haut : c'est sur lui que la carte aligne les coordonnées.
  static const width = 70.0;

  static const dotRadius = 5.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: landmark.color, selected: selected),
            const SizedBox(height: 2),
            _Label(landmark: landmark, selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final bool selected;

  const _Dot({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    const diameter = MapLandmarkMarker.dotRadius * 2;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.textPrimary : AppColors.background,
          width: selected ? 2 : 1.5,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final MapLandmark landmark;
  final bool selected;

  const _Label({required this.landmark, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(selected ? 0.92 : 0.7),
        borderRadius: BorderRadius.circular(4),
        border: selected ? Border.all(color: landmark.color) : null,
      ),
      child: Text(
        landmark.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.mono(
          size: 8,
          letterSpacing: 0.2,
          color: selected ? landmark.color : AppColors.textPrimary,
        ),
      ),
    );
  }
}
