import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class MapPlaceholder extends StatelessWidget {
  final String message;

  const MapPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          message,
          style: AppTheme.mono(size: 11, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
