import 'package:flutter/material.dart';
import '../../models/item_profile.dart';
import '../item_filter_chip/item_filter_chip.dart';

class ItemProfileBar extends StatelessWidget {
  final ItemProfile? selectedProfile;
  final ValueChanged<ItemProfile?> onSelect;

  const ItemProfileBar({
    super.key,
    required this.selectedProfile,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ItemFilterChip(
            label: 'Tout',
            selected: selectedProfile == null,
            onTap: () => onSelect(null),
          ),
          ...ItemProfile.values.map((profile) {
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: ItemFilterChip(
                label: profileLabels[profile]!,
                selected: selectedProfile == profile,
                onTap: () {
                  onSelect(selectedProfile == profile ? null : profile);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
