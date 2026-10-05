import '../../champions/models/champion_stats.dart';
import '../../items/models/item.dart';
import '../models/combat_stats.dart';

class CombatStatsCalculator {
  static const minLevel = 1;
  static const maxLevel = 18;

  /// Le jeu plafonne la vitesse d'attaque à 2,5 attaques par seconde.
  static const attackSpeedCap = 2.5;

  /// Riot ne fait pas croître les caractéristiques de façon linéaire : le gain
  /// par niveau publié est multiplié par ce facteur, qui vaut 1 au niveau 18.
  static double growthFactor(int level) {
    final steps = level - 1;

    return steps * (0.7025 + 0.0175 * steps);
  }

  /// Caractéristiques de [base] au [level] donné, avec les bonus de [items].
  static CombatStats compute(
    ChampionStats base,
    int level,
    List<Item> items,
  ) {
    final growth = growthFactor(level.clamp(minLevel, maxLevel));

    double fromItems(String key) {
      return items.fold(0, (total, item) => total + (item.stats[key] ?? 0));
    }

    // Le bonus de vitesse d'attaque des objets et celui des niveaux
    // s'additionnent, puis s'appliquent à la vitesse d'attaque de base.
    final attackSpeedBonus =
        base.attackSpeedPerLevel / 100 * growth +
        fromItems('PercentAttackSpeedMod');
    final attackSpeed = base.attackSpeed * (1 + attackSpeedBonus);

    final moveSpeed =
        (base.moveSpeed + fromItems('FlatMovementSpeedMod')) *
        (1 + fromItems('PercentMovementSpeedMod'));

    return CombatStats(
      health:
          base.health + base.healthPerLevel * growth + fromItems('FlatHPPoolMod'),
      attackDamage:
          base.attackDamage +
          base.attackDamagePerLevel * growth +
          fromItems('FlatPhysicalDamageMod'),
      abilityPower: fromItems('FlatMagicDamageMod'),
      attackSpeed: attackSpeed > attackSpeedCap ? attackSpeedCap : attackSpeed,
      armor:
          base.armor + base.armorPerLevel * growth + fromItems('FlatArmorMod'),
      magicResist:
          base.magicResist +
          base.magicResistPerLevel * growth +
          fromItems('FlatSpellBlockMod'),
      moveSpeed: moveSpeed,
      attackRange: base.attackRange,
      critChance: fromItems('FlatCritChanceMod').clamp(0.0, 1.0),
      lifeSteal: fromItems('PercentLifeStealMod'),
      difficulty: base.difficulty,
    );
  }
}
