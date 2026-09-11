import 'package:flutter/material.dart';
import '../../constants/map_landmarks.dart';
import '../../../shared/widgets/app_filter_chip/app_filter_chip.dart';

class MapTypeBar extends StatelessWidget {
  final LandmarkType? selectedType;
  final ValueChanged<LandmarkType?> onSelect;

  const MapTypeBar({
    super.key,
    required this.selectedType,
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
            label: 'Tout',
            selected: selectedType == null,
            onTap: () => onSelect(null),
          ),
          ...LandmarkType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: AppFilterChip(
                label: landmarkTypeLabels[type]!,
                selected: selectedType == type,
                onTap: () => onSelect(selectedType == type ? null : type),
              ),
            );
          }),
        ],
      ),
    );
  }
}
