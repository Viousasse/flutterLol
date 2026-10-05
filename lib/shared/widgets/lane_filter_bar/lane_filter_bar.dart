import 'package:flutter/material.dart';

import '../../../matchups/constants/lane_labels.dart';
import '../app_filter_chip/app_filter_chip.dart';

/// Choix de la voie : « Toutes » additionne les voies, les autres puces
/// restreignent la liste à une seule.
class LaneFilterBar extends StatelessWidget {
  final List<String> lanes;
  final String? selectedLane;
  final ValueChanged<String?> onSelect;

  const LaneFilterBar({
    super.key,
    required this.lanes,
    required this.selectedLane,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      // Les puces font 44 px de zone tactile pour 32 visibles : plus d'écart
      // entre les lignes, la zone tactile en fournit déjà.
      runSpacing: 0,
      children: [
        _chip(label: 'Toutes les voies', lane: null),
        for (final lane in lanes) _chip(label: laneLabels[lane] ?? lane, lane: lane),
      ],
    );
  }

  Widget _chip({required String label, required String? lane}) {
    return SizedBox(
      height: AppFilterChip.minTapHeight,
      child: AppFilterChip(
        label: label,
        selected: selectedLane == lane,
        onTap: () => onSelect(lane),
      ),
    );
  }
}
