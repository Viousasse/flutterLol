import 'package:flutter/material.dart';

import '../../../shared/widgets/app_filter_chip/app_filter_chip.dart';
import '../../models/quiz_question.dart';

/// Choix de la famille de questions. « Tout » mélange les quatre.
class QuizCategoryBar extends StatelessWidget {
  final QuizCategory? selected;
  final ValueChanged<QuizCategory?> onSelect;

  const QuizCategoryBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Un Wrap plutôt qu'une liste horizontale : les cinq puces ne tiennent pas
    // sur une ligne à 375px, et il fallait alors faire défiler la barre pour
    // atteindre la dernière — la puce choisie se retrouvait coupée au bord.
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _chip(label: 'Tout', category: null),
        ...QuizCategory.values.map(
          (category) =>
              _chip(label: quizCategoryLabels[category]!, category: category),
        ),
      ],
    );
  }

  Widget _chip({required String label, required QuizCategory? category}) {
    return SizedBox(
      height: 32,
      child: AppFilterChip(
        label: label,
        selected: selected == category,
        onTap: () => onSelect(selected == category ? null : category),
      ),
    );
  }
}
