import 'package:flutter/material.dart';

import '../../../matchups/constants/lane_labels.dart';
import '../../../shared/widgets/app_filter_chip/app_filter_chip.dart';

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
      runSpacing: 7,
      children: [
        _chip(label: 'Toutes les voies', lane: null),
        for (final lane in lanes) _chip(label: laneLabels[lane] ?? lane, lane: lane),
      ],
    );
  }

  Widget _chip({required String label, required String? lane}) {
    return SizedBox(
      height: 32,
      child: AppFilterChip(
        label: label,
        selected: selectedLane == lane,
        onTap: () => onSelect(lane),
      ),
    );
  }
}
