import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/app_filter_chip/app_filter_chip.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'constants/lore_regions.dart';
import 'models/lore_region.dart';
import 'services/region_service.dart';
import 'widgets/region_details/region_details.dart';
import 'widgets/runeterra_map/runeterra_map.dart';

/// Carte du lore : les régions de Runeterra et les champions qui en viennent.
class RuneterraBoard extends StatefulWidget {
  const RuneterraBoard({super.key});

  @override
  State<RuneterraBoard> createState() => _RuneterraBoardState();
}

class _RuneterraBoardState extends State<RuneterraBoard> {
  List<Champion> champions = const [];
  bool isLoading = true;
  String? errorMessage;
  RegionId? selectedRegion;

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    try {
      final result = await ChampionService.fetchAll();

      if (!mounted) return;
      setState(() {
        champions = result;
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

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadChampions();
  }

  void _select(LoreRegion region) {
    setState(() {
      selectedRegion = selectedRegion == region.id ? null : region.id;
    });
  }

  /// Régions sans territoire : elles ne se posent pas sur la carte, mais leurs
  /// champions doivent rester atteignables.
  List<LoreRegion> get _placelessRegions {
    return loreRegions
        .where((region) => region.x == null || region.y == null)
        .where((region) => RegionService.countOf(region.id, champions) > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final failure = errorMessage;
    if (failure != null) {
      return ErrorRetryView(message: failure, onRetry: retry);
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final selected = selectedRegion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuneterraMap(
          champions: champions,
          selectedRegion: selectedRegion,
          onSelect: _select,
        ),
        const SizedBox(height: 10),
        _placelessRow(),
        const SizedBox(height: 12),
        RegionDetails(
          region: selected == null ? null : regionsById[selected],
          champions: selected == null
              ? const []
              : RegionService.championsOf(selected, champions),
        ),
      ],
    );
  }

  Widget _placelessRow() {
    final placeless = _placelessRegions;
    if (placeless.isEmpty) return const SizedBox.shrink();

    // Liste horizontale comme la barre de filtres de la Faille : dans un Wrap,
    // AppFilterChip s'étire sur toute la largeur disponible à cause de son
    // alignment, et le libellé ne tenait pas sur une ligne à 375px.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hors carte',
          style: AppTheme.mono(size: 9, color: AppColors.textMuted),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 30,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: placeless.map((region) {
              final count = RegionService.countOf(region.id, champions);

              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: AppFilterChip(
                  label: '${region.name} · $count',
                  selected: selectedRegion == region.id,
                  onTap: () => _select(region),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
