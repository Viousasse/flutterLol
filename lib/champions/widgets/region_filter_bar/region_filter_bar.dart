import 'package:flutter/material.dart';

import '../../../regions/constants/lore_regions.dart';
import '../../../regions/models/lore_region.dart';
import '../../../shared/widgets/app_filter_chip/app_filter_chip.dart';

/// « Non répertoriés » n'est pas un choix de l'univers, juste des champions
/// absents de notre table : il n'a pas sa place parmi les filtres.
final _filterableRegions = loreRegions
    .where((region) => region.id != RegionId.unknown)
    .toList();

class RegionFilterBar extends StatelessWidget {
  final RegionId? selectedRegion;
  final ValueChanged<RegionId?> onSelect;

  const RegionFilterBar({
    super.key,
    required this.selectedRegion,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          AppFilterChip(
            label: 'Toutes les régions',
            selected: selectedRegion == null,
            onTap: () => onSelect(null),
          ),
          for (final region in _filterableRegions)
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: AppFilterChip(
                label: region.name,
                selected: selectedRegion == region.id,
                onTap: () => onSelect(
                  selectedRegion == region.id ? null : region.id,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
