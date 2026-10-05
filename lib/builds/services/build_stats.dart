import '../../items/models/item.dart';

/// Une ligne de statistiques cumulées, déjà mise en forme.
class StatLine {
  final String label;
  final String value;

  const StatLine({required this.label, required this.value});
}

class _StatDefinition {
  final String key;
  final String label;

  /// Riot exprime ces bonus en fraction (0,25 pour 25 %) : on les affiche en
  /// pourcentage.
  final bool isPercent;

  const _StatDefinition(this.key, this.label, {this.isPercent = false});
}

/// Les seules statistiques que portent réellement les objets de la Faille, dans
/// l'ordre où un joueur les lit.
const _definitions = [
  _StatDefinition('FlatPhysicalDamageMod', "Dégâts d'attaque"),
  _StatDefinition('FlatMagicDamageMod', 'Puissance'),
  _StatDefinition('PercentAttackSpeedMod', "Vitesse d'attaque", isPercent: true),
  _StatDefinition('FlatCritChanceMod', 'Chances de coup critique', isPercent: true),
  _StatDefinition('PercentLifeStealMod', 'Vol de vie', isPercent: true),
  _StatDefinition('FlatHPPoolMod', 'Points de vie'),
  _StatDefinition('FlatArmorMod', 'Armure'),
  _StatDefinition('FlatSpellBlockMod', 'Résistance magique'),
  _StatDefinition('FlatMPPoolMod', 'Mana'),
  _StatDefinition('FlatHPRegenMod', 'Régénération de PV'),
  _StatDefinition('FlatMovementSpeedMod', 'Vitesse de déplacement'),
  _StatDefinition(
    'PercentMovementSpeedMod',
    'Vitesse de déplacement',
    isPercent: true,
  ),
];

class BuildStats {
  /// Prix d'achat cumulé : le coût total de chaque objet, composants compris.
  static int totalGold(List<Item> items) {
    return items.fold(0, (total, item) => total + item.gold);
  }

  /// Bonus cumulés des objets, en ne gardant que les statistiques non nulles.
  ///
  /// Les effets passifs et actifs ne sont pas des statistiques et ne sont donc
  /// pas comptés : le total est celui des bonus chiffrés, rien de plus.
  static List<StatLine> total(List<Item> items) {
    final lines = <StatLine>[];

    for (final definition in _definitions) {
      final sum = items.fold<double>(
        0,
        (total, item) => total + (item.stats[definition.key] ?? 0),
      );
      if (sum == 0) continue;

      lines.add(StatLine(label: definition.label, value: _format(sum, definition)));
    }

    return lines;
  }

  static String _format(double sum, _StatDefinition definition) {
    if (definition.isPercent) return '+${(sum * 100).round()} %';

    return '+${sum.round()}';
  }
}
