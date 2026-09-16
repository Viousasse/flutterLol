import 'package:flutter/material.dart';

import '../../../champions/models/champion.dart';
import '../../../theme/app_colors.dart';
import '../../constants/lore_regions.dart';
import '../../models/lore_region.dart';
import '../../services/region_service.dart';
import '../region_marker/region_marker.dart';

/// La carte du monde de Runeterra, avec une pastille par région.
///
/// Le fond est l'image officielle de la carte interactive de Riot, embarquée
/// dans les assets ; les
/// pastilles sont posées en coordonnées relatives, comme les points de la
/// Faille, donc la mise en page suit la largeur de l'écran.
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

  /// Empreinte d'une pastille, en fraction de la carte à 335 px de large :
  /// les positions de [loreRegions] sont choisies pour que deux pastilles ne
  /// se recouvrent jamais à cette taille.
  static const _markerWidth = 72.0;
  static const _markerHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    final placedRegions = loreRegions
        .where((region) => region.x != null && region.y != null)
        .toList();

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(runeterraMapAsset, fit: BoxFit.cover),
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
    return Positioned(
      left: (region.x! * constraints.maxWidth) - (_markerWidth / 2),
      top: (region.y! * constraints.maxHeight) - (_markerHeight / 2),
      width: _markerWidth,
      child: RegionMarker(
        region: region,
        championCount: RegionService.countOf(region.id, champions),
        selected: selectedRegion == region.id,
        onTap: () => onSelect(region),
      ),
    );
  }
}
