import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion_stats.dart';
import 'package:monapp/compare/services/combat_stats_calculator.dart';
import 'package:monapp/items/models/item.dart';
import 'package:monapp/items/models/item_profile.dart';

/// Les chiffres d'Ahri dans Data Dragon.
const _ahri = ChampionStats(
  health: 590,
  armor: 21,
  magicResist: 30,
  attackDamage: 53,
  attackSpeed: 0.668,
  moveSpeed: 330,
  attackRange: 550,
  attackRating: 3,
  defenseRating: 4,
  magicRating: 8,
  difficulty: 5,
  healthPerLevel: 104,
  armorPerLevel: 4.7,
  magicResistPerLevel: 1.3,
  attackDamagePerLevel: 3,
  attackSpeedPerLevel: 2,
);

Item _item(Map<String, double> stats) {
  return Item(
    id: '1',
    name: 'Objet',
    description: '',
    plaintext: '',
    gold: 1000,
    imageUrl: 'https://example.invalid/1.png',
    tier: ItemTier.legendary,
    profile: ItemProfile.other,
    componentIds: const [],
    upgradeIds: const [],
    stats: stats,
  );
}

void main() {
  test('au niveau 1, les caractéristiques sont celles de base', () {
    final stats = CombatStatsCalculator.compute(_ahri, 1, const []);

    expect(stats.health, 590);
    expect(stats.attackDamage, 53);
    expect(stats.armor, 21);
    expect(stats.attackSpeed, closeTo(0.668, 0.0001));
  });

  test('au niveau 18, le gain par niveau est appliqué en plein', () {
    final stats = CombatStatsCalculator.compute(_ahri, 18, const []);

    // Au niveau 18 le facteur de croissance vaut 17 niveaux de gain complets.
    expect(stats.health, closeTo(590 + 104 * 17, 0.01));
    expect(stats.attackDamage, closeTo(53 + 3 * 17, 0.01));
    expect(stats.armor, closeTo(21 + 4.7 * 17, 0.01));
  });

  test('la croissance n est pas linéaire : le milieu est sous la moitié', () {
    final level10 = CombatStatsCalculator.compute(_ahri, 10, const []);

    expect(level10.health, lessThan(590 + 104 * 17 / 2 + 104 * 17 * 0.1));
    expect(level10.health, greaterThan(590));
  });

  test('les objets s ajoutent aux caractéristiques du niveau', () {
    final stats = CombatStatsCalculator.compute(_ahri, 1, [
      _item({'FlatHPPoolMod': 400, 'FlatMagicDamageMod': 80}),
      _item({'FlatHPPoolMod': 300, 'FlatArmorMod': 40}),
    ]);

    expect(stats.health, 590 + 700);
    expect(stats.abilityPower, 80);
    expect(stats.armor, 21 + 40);
  });

  test('la vitesse d attaque des objets s applique à la vitesse de base', () {
    final stats = CombatStatsCalculator.compute(_ahri, 1, [
      _item({'PercentAttackSpeedMod': 0.5}),
    ]);

    expect(stats.attackSpeed, closeTo(0.668 * 1.5, 0.0001));
  });

  test('la vitesse d attaque est plafonnée à 2,5', () {
    final stats = CombatStatsCalculator.compute(_ahri, 18, [
      _item({'PercentAttackSpeedMod': 3}),
    ]);

    expect(stats.attackSpeed, CombatStatsCalculator.attackSpeedCap);
  });

  test('la vitesse de déplacement combine bonus fixe puis pourcentage', () {
    final stats = CombatStatsCalculator.compute(_ahri, 1, [
      _item({'FlatMovementSpeedMod': 45, 'PercentMovementSpeedMod': 0.1}),
    ]);

    expect(stats.moveSpeed, closeTo((330 + 45) * 1.1, 0.001));
  });

  test('un niveau hors bornes est ramené dans 1 à 18', () {
    final below = CombatStatsCalculator.compute(_ahri, -4, const []);
    final above = CombatStatsCalculator.compute(_ahri, 99, const []);

    expect(below.health, 590);
    expect(above.health, closeTo(590 + 104 * 17, 0.01));
  });

  test('la chance de critique est plafonnée à 100 %', () {
    final stats = CombatStatsCalculator.compute(_ahri, 1, [
      _item({'FlatCritChanceMod': 0.6}),
      _item({'FlatCritChanceMod': 0.6}),
    ]);

    expect(stats.critChance, 1);
  });
}
