import 'package:flutter/material.dart';

import '../../../shared/widgets/remote_image/remote_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../models/quiz_question.dart';

const quizCorrectColor = Color(0xFF6FCF97);
const quizWrongColor = Color(0xFFEB5757);

enum QuizAnswerState {
  /// Pas encore répondu : la proposition est cliquable.
  open,

  /// La bonne réponse, révélée.
  correct,

  /// Ce que l'on avait choisi, et qui était faux.
  wrong,

  /// Une autre proposition, après réponse.
  dimmed,
}

class QuizAnswerButton extends StatelessWidget {
  final QuizOptionData option;
  final QuizAnswerState state;
  final VoidCallback onTap;

  const QuizAnswerButton({
    super.key,
    required this.option,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (borderColor, textColor, background) = switch (state) {
      QuizAnswerState.open => (
        AppColors.border,
        AppColors.textPrimary,
        Colors.transparent,
      ),
      QuizAnswerState.correct => (
        quizCorrectColor,
        quizCorrectColor,
        quizCorrectColor.withValues(alpha: 0.12),
      ),
      QuizAnswerState.wrong => (
        quizWrongColor,
        quizWrongColor,
        quizWrongColor.withValues(alpha: 0.12),
      ),
      QuizAnswerState.dimmed => (
        AppColors.border,
        AppColors.textMuted,
        Colors.transparent,
      ),
    };

    final thumbnail = option.imageUrl;

    return GestureDetector(
      onTap: state == QuizAnswerState.open ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            if (thumbnail != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: RemoteImage(url: thumbnail, width: 34, height: 34),
              ),
              const SizedBox(width: 11),
            ],
            Expanded(
              child: Text(
                option.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (state == QuizAnswerState.correct)
              const Icon(Icons.check, size: 16, color: quizCorrectColor),
            if (state == QuizAnswerState.wrong)
              const Icon(Icons.close, size: 16, color: quizWrongColor),
          ],
        ),
      ),
    );
  }
}
