import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Rectangle dont la teinte oscille doucement, posé à la place d'un contenu en
/// cours de chargement.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;

  const ShimmerBox({super.key, this.width, this.height});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  static const _pulse = Duration(milliseconds: 1100);

  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: _pulse,
  )..repeat(reverse: true);

  late final Animation<Color?> color = ColorTween(
    begin: AppColors.surface,
    end: Color.lerp(AppColors.surface, AppColors.textPrimary, 0.09),
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: color,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        color: color.value,
      ),
    );
  }
}
