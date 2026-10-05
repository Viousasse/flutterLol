import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/models/champion_detail.dart';
import '../champions/services/champion_service.dart';
import '../items/models/item.dart';
import '../items/services/item_service.dart';
import '../matchups/models/matchup.dart';
import '../matchups/services/matchup_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../shared/widgets/item_picker_sheet/item_picker_sheet.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'services/combat_stats_calculator.dart';
import 'services/comparison_builder.dart';
import 'widgets/compare_item_slots/compare_item_slots.dart';
import 'widgets/compare_level_slider/compare_level_slider.dart';
import 'widgets/compare_slot/compare_slot.dart';
import 'widgets/head_to_head_card/head_to_head_card.dart';
import 'widgets/stat_compare_row/stat_compare_row.dart';

/// Deux champions côte à côte, à un niveau et avec les objets de son choix, plus
/// leur bilan en duel.
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

  int level = CombatStatsCalculator.minLevel;
  List<Item> leftItems = const [];
  List<Item> rightItems = const [];

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

  /// Les objets ne sont téléchargés qu'au premier ajout : la comparaison de
  /// deux champions nus n'en a pas besoin.
  Future<void> addItem({required bool isLeft}) async {
    final List<Item> catalog;

    try {
      catalog = await ItemService.fetchAll();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
      return;
    }
    if (!mounted) return;

    final item = await ItemPickerSheet.show(context, items: catalog);
    if (item == null || !mounted) return;

    setState(() {
      if (isLeft) {
        leftItems = [...leftItems, item];
      } else {
        rightItems = [...rightItems, item];
      }
    });
  }

  void removeItem({required bool isLeft, required int index}) {
    setState(() {
      if (isLeft) {
        leftItems = [...leftItems]..removeAt(index);
      } else {
        rightItems = [...rightItems]..removeAt(index);
      }
    });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column(isLeft: true)),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 80),
              child: Text('VS', style: TextStyle(color: AppColors.accent)),
            ),
            Expanded(child: _column(isLeft: false)),
          ],
        ),
        const SizedBox(height: 22),
        ..._comparison(),
      ],
    );
  }

  /// Le portrait d'un champion, et sous lui ses objets une fois choisi.
  Widget _column({required bool isLeft}) {
    final champion = isLeft ? left : right;
    final items = isLeft ? leftItems : rightItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompareSlot(
          champion: champion,
          emptyLabel: isLeft
              ? 'Choisir le premier champion'
              : 'Choisir le second champion',
          onTap: () => pick(isLeft: isLeft),
        ),
        if (champion != null) ...[
          const SizedBox(height: 10),
          CompareItemSlots(
            items: items,
            onAdd: () => addItem(isLeft: isLeft),
            onRemoveAt: (index) => removeItem(isLeft: isLeft, index: index),
          ),
        ],
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

    final rows = ComparisonBuilder.build(
      CombatStatsCalculator.compute(leftStats, level, leftItems),
      CombatStatsCalculator.compute(rightStats, level, rightItems),
    );

    return [
      CompareLevelSlider(
        level: level,
        onChanged: (value) => setState(() => level = value),
      ),
      const SizedBox(height: 8),
      for (final stat in rows) StatCompareRow(stat: stat),
      const SizedBox(height: 18),
      if (!dataset.isEmpty)
        HeadToHeadCard(left: currentLeft, right: currentRight, dataset: dataset),
    ];
  }
}
