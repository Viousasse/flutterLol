import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Emplacement d'un des deux champions : son portrait une fois choisi, une
/// invitation à en choisir un sinon. Un appui rouvre le choix.
class CompareSlot extends StatelessWidget {
  final Champion? champion;
  final String emptyLabel;
  final VoidCallback onTap;

  const CompareSlot({
    super.key,
    required this.champion,
    required this.emptyLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = champion;
    final label = selected == null
        ? emptyLabel
        : '${selected.name}, appuyer pour changer';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 0.82,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: selected == null
                ? _Empty(label: emptyLabel)
                : _Filled(champion: selected),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String label;

  const _Empty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle_outline, color: AppColors.accent, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.mono(size: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Filled extends StatelessWidget {
  final Champion champion;

  const _Filled({required this.champion});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RemoteImage(url: champion.portraitUrl, alignment: Alignment.topCenter),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.5, 1.0],
              colors: [
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: Text(champion.name, style: AppTheme.serif(size: 18)),
        ),
      ],
    );
  }
}
