import 'package:flutter/material.dart';

import '../champion_detail/champion_detail_page.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../shared/widgets/data_source_note/data_source_note.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../shared/widgets/remote_image/remote_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'models/counter_pick.dart';
import 'services/counter_service.dart';
import '../shared/widgets/counter_tile/counter_tile.dart';
import '../shared/widgets/lane_filter_bar/lane_filter_bar.dart';
import '../matchups/services/lane_profile.dart';
import '../team/services/role_filters.dart';

/// « Je joue contre ce champion, qui choisir ? » : les champions qui le battent
/// le plus souvent dans les parties classées Master+ analysées.
class CountersPage extends StatefulWidget {
  /// Adversaire déjà choisi, quand on arrive depuis sa fiche.
  final String? initialOpponentId;

  /// Sources de données, injectables pour tester la page sans réseau.
  final Future<List<Champion>> Function() loadChampions;
  final Future<MatchupDataset> Function() loadDataset;

  const CountersPage({
    super.key,
    this.initialOpponentId,
    this.loadChampions = ChampionService.fetchAll,
    this.loadDataset = MatchupService.load,
  });

  @override
  State<CountersPage> createState() => _CountersPageState();
}

class _CountersPageState extends State<CountersPage> {
  List<Champion> champions = const [];
  MatchupDataset dataset = const MatchupDataset.empty();
  Champion? opponent;
  String? lane;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Future.wait écoute tous les chargements dès le départ : une erreur du
      // second ne reste pas sans auditeur pendant qu'on attend le premier.
      final results = await Future.wait<Object?>([
        widget.loadChampions(),
        widget.loadDataset(),
      ]);
      final loadedChampions = results[0] as List<Champion>;
      final loadedDataset = results[1] as MatchupDataset;

      if (!mounted) return;
      setState(() {
        champions = loadedChampions;
        dataset = loadedDataset;
        opponent = _find(widget.initialOpponentId);
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isLoading = false;
      });
    }
  }

  Champion? _find(String? id) {
    for (final champion in champions) {
      if (champion.id == id) return champion;
    }

    return null;
  }

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadData();
  }

  Future<void> pickOpponent() async {
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedIds: {?opponent?.id},
      roleFilter: RoleFilters.forProfile(LaneProfile.fromDataset(dataset)),
    );
    if (chosen == null || !mounted) return;

    // La voie choisie pour l'adversaire précédent n'a peut-être pas de données
    // pour le nouveau : on repart de toutes les voies.
    setState(() {
      opponent = chosen;
      lane = null;
    });
  }

  void openChampion(Champion champion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChampionDetailPage(championId: champion.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contre-picks', style: AppTheme.serif(size: 24)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final failure = errorMessage;
    if (failure != null) {
      return ErrorRetryView(message: failure, onRetry: retry);
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _OpponentPicker(opponent: opponent, onTap: pickOpponent),
        const SizedBox(height: 18),
        ..._results(),
      ],
    );
  }

  List<Widget> _results() {
    final target = opponent;

    if (target == null) {
      return [
        Text(
          'Choisissez le champion que vous allez affronter pour voir qui le '
          'bat le plus souvent.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        ),
      ];
    }

    if (dataset.isEmpty) {
      return [
        Text(
          'Les matchups ne sont pas disponibles pour le moment.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        ),
      ];
    }

    final lanes = CounterService.lanesFor(target.id, dataset);
    final picks = CounterService.counters(target.id, dataset, lane: lane);

    return [
      if (lanes.length > 1) ...[
        LaneFilterBar(
          lanes: lanes,
          selectedLane: lane,
          onSelect: (value) => setState(() => lane = value),
        ),
        const SizedBox(height: 16),
      ],
      if (picks.isEmpty)
        Text(
          'Aucune partie Master+ analysée contre ${target.name}'
          '${lane == null ? '' : ' dans cette voie'} : essayez une autre voie '
          'ou un autre champion.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        )
      else ...[
        Text('MEILLEURS CHOIX', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        for (var index = 0; index < picks.length; index++)
          _tile(picks[index], index + 1),
        const SizedBox(height: 10),
        if (picks.any((pick) => !pick.isReliable)) ...[
          Text(
            'Peu de parties Master+ contre ${target.name} : les propositions '
            'marquées « peu de données » sont indicatives, classées avec '
            'prudence.',
            style: AppTheme.serif(size: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
        ],
        DataSourceNote(dataset: dataset),
        const SizedBox(height: 4),
        Text(
          'Le pourcentage est celui du champion proposé face à ${target.name}.',
          style: AppTheme.mono(size: 9, color: AppColors.textMuted),
        ),
      ],
    ];
  }

  Widget _tile(CounterPick pick, int rank) {
    final champion = _find(pick.championId);
    if (champion == null) return const SizedBox.shrink();

    return CounterTile(
      pick: pick,
      champion: champion,
      rank: rank,
      onTap: () => openChampion(champion),
    );
  }
}

class _OpponentPicker extends StatelessWidget {
  final Champion? opponent;
  final VoidCallback onTap;

  const _OpponentPicker({required this.opponent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = opponent;

    return Semantics(
      button: true,
      label: selected == null
          ? "Choisir le champion à affronter"
          : 'Adversaire : ${selected.name}, appuyer pour changer',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (selected != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RemoteImage(
                    url: selected.imageUrl,
                    width: 52,
                    height: 52,
                  ),
                )
              else
                Icon(Icons.person_search, size: 32, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JE JOUE CONTRE',
                      style: AppTheme.mono(size: 9, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected?.name ?? 'Choisir un champion',
                      style: AppTheme.serif(size: 20),
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_more, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
