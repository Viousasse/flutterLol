class ChampionAbility {
  final String name;
  final String description;
  final String imageUrl;

  ChampionAbility({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class ChampionDetail {
  final String id;
  final String name;
  final String title;
  final String lore;
  final ChampionAbility passive;
  final List<ChampionAbility> spells;

  ChampionDetail({
    required this.id,
    required this.name,
    required this.title,
    required this.lore,
    required this.passive,
    required this.spells,
  });

  factory ChampionDetail.fromJson(Map<String, dynamic> json, String version) {
    final passiveJson = json['passive'];
    final passive = ChampionAbility(
      name: passiveJson['name'],
      description: _cleanText(passiveJson['description']),
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/passive/${passiveJson['image']['full']}',
    );

    final spells = (json['spells'] as List).map((spell) {
      return ChampionAbility(
        name: spell['name'],
        description: _cleanText(spell['description']),
        imageUrl:
            'https://ddragon.leagueoflegends.com/cdn/$version/img/spell/${spell['image']['full']}',
      );
    }).toList();

    return ChampionDetail(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      lore: json['lore'] ?? '',
      passive: passive,
      spells: spells,
    );
  }

  static String _cleanText(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
