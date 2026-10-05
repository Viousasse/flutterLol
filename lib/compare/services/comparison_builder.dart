import '../models/combat_stats.dart';
import '../models/stat_comparison.dart';

class ComparisonBuilder {
  /// Les lignes dans l'ordre d'affichage, de la plus structurante (points de
  /// vie, dégâts) à la plus fine (portée).
  ///
  /// Les lignes que seuls les objets alimentent (puissance, critique, vol de
  /// vie) n'apparaissent que si au moins un des deux champions en a : sans
  /// objet, elles seraient des rangées de zéros.
  static List<StatComparison> build(CombatStats left, CombatStats right) {
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
      if (left.abilityPower > 0 || right.abilityPower > 0)
        StatComparison(
          label: 'Puissance',
          left: left.abilityPower,
          right: right.abilityPower,
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
      if (left.critChance > 0 || right.critChance > 0)
        StatComparison(
          label: 'Chances de coup critique (%)',
          left: left.critChance * 100,
          right: right.critChance * 100,
        ),
      if (left.lifeSteal > 0 || right.lifeSteal > 0)
        StatComparison(
          label: 'Vol de vie (%)',
          left: left.lifeSteal * 100,
          right: right.lifeSteal * 100,
        ),
      StatComparison(
        label: 'Difficulté',
        left: left.difficulty.toDouble(),
        right: right.difficulty.toDouble(),
      ),
    ];
  }
}
