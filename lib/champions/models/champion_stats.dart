/// Caractéristiques de base d'un champion au niveau 1, telles que Riot les
/// publie dans la fiche détaillée.
class ChampionStats {
  final double health;
  final double armor;
  final double magicResist;
  final double attackDamage;
  final double attackSpeed;
  final double moveSpeed;
  final double attackRange;

  /// Les quatre jauges de Riot, de 0 à 10.
  final int attackRating;
  final int defenseRating;
  final int magicRating;
  final int difficulty;

  const ChampionStats({
    required this.health,
    required this.armor,
    required this.magicResist,
    required this.attackDamage,
    required this.attackSpeed,
    required this.moveSpeed,
    required this.attackRange,
    required this.attackRating,
    required this.defenseRating,
    required this.magicRating,
    required this.difficulty,
  });

  const ChampionStats.empty()
    : this(
        health: 0,
        armor: 0,
        magicResist: 0,
        attackDamage: 0,
        attackSpeed: 0,
        moveSpeed: 0,
        attackRange: 0,
        attackRating: 0,
        defenseRating: 0,
        magicRating: 0,
        difficulty: 0,
      );

  factory ChampionStats.fromJson(
    Map<String, dynamic>? stats,
    Map<String, dynamic>? info,
  ) {
    double number(String key) => (stats?[key] as num?)?.toDouble() ?? 0;
    int rating(String key) => (info?[key] as num?)?.toInt() ?? 0;

    return ChampionStats(
      health: number('hp'),
      armor: number('armor'),
      magicResist: number('spellblock'),
      attackDamage: number('attackdamage'),
      attackSpeed: number('attackspeed'),
      moveSpeed: number('movespeed'),
      attackRange: number('attackrange'),
      attackRating: rating('attack'),
      defenseRating: rating('defense'),
      magicRating: rating('magic'),
      difficulty: rating('difficulty'),
    );
  }
}
