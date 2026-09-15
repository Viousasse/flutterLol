import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../theme/app_colors.dart';
import '../../constants/lore_regions.dart';
import '../../models/lore_region.dart';
import '../../services/region_service.dart';
import '../region_marker/region_marker.dart';

/// Carte schématique de Runeterra.
///
/// Aucune image n'est chargée : les régions sont posées en coordonnées
/// relatives sur un fond dessiné, ce qui reste net à toute taille et
/// fonctionne hors ligne.
class RuneterraMap extends StatelessWidget {
  final List<Champion> champions;
  final RegionId? selectedRegion;
  final ValueChanged<LoreRegion> onSelect;

  const RuneterraMap({
    super.key,
    required this.champions,
    required this.selectedRegion,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final placedRegions = loreRegions
        .where((region) => region.x != null && region.y != null)
        .toList();

    return AspectRatio(
      aspectRatio: 0.82,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF16100F), Color(0xFF241A17)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                for (final region in placedRegions)
                  _positioned(region, constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _positioned(LoreRegion region, BoxConstraints constraints) {
    const markerWidth = 86.0;
    const markerHeight = 34.0;

    return Positioned(
      left: (region.x! * constraints.maxWidth) - (markerWidth / 2),
      top: (region.y! * constraints.maxHeight) - (markerHeight / 2),
      width: markerWidth,
      child: RegionMarker(
        region: region,
        championCount: RegionService.countOf(region.id, champions),
        selected: selectedRegion == region.id,
        onTap: () => onSelect(region),
      ),
    );
  }
}
