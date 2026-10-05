import '../../champions/models/champion_stats.dart';
import '../models/stat_comparison.dart';

class ComparisonBuilder {
  /// Les lignes dans l'ordre d'affichage, de la plus structurante (points de
  /// vie, dégâts) à la plus fine (portée).
  static List<StatComparison> build(ChampionStats left, ChampionStats right) {
    return [
      StatComparison(
        label: 'Points de vie',
        left: left.health,
        right: right.health,
      ),
      StatComparison(
        label: "Dégâts d'attaque",
        left: left.attackDamage,
        right: right.attackDamage,
      ),
      StatComparison(
        label: "Vitesse d'attaque",
        left: left.attackSpeed,
        right: right.attackSpeed,
        decimals: 2,
      ),
      StatComparison(label: 'Armure', left: left.armor, right: right.armor),
      StatComparison(
        label: 'Résistance magique',
        left: left.magicResist,
        right: right.magicResist,
      ),
      StatComparison(
        label: 'Vitesse de déplacement',
        left: left.moveSpeed,
        right: right.moveSpeed,
      ),
      StatComparison(
        label: "Portée d'attaque",
        left: left.attackRange,
        right: right.attackRange,
      ),
      StatComparison(
        label: 'Difficulté',
        left: left.difficulty.toDouble(),
        right: right.difficulty.toDouble(),
      ),
    ];
  }
}
