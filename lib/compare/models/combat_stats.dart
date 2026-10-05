/// Ce qu'un champion a réellement en main à un niveau donné, objets compris.
class CombatStats {
  final double health;
  final double attackDamage;
  final double abilityPower;
  final double attackSpeed;
  final double armor;
  final double magicResist;
  final double moveSpeed;
  final double attackRange;

  /// Fractions de 0 à 1 : 0,25 veut dire 25 %.
  final double critChance;
  final double lifeSteal;

  /// Difficulté de prise en main selon Riot : elle ne dépend ni du niveau ni
  /// des objets, mais se lit au même endroit.
  final int difficulty;

  const CombatStats({
    required this.health,
    required this.attackDamage,
    required this.abilityPower,
    required this.attackSpeed,
    required this.armor,
    required this.magicResist,
    required this.moveSpeed,
    required this.attackRange,
    required this.critChance,
    required this.lifeSteal,
    required this.difficulty,
  });
}
