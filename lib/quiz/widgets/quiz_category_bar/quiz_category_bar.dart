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
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          AppFilterChip(
            label: 'Tout',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...QuizCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: AppFilterChip(
                label: quizCategoryLabels[category]!,
                selected: selected == category,
                onTap: () => onSelect(selected == category ? null : category),
              ),
            );
          }),
        ],
      ),
    );
  }
}
