import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion_stats.dart';
import 'package:monapp/compare/models/combat_stats.dart';
import 'package:monapp/compare/models/stat_comparison.dart';
import 'package:monapp/compare/services/comparison_builder.dart';

CombatStats _stats({
  double health = 600,
  double armor = 30,
  double abilityPower = 0,
  double critChance = 0,
  double lifeSteal = 0,
}) {
  return CombatStats(
    health: health,
    attackDamage: 60,
    abilityPower: abilityPower,
    attackSpeed: 0.65,
    armor: armor,
    magicResist: 32,
    moveSpeed: 340,
    attackRange: 175,
    critChance: critChance,
    lifeSteal: lifeSteal,
    difficulty: 5,
  );
}

List<String> _labels(List<StatComparison> rows) {
  return rows.map((row) => row.label).toList();
}

void main() {
  test('désigne le gagnant de chaque ligne ou une égalité', () {
    final rows = ComparisonBuilder.build(
      _stats(health: 700),
      _stats(health: 600),
    );

    final health = rows.firstWhere((row) => row.label == 'Points de vie');
    final armor = rows.firstWhere((row) => row.label == 'Armure');

    expect(health.winner, ComparisonWinner.left);
    expect(armor.winner, ComparisonWinner.tie);
  });

  test('la barre de la plus forte valeur est pleine, l autre proportionnelle', () {
    const stat = StatComparison(label: 'x', left: 300, right: 600);

    expect(stat.rightFraction, 1);
    expect(stat.leftFraction, 0.5);
  });

  test('deux valeurs nulles ne divisent pas par zéro', () {
    const stat = StatComparison(label: 'x', left: 0, right: 0);

    expect(stat.leftFraction, 0);
    expect(stat.rightFraction, 0);
  });

  test('la vitesse d attaque garde deux décimales', () {
    final rows = ComparisonBuilder.build(_stats(), _stats());
    final speed = rows.firstWhere((row) => row.label == "Vitesse d'attaque");

    expect(speed.decimals, 2);
  });

  test('sans objet, les lignes alimentées par les objets sont absentes', () {
    final labels = _labels(ComparisonBuilder.build(_stats(), _stats()));

    expect(labels, isNot(contains('Puissance')));
    expect(labels, isNot(contains('Chances de coup critique (%)')));
    expect(labels, isNot(contains('Vol de vie (%)')));
  });

  test('un seul champion équipé suffit à faire apparaître la ligne', () {
    final rows = ComparisonBuilder.build(
      _stats(abilityPower: 120, critChance: 0.25, lifeSteal: 0.1),
      _stats(),
    );
    final labels = _labels(rows);

    expect(labels, contains('Puissance'));
    expect(labels, contains('Chances de coup critique (%)'));
    expect(labels, contains('Vol de vie (%)'));

    final crit = rows.firstWhere(
      (row) => row.label == 'Chances de coup critique (%)',
    );
    expect(crit.left, 25);
    expect(crit.winner, ComparisonWinner.left);
  });

  test('lit les caractéristiques depuis le JSON de Data Dragon', () {
    final stats = ChampionStats.fromJson(
      {
        'hp': 630,
        'hpperlevel': 109,
        'armor': 34,
        'attackspeed': 0.625,
        'attackspeedperlevel': 2.5,
      },
      {'difficulty': 7},
    );

    expect(stats.health, 630);
    expect(stats.healthPerLevel, 109);
    expect(stats.attackSpeed, 0.625);
    expect(stats.attackSpeedPerLevel, 2.5);
    expect(stats.difficulty, 7);
    expect(stats.magicResist, 0);
  });
}
