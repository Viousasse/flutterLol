import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/map_landmarks.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class MapLandmarkDetails extends StatelessWidget {
  final MapLandmark? landmark;

  const MapLandmarkDetails({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    final selected = landmark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: selected == null
          ? Text(
              'Touchez un point de la carte pour en savoir plus.',
              style: AppTheme.mono(size: 10, color: AppColors.textMuted),
            )
          : _Details(landmark: selected),
    );
  }
}

class _Details extends StatelessWidget {
  final MapLandmark landmark;

  const _Details({required this.landmark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: landmark.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(landmark.name, style: AppTheme.serif(size: 18)),
            ),
            Text(
              landmarkSideLabels[landmark.side]!,
              style: AppTheme.mono(size: 9, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          landmark.description,
          style: GoogleFonts.instrumentSans(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
