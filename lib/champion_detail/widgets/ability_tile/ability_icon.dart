import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_fonts.dart';
import '../../../theme/app_colors.dart';

class AbilityIcon extends StatelessWidget {
  final String label;
  final String imageUrl;

  const AbilityIcon({super.key, required this.label, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: RemoteImage(url: imageUrl, width: 44, height: 44),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: label == 'R' ? AppColors.accent : AppColors.background,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.accent, width: 1),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  color: label == 'R' ? AppColors.background : AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
