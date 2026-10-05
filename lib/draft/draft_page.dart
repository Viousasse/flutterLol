import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../shared/services/clipboard_copy/clipboard_copy.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../team/constants/team_roles.dart';
import '../team/models/team_member.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'draft_history_page.dart';
import 'models/draft_mode.dart';
import 'models/draft_record.dart';
import 'models/draft_report.dart';
import 'models/draft_state.dart';
import 'services/draft_bot.dart';
import 'services/draft_evaluator.dart';
import 'services/draft_history_store.dart';
import 'services/draft_share_text.dart';
import 'widgets/ban_row/ban_row.dart';
import 'widgets/draft_report_view/draft_report_view.dart';
import 'widgets/draft_slot/draft_slot.dart';
import 'widgets/player_name_dialog/player_name_dialog.dart';

/// Délai avant que le site joue son choix : sans lui, la draft se déroulerait
/// d'un seul coup et on ne verrait pas qui choisit quoi.
const _botThinkingDelay = Duration(milliseconds: 900);

/// Entraîneur de draft : le joueur et le site (ou un ami, en mode à deux)
/// choisissent à tour de rôle, puis
/// l'application compare les deux drafts et dit laquelle est meilleure.
class DraftPage extends StatefulWidget {
  final DraftMode mode;

  const DraftPage({super.key, this.mode = DraftMode.vsSite});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  List<Champion> champions = const [];
  MatchupDataset dataset = const MatchupDataset.empty();
  DraftBot? bot;

  /// Les joueurs d'un duel, ou `null` contre le site. Leurs noms se modifient
  /// en touchant le titre de leur colonne.
  late DraftPlayers? players = widget.mode.players;

  /// Les bannissements ouvrent la draft, comme en partie classée. On peut les
  /// retirer tant que rien n'a été joué.
  bool withBans = true;

  late DraftState state = DraftState.empty(withBans: withBans);
  bool isLoading = true;
  bool isBotThinking = false;
  bool isAnalysing = false;
  DraftReport? report;

  /// La draft terminée telle qu'elle est gardée dans l'historique et partagée.
  DraftRecord? record;
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
      state = DraftState.empty(withBans: withBans);
      record = null;
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
    } else if (widget.mode == DraftMode.vsSite &&
        state.nextSide == DraftSide.red) {
      playBotTurn();
    }
  }

  Future<void> playBotTurn() async {
    final currentGeneration = generation;
    setState(() => isBotThinking = true);

    await Future<void>.delayed(_botThinkingDelay);
    if (!mounted || currentGeneration != generation) return;

    if (state.isBanPhase) {
      final banned = bot!.chooseBan(state: state, pool: champions);
      setState(() {
        state = state.ban(DraftSide.red, banned);
        isBotThinking = false;
      });
    } else {
      final choice = bot!.choose(
        state: state,
        side: DraftSide.red,
        pool: champions,
      );
      setState(() {
        state = state.pick(DraftSide.red, choice.roleIndex, choice.champion);
        isBotThinking = false;
      });
    }
    advance();
  }

  void toggleBans(bool enabled) {
    setState(() {
      withBans = enabled;
      state = DraftState.empty(withBans: enabled);
    });
  }

  Future<void> banFor(DraftSide side) async {
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedIds: state.unavailableIds,
    );
    if (chosen == null || !mounted) return;
    if (!state.isBanPhase || state.nextSide != side) return;

    setState(() {
      state = state.ban(side, chosen);
    });
    advance();
  }

  Future<void> rename(DraftSide side) async {
    final current = players;
    if (current == null) return;

    final name = await PlayerNameDialog.show(
      context,
      currentName: current.of(side),
      otherName: current.of(side.opposite),
    );
    if (name == null || !mounted) return;

    setState(() {
      players = side == DraftSide.blue
          ? DraftPlayers(blue: name, red: current.red)
          : DraftPlayers(blue: current.blue, red: name);
    });
  }

  Future<void> pickFor(DraftSide side, int roleIndex) async {
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedIds: state.unavailableIds,
    );
    if (chosen == null || !mounted) return;
    if (state.nextSide != side) return;

    setState(() {
      state = state.pick(side, roleIndex, chosen);
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
      final finished = DraftEvaluator.evaluate(
        blue: blueMembers,
        red: redMembers,
        dataset: dataset,
        championNames: {for (final c in champions) c.id: c.name},
        players: players,
      );
      final saved = DraftRecord.from(
        id: DraftHistoryStore.newId(),
        playedAt: DateTime.now(),
        state: state,
        report: finished,
        versusFriend: players != null,
        blueName: players?.blue ?? 'Vous',
        redName: players?.red ?? 'Le site',
      );

      setState(() {
        report = finished;
        record = saved;
        isAnalysing = false;
      });
      // La draft est gardée dès qu'elle est jugée : on ne demande rien au
      // joueur, et un « Recommencer » ne la perd pas.
      DraftHistoryStore.add(saved);
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
        title: Text(
          widget.mode == DraftMode.vsFriend
              ? 'Draft à deux'
              : 'Entraîneur de draft',
          style: AppTheme.serif(size: 24),
        ),
        actions: [
          IconButton(
            tooltip: 'Historique des drafts',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DraftHistoryPage()),
            ),
            icon: const Icon(Icons.history),
          ),
          if (!isLoading && (state.pickCount > 0 || state.banCount > 0))
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
        if (_canChooseBans) ...[
          _BansSwitch(value: withBans, onChanged: toggleBans),
          const SizedBox(height: 10),
        ],
        _StatusCard(
          state: state,
          players: players,
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

  /// Les bannissements se règlent avant le premier coup, pas pendant la draft.
  bool get _canChooseBans =>
      state.banCount == 0 && state.pickCount == 0 && !isBotThinking;

  Widget _board() {
    final friend = widget.mode == DraftMode.vsFriend;
    final duel = players;
    final next = isBotThinking ? null : state.nextSide;
    // Changer un nom après le bilan le rendrait faux : on le fige.
    final canRename = friend && !state.isComplete;
    final banning = state.isBanPhase;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TeamColumn(
            title: duel == null ? 'VOUS' : '${duel.blue} · BLEU',
            champions: state.blue,
            onRename: canRename ? () => rename(DraftSide.blue) : null,
            bans: state.blueBans,
            banOwner: duel?.blue ?? 'vous',
            onBan: banning && next == DraftSide.blue
                ? () => banFor(DraftSide.blue)
                : null,
            onPick: !banning && next == DraftSide.blue
                ? (role) => pickFor(DraftSide.blue, role)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TeamColumn(
            title: duel == null ? 'SITE' : '${duel.red} · ROUGE',
            champions: state.red,
            // Contre le site, le rouge se joue tout seul ; à deux, il se joue
            // au doigt.
            onRename: canRename ? () => rename(DraftSide.red) : null,
            bans: state.redBans,
            banOwner: duel?.red ?? 'le site',
            onBan: banning && friend && next == DraftSide.red
                ? () => banFor(DraftSide.red)
                : null,
            onPick: !banning && friend && next == DraftSide.red
                ? (role) => pickFor(DraftSide.red, role)
                : null,
          ),
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
          widget.mode == DraftMode.vsFriend
              ? 'Chacun choisit à son tour sur le même appareil, pour le rôle de '
                    'son choix. À la fin, les deux drafts sont comparées.'
              : 'Choisissez un champion pour le rôle de votre choix quand c’est à '
                    'vous. Le site répond, puis la draft est comparée à la fin.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        ),
      ];
    }

    return [
      DraftReportView(report: finished),
      const SizedBox(height: 20),
      if (record case final saved?)
        OutlinedButton.icon(
          onPressed: () => copyToClipboard(
            context,
            DraftShareText.of(saved),
            message: 'Résumé de la draft copié',
          ),
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copier le résumé à partager'),
        ),
      const SizedBox(height: 10),
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
  final VoidCallback? onRename;
  final List<Champion?> bans;
  final String banOwner;
  final VoidCallback? onBan;

  const _TeamColumn({
    required this.title,
    required this.champions,
    required this.bans,
    required this.banOwner,
    this.onPick,
    this.onRename,
    this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColumnTitle(title: title, onRename: onRename),
        BanRow(owner: banOwner, bans: bans, onTap: onBan),
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
  final DraftPlayers? players;
  final bool isBotThinking;
  final bool isAnalysing;

  const _StatusCard({
    required this.state,
    required this.players,
    required this.isBotThinking,
    required this.isAnalysing,
  });

  String get _message {
    if (state.isComplete) {
      return isAnalysing ? 'Analyse des deux drafts…' : 'Draft terminée.';
    }
    if (isBotThinking) {
      return state.isBanPhase ? 'Le site bannit…' : 'Le site choisit…';
    }

    final duel = players;
    if (state.isBanPhase) {
      final side = state.nextSide!;
      final step = state.banCount + 1;
      final who = duel == null ? 'À vous' : "Au tour de ${duel.of(side)}";

      return "$who de bannir un champion (ban $step sur ${state.totalBans}). "
          "Appuyez sur la case libre pour choisir.";
    }

    final step = state.pickCount + 1;
    final count = draftPickOrder.length;

    if (duel != null) {
      final name = duel.of(state.nextSide!);
      final camp = state.nextSide == DraftSide.blue ? 'bleu' : 'rouge';

      return 'Au tour de $name, camp $camp (choix $step sur $count). Passez '
          "l'appareil si besoin, puis appuyez sur un rôle libre.";
    }

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

/// Le titre d'une colonne. Quand [onRename] est fourni, il se touche pour
/// changer le nom du joueur, et un crayon le dit.
class _ColumnTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onRename;

  const _ColumnTitle({required this.title, this.onRename});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.mono(size: 10, color: AppColors.accent),
    );
    if (onRename == null) {
      return Padding(padding: const EdgeInsets.only(bottom: 8), child: label);
    }

    return Semantics(
      button: true,
      label: 'Modifier le nom : $title',
      excludeSemantics: true,
      onTap: onRename,
      child: InkWell(
        onTap: onRename,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 2),
          child: Row(
            children: [
              Flexible(child: label),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, size: 12, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le réglage des bannissements, affiché avant que la draft commence.
class _BansSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BansSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Un Material et non un Container décoré : le SwitchListTile peint son effet
    // de toucher sur le Material le plus proche, qu'un fond intermédiaire
    // cacherait.
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text('Bannissements', style: AppTheme.serif(size: 15)),
        subtitle: Text(
          value
              ? 'Chaque camp écarte 5 champions avant de choisir.'
              : 'Aucun champion n’est écarté avant les choix.',
          style: AppTheme.serif(
            size: 12.5,
            italic: true,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
