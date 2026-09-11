import 'package:flutter/material.dart';
import '../../../champions/models/champion_detail.dart';

class AbilityTile extends StatelessWidget {
  final String label;
  final ChampionAbility ability;

  const AbilityTile({super.key, required this.label, required this.ability});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(ability.imageUrl, width: 50, height: 50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label - ${ability.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(ability.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
