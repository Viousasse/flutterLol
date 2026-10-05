import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Texte long replié sur quelques lignes, avec un lien pour le lire en entier.
///
/// Sert aux histoires de champions : sans repli, elles repoussent les
/// capacités, les runes et les matchups loin sous l'écran.
class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int collapsedLines;

  const ExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.collapsedLines = 5,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.collapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        // Pas de lien quand tout le texte tient déjà dans l'espace replié.
        if (!painter.didExceedMaxLines) {
          return Text(widget.text, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: isExpanded ? null : widget.collapsedLines,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Semantics(
              button: true,
              expanded: isExpanded,
              label: isExpanded ? "Réduire l'histoire" : "Lire toute l'histoire",
              excludeSemantics: true,
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: GestureDetector(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    isExpanded ? 'Réduire' : 'Lire la suite',
                    style: AppTheme.mono(size: 11, color: AppColors.accent),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
