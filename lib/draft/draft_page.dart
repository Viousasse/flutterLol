import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../team/constants/team_roles.dart';
import '../team/models/team_member.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'models/draft_report.dart';
import 'models/draft_state.dart';
import 'services/draft_bot.dart';
import 'services/draft_evaluator.dart';
import 'widgets/draft_report_view/draft_report_view.dart';
import 'widgets/draft_slot/draft_slot.dart';

/// Délai avant que le site joue son choix : sans lui, la draft se déroulerait
/// d'un seul coup et on ne verrait pas qui choisit quoi.
const _botThinkingDelay = Duration(milliseconds: 900);

/// Entraîneur de draft : le joueur et le site choisissent à tour de rôle, puis
/// l'application compare les deux drafts et dit laquelle est meilleure.
class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  List<Champion> champions = const [];
  MatchupDataset dataset = const MatchupDataset.empty();
  DraftBot? bot;

  DraftState state = DraftState.empty();
  bool isLoading = true;
  bool isBotThinking = false;
  bool isAnalysing = false;
  DraftReport? report;
  String? errorMessage;

  /// Numéro de la partie en cours. Un tour du site lancé avant un
  /// « Recommencer » ne doit pas s'appliquer à la nouvelle partie.
  int generation = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final championsRequest = ChampionService.fetchAll();
      final datasetRequest = MatchupService.load();

      final loadedChampions = await championsRequest;
      final loadedDataset = await datasetRequest;

      if (!mounted) return;
      setState(() {
        champions = loadedChampions;
        dataset = loadedDataset;
        bot = DraftBot(dataset: loadedDataset);
        isLoading = false;
      });
      advance();
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

  void restart() {
    setState(() {
      generation++;
      state = DraftState.empty();
      isBotThinking = false;
      isAnalysing = false;
      report = null;
      errorMessage = null;
    });
    advance();
  }

  /// Fait avancer la draft : le site joue quand c'est son tour, l'analyse part
  /// quand tout est choisi, et le joueur n'a rien à lancer le reste du temps.
  void advance() {
    if (state.isComplete) {
      analyse();
    } else if (state.nextSide == DraftSide.red) {
      playBotTurn();
    }
  }

  Future<void> playBotTurn() async {
    final currentGeneration = generation;
    setState(() => isBotThinking = true);

    await Future<void>.delayed(_botThinkingDelay);
    if (!mounted || currentGeneration != generation) return;

    final choice = bot!.choose(
      state: state,
      side: DraftSide.red,
      pool: champions,
    );

    setState(() {
      state = state.pick(DraftSide.red, choice.roleIndex, choice.champion);
      isBotThinking = false;
    });
    advance();
  }

  Future<void> pickForYou(int roleIndex) async {
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedIds: state.pickedIds,
    );
    if (chosen == null || !mounted) return;
    if (state.nextSide != DraftSide.blue) return;

    setState(() {
      state = state.pick(DraftSide.blue, roleIndex, chosen);
    });
    advance();
  }

  /// Télécharge les fiches des dix champions (jauges et sorts), puis compare
  /// les deux drafts.
  Future<void> analyse() async {
    final currentGeneration = generation;
    setState(() {
      isAnalysing = true;
      errorMessage = null;
    });

    try {
      final blueMembers = await _members(DraftSide.blue);
      final redMembers = await _members(DraftSide.red);

      if (!mounted || currentGeneration != generation) return;
      setState(() {
        report = DraftEvaluator.evaluate(
          blue: blueMembers,
          red: redMembers,
          dataset: dataset,
          championNames: {for (final c in champions) c.id: c.name},
        );
        isAnalysing = false;
      });
    } catch (error) {
      if (!mounted || currentGeneration != generation) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isAnalysing = false;
      });
    }
  }

  Future<List<TeamMember>> _members(DraftSide side) async {
    final team = state.teamOf(side).whereType<Champion>().toList();
    final details = await Future.wait(
      team.map((champion) => ChampionService.fetchDetail(champion.id)),
    );

    return [
      for (var index = 0; index < team.length; index++)
        TeamMember(champion: team[index], detail: details[index]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entraîneur de draft', style: AppTheme.serif(size: 24)),
        actions: [
          if (!isLoading && state.pickCount > 0)
            IconButton(
              tooltip: 'Recommencer la draft',
              onPressed: restart,
              icon: const Icon(Icons.restart_alt),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bot == null) {
      return ErrorRetryView(
        message: errorMessage ?? 'Chargement impossible pour le moment.',
        onRetry: retry,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _StatusCard(
          state: state,
          isBotThinking: isBotThinking,
          isAnalysing: isAnalysing,
        ),
        const SizedBox(height: 16),
        _board(),
        const SizedBox(height: 20),
        ..._result(),
      ],
    );
  }

  Widget _board() {
    final yourTurn = state.nextSide == DraftSide.blue && !isBotThinking;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TeamColumn(
            title: 'VOUS',
            champions: state.blue,
            onPick: yourTurn ? pickForYou : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TeamColumn(title: 'SITE', champions: state.red),
        ),
      ],
    );
  }

  List<Widget> _result() {
    final failure = errorMessage;
    if (failure != null) {
      return [ErrorRetryView(message: failure, onRetry: analyse)];
    }

    if (isAnalysing) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    final finished = report;
    if (finished == null) {
      return [
        Text(
          'Choisissez un champion pour le rôle de votre choix quand c’est à '
          'vous. Le site répond, puis la draft est comparée à la fin.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        ),
      ];
    }

    return [
      DraftReportView(report: finished),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: restart,
        icon: const Icon(Icons.restart_alt),
        label: const Text('Refaire une draft'),
      ),
    ];
  }
}

class _TeamColumn extends StatelessWidget {
  final String title;
  final List<Champion?> champions;
  final ValueChanged<int>? onPick;

  const _TeamColumn({
    required this.title,
    required this.champions,
    this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: AppTheme.mono(size: 10, color: AppColors.accent),
          ),
        ),
        for (var index = 0; index < teamRoles.length; index++)
          DraftSlot(
            role: teamRoles[index],
            champion: champions[index],
            onTap: onPick == null ? null : () => onPick!(index),
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final DraftState state;
  final bool isBotThinking;
  final bool isAnalysing;

  const _StatusCard({
    required this.state,
    required this.isBotThinking,
    required this.isAnalysing,
  });

  String get _message {
    if (state.isComplete) {
      return isAnalysing ? 'Analyse des deux drafts…' : 'Draft terminée.';
    }
    if (isBotThinking) return 'Le site choisit…';

    final step = state.pickCount + 1;
    final count = draftPickOrder.length;

    return 'À vous de choisir (choix $step sur $count). Appuyez sur un rôle '
        'libre.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (isBotThinking || isAnalysing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(Icons.flag_outlined, size: 18, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(_message, style: AppTheme.serif(size: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
