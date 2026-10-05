import 'package:flutter/material.dart';

import '../champion_detail/champion_detail_page.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../counters/models/counter_pick.dart';
import '../counters/services/counter_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../shared/widgets/counter_tile/counter_tile.dart';
import '../shared/widgets/data_source_note/data_source_note.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../shared/widgets/lane_filter_bar/lane_filter_bar.dart';
import '../shared/widgets/remote_image/remote_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../matchups/services/lane_profile.dart';
import '../team/services/role_filters.dart';

/// « Je joue ce champion : contre qui est-il fort, et contre qui souffre-t-il ? »
/// d'après les parties classées Master+ analysées.
class StrengthsPage extends StatefulWidget {
  /// Champion déjà choisi, quand on arrive depuis sa fiche.
  final String? initialChampionId;

  /// Sources de données, injectables pour tester la page sans réseau.
  final Future<List<Champion>> Function() loadChampions;
  final Future<MatchupDataset> Function() loadDataset;

  const StrengthsPage({
    super.key,
    this.initialChampionId,
    this.loadChampions = ChampionService.fetchAll,
    this.loadDataset = MatchupService.load,
  });

  @override
  State<StrengthsPage> createState() => _StrengthsPageState();
}

class _StrengthsPageState extends State<StrengthsPage> {
  List<Champion> champions = const [];
  MatchupDataset dataset = const MatchupDataset.empty();
  Champion? mine;
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
        mine = _find(widget.initialChampionId);
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

  Future<void> pickChampion() async {
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedIds: {?mine?.id},
      roleFilter: RoleFilters.forProfile(LaneProfile.fromDataset(dataset)),
    );
    if (chosen == null || !mounted) return;

    // La voie choisie pour l'ancien champion n'a peut-être pas de données pour
    // le nouveau : on repart de toutes les voies.
    setState(() {
      mine = chosen;
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
        title: Text('Points forts', style: AppTheme.serif(size: 24)),
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
        _ChampionPicker(champion: mine, onTap: pickChampion),
        const SizedBox(height: 18),
        ..._results(),
      ],
    );
  }

  List<Widget> _results() {
    final champion = mine;

    if (champion == null) {
      return [
        Text(
          'Choisissez votre champion pour voir contre qui il est fort, et '
          'contre qui il a du mal.',
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

    final lanes = CounterService.lanesPlayedBy(champion.id, dataset);
    final strong = CounterService.strongAgainst(
      champion.id,
      dataset,
      lane: lane,
    );
    final weak = CounterService.weakAgainst(champion.id, dataset, lane: lane);

    if (strong.isEmpty && weak.isEmpty) {
      return [
        Text(
          'Aucune partie Master+ analysée avec ${champion.name}'
          '${lane == null ? '' : ' dans cette voie'} : essayez une autre voie '
          'ou un autre champion.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        ),
      ];
    }

    return [
      if (lanes.length > 1) ...[
        LaneFilterBar(
          lanes: lanes,
          selectedLane: lane,
          onSelect: (value) => setState(() => lane = value),
        ),
        const SizedBox(height: 16),
      ],
      if (strong.isNotEmpty) ...[
        Text('FORT CONTRE', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        ..._tiles(strong),
      ],
      if (weak.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text('DIFFICILE CONTRE', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        ..._tiles(weak),
      ],
      const SizedBox(height: 10),
      if (strong.any((pick) => !pick.isReliable)) ...[
        Text(
          'Peu de parties Master+ avec ${champion.name} : les adversaires '
          'marqués « peu de données » sont indicatifs, classés avec prudence.',
          style: AppTheme.serif(size: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
      ],
      DataSourceNote(dataset: dataset),
      const SizedBox(height: 4),
      Text(
        'Le pourcentage est celui de ${champion.name} face à chaque '
        'adversaire.',
        style: AppTheme.mono(size: 9, color: AppColors.textMuted),
      ),
    ];
  }

  List<Widget> _tiles(List<CounterPick> picks) {
    return [
      for (var index = 0; index < picks.length; index++)
        if (_find(picks[index].championId) case final opponent?)
          CounterTile(
            pick: picks[index],
            champion: opponent,
            rank: index + 1,
            onTap: () => openChampion(opponent),
          ),
    ];
  }
}

class _ChampionPicker extends StatelessWidget {
  final Champion? champion;
  final VoidCallback onTap;

  const _ChampionPicker({required this.champion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = champion;

    return Semantics(
      button: true,
      label: selected == null
          ? 'Choisir votre champion'
          : 'Votre champion : ${selected.name}, appuyer pour changer',
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
                Icon(Icons.military_tech, size: 32, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JE JOUE',
                      style: AppTheme.mono(size: 9, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected?.name ?? 'Choisir mon champion',
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
