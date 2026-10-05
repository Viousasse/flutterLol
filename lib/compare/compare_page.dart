import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/models/champion_detail.dart';
import '../champions/services/champion_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'services/comparison_builder.dart';
import 'widgets/champion_picker_sheet/champion_picker_sheet.dart';
import 'widgets/compare_slot/compare_slot.dart';
import 'widgets/head_to_head_card/head_to_head_card.dart';
import 'widgets/stat_compare_row/stat_compare_row.dart';

/// Deux champions côte à côte : caractéristiques de base et bilan en duel.
class ComparePage extends StatefulWidget {
  /// Champion déjà placé à gauche, quand on arrive depuis sa fiche.
  final String? initialChampionId;

  const ComparePage({super.key, this.initialChampionId});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  List<Champion> champions = const [];
  MatchupDataset dataset = const MatchupDataset.empty();

  Champion? left;
  Champion? right;
  ChampionDetail? leftDetail;
  ChampionDetail? rightDetail;

  bool isLoading = true;
  bool isLoadingDetails = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    try {
      final loaded = await ChampionService.fetchAll();
      final loadedDataset = await _loadDatasetOrEmpty();

      if (!mounted) return;
      setState(() {
        champions = loaded;
        dataset = loadedDataset;
        left = _find(widget.initialChampionId, loaded);
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

  /// Le duel est un bonus : sans le fichier embarqué, les caractéristiques
  /// restent comparables.
  Future<MatchupDataset> _loadDatasetOrEmpty() async {
    try {
      return await MatchupService.load();
    } catch (_) {
      return const MatchupDataset.empty();
    }
  }

  Champion? _find(String? id, List<Champion> all) {
    if (id == null) return null;

    for (final champion in all) {
      if (champion.id == id) return champion;
    }

    return null;
  }

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadChampions();
  }

  Future<void> pick({required bool isLeft}) async {
    final other = isLeft ? right : left;
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedId: other?.id,
    );
    if (chosen == null || !mounted) return;

    setState(() {
      if (isLeft) {
        left = chosen;
        leftDetail = null;
      } else {
        right = chosen;
        rightDetail = null;
      }
    });
    loadDetails();
  }

  /// Les caractéristiques viennent de la fiche détaillée de chaque champion,
  /// téléchargée à la demande plutôt que pour les 170 d'avance.
  Future<void> loadDetails() async {
    final currentLeft = left;
    final currentRight = right;
    if (currentLeft == null || currentRight == null) return;

    setState(() {
      isLoadingDetails = true;
      errorMessage = null;
    });

    try {
      final loadedLeft = ChampionService.fetchDetail(currentLeft.id);
      final loadedRight = ChampionService.fetchDetail(currentRight.id);
      final details = [await loadedLeft, await loadedRight];

      // Un autre choix a pu arriver pendant le chargement : on ne montre que
      // des données qui correspondent encore aux deux emplacements.
      if (!mounted || left != currentLeft || right != currentRight) return;
      setState(() {
        leftDetail = details[0];
        rightDetail = details[1];
        isLoadingDetails = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comparer', style: AppTheme.serif(size: 24))),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final failure = errorMessage;
    if (failure != null && champions.isEmpty) {
      return ErrorRetryView(message: failure, onRetry: retry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: CompareSlot(
                champion: left,
                emptyLabel: 'Choisir le premier champion',
                onTap: () => pick(isLeft: true),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('VS', style: TextStyle(color: AppColors.accent)),
            ),
            Expanded(
              child: CompareSlot(
                champion: right,
                emptyLabel: 'Choisir le second champion',
                onTap: () => pick(isLeft: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ..._comparison(),
      ],
    );
  }

  List<Widget> _comparison() {
    final currentLeft = left;
    final currentRight = right;

    if (currentLeft == null || currentRight == null) {
      return [
        Text(
          'Choisissez deux champions pour comparer leurs caractéristiques '
          'et leur bilan en duel.',
          style: AppTheme.serif(size: 14, color: AppColors.textMuted),
        ),
      ];
    }

    final failure = errorMessage;
    if (failure != null) {
      return [ErrorRetryView(message: failure, onRetry: loadDetails)];
    }

    final leftStats = leftDetail?.stats;
    final rightStats = rightDetail?.stats;
    if (isLoadingDetails || leftStats == null || rightStats == null) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    return [
      for (final stat in ComparisonBuilder.build(leftStats, rightStats))
        StatCompareRow(stat: stat),
      const SizedBox(height: 18),
      if (!dataset.isEmpty)
        HeadToHeadCard(left: currentLeft, right: currentRight, dataset: dataset),
    ];
  }
}
