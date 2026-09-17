import 'package:flutter/material.dart';

import '../champions/services/champion_service.dart';
import '../items/services/item_service.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'models/quiz_question.dart';
import 'services/quiz_generator.dart';
import 'services/quiz_score_service.dart';
import 'widgets/quiz_category_bar/quiz_category_bar.dart';
import 'widgets/quiz_question_card/quiz_question_card.dart';
import 'widgets/quiz_score_bar/quiz_score_bar.dart';

/// Quiz sans fin : les questions sont tirées des données déjà chargées par
/// l'app — champions, régions officielles, objets et matchups réels.
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizGenerator? generator;
  bool isLoading = true;
  String? errorMessage;

  QuizCategory? category;
  QuizQuestion? question;
  int? chosenIndex;

  int streak = 0;
  int correct = 0;
  int answered = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Lancés ensemble, récupérés typés : Future.wait aurait rendu une liste
      // d'Object? qu'il aurait fallu recaster.
      final championsRequest = ChampionService.fetchAll();
      final itemsRequest = ItemService.fetchAll();
      final matchupsRequest = MatchupService.load();
      final scoreRequest = QuizScoreService.ensureLoaded();

      final data = QuizData(
        champions: await championsRequest,
        items: await itemsRequest,
        matchups: await matchupsRequest,
      );
      await scoreRequest;

      if (!mounted) return;
      setState(() {
        generator = QuizGenerator(data);
        isLoading = false;
      });
      _draw();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isLoading = false;
      });
    }
  }

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadData();
  }

  void _draw() {
    setState(() {
      question = generator?.next(category: category, avoid: question);
      chosenIndex = null;
    });
  }

  void _selectCategory(QuizCategory? next) {
    setState(() => category = next);
    _draw();
  }

  Future<void> _answer(int index) async {
    final current = question;
    if (current == null || chosenIndex != null) return;

    final right = index == current.answerIndex;
    final nextStreak = right ? streak + 1 : 0;

    setState(() {
      chosenIndex = index;
      answered++;
      if (right) correct++;
      streak = nextStreak;
    });

    if (right) await QuizScoreService.submit(nextStreak);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('Quiz', style: AppTheme.serif(size: 32)),
            const SizedBox(height: 4),
            Text(
              'Testez vos connaissances',
              style: AppTheme.mono(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            ..._body(),
          ],
        ),
      ),
    );
  }

  List<Widget> _body() {
    final failure = errorMessage;
    if (failure != null) {
      return [ErrorRetryView(message: failure, onRetry: retry)];
    }

    if (isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    final current = question;

    return [
      QuizScoreBar(streak: streak, correct: correct, answered: answered),
      const SizedBox(height: 12),
      QuizCategoryBar(selected: category, onSelect: _selectCategory),
      const SizedBox(height: 14),
      if (current == null)
        _NoQuestion(onRetry: _draw)
      else
        QuizQuestionCard(
          question: current,
          chosenIndex: chosenIndex,
          onAnswer: _answer,
          onNext: _draw,
        ),
    ];
  }
}

class _NoQuestion extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoQuestion({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Aucune question disponible dans cette catégorie. '
          'Touchez pour réessayer.',
          style: AppTheme.mono(size: 9.5, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
