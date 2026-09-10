class Champion {
  final String id;
  final String name;
  final String title;
  final String imageUrl;

  Champion({
    required this.id,
    required this.name,
    required this.title,
    required this.imageUrl,
  });

  factory Champion.fromJson(Map<String, dynamic> json, String version) {
    return Champion(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/champion/${json['image']['full']}',
    );
  }
}
