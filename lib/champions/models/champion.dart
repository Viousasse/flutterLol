class Champion {
  final String id;
  final String name;
  final String title;
  final String blurb;
  final String imageUrl;
  final List<String> tags;

  /// Difficulté de prise en main, de 1 à 10 selon Riot. 0 quand l'information
  /// n'est pas fournie.
  final int difficulty;

  Champion({
    required this.id,
    required this.name,
    required this.title,
    required this.blurb,
    required this.imageUrl,
    required this.tags,
    this.difficulty = 0,
  });

  /// Illustration verticale haute définition, faite pour les grandes cartes :
  /// l'icône carrée de 120 px devient floue dès qu'on l'étire.
  String get portraitUrl =>
      'https://ddragon.leagueoflegends.com/cdn/img/champion/loading/${id}_0.jpg';

  factory Champion.fromJson(Map<String, dynamic> json, String version) {
    final info = json['info'] as Map<String, dynamic>?;

    return Champion(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      blurb: json['blurb'] ?? '',
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/champion/${json['image']['full']}',
      tags: List<String>.from(json['tags'] ?? []),
      difficulty: (info?['difficulty'] as num?)?.toInt() ?? 0,
    );
  }
}
