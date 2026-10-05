/// Un sort d'invocateur de la Faille, tel que Data Dragon le décrit.
class SummonerSpell {
  static const _classicMode = 'CLASSIC';

  /// Identifiant Riot, par exemple `SummonerFlash`.
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  /// Temps de recharge en secondes.
  final int cooldown;

  const SummonerSpell({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cooldown,
  });

  factory SummonerSpell.fromJson(Map<String, dynamic> json, String version) {
    final cooldowns = json['cooldown'] as List? ?? const [];

    return SummonerSpell(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/spell/${json['image']['full']}',
      cooldown: cooldowns.isEmpty ? 0 : (cooldowns.first as num).toInt(),
    );
  }

  /// Vrai pour les sorts jouables en partie classique : Riot liste aussi ceux
  /// des modes événementiels, qui n'ont rien à faire dans une recommandation.
  static bool isClassic(Map<String, dynamic> json) {
    final modes = json['modes'] as List? ?? const [];

    return modes.contains(_classicMode);
  }
}
