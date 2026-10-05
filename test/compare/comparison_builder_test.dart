import 'package:flutter_test/flutter_test.dart';
import 'package:monapp/champions/models/champion_stats.dart';
import 'package:monapp/compare/models/stat_comparison.dart';
import 'package:monapp/compare/services/comparison_builder.dart';

ChampionStats _stats({
  double health = 600,
  double armor = 30,
  double attackSpeed = 0.65,
  int difficulty = 5,
}) {
  return ChampionStats(
    health: health,
    armor: armor,
    magicResist: 32,
    attackDamage: 60,
    attackSpeed: attackSpeed,
    moveSpeed: 340,
    attackRange: 175,
    attackRating: 6,
    defenseRating: 5,
    magicRating: 3,
    difficulty: difficulty,
  );
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

  test('lit les caractéristiques depuis le JSON de Data Dragon', () {
    final stats = ChampionStats.fromJson(
      {'hp': 630, 'armor': 34, 'attackspeed': 0.625},
      {'difficulty': 7},
    );

    expect(stats.health, 630);
    expect(stats.attackSpeed, 0.625);
    expect(stats.difficulty, 7);
    expect(stats.magicResist, 0);
  });
}
