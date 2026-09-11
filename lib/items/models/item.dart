enum ItemTier { basic, epic, legendary }

class Item {
  final String id;
  final String name;
  final String description;
  final String plaintext;
  final int gold;
  final String imageUrl;
  final ItemTier tier;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.plaintext,
    required this.gold,
    required this.imageUrl,
    required this.tier,
  });

  factory Item.fromJson(String id, Map<String, dynamic> json, String version) {
    return Item(
      id: id,
      name: json['name'] ?? '',
      description: _cleanText(json['description'] ?? ''),
      plaintext: json['plaintext'] ?? '',
      gold: json['gold']?['total'] ?? 0,
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/item/${json['image']['full']}',
      tier: _resolveTier(json),
    );
  }

  static ItemTier _resolveTier(Map<String, dynamic> json) {
    final hasFrom = (json['from'] as List?)?.isNotEmpty ?? false;
    final hasInto = (json['into'] as List?)?.isNotEmpty ?? false;

    if (!hasFrom) return ItemTier.basic;
    if (hasInto) return ItemTier.epic;
    return ItemTier.legendary;
  }

  static bool isAvailable(Map<String, dynamic> json) {
    final purchasable = json['gold']?['purchasable'] ?? false;
    final onRift = json['maps']?['11'] ?? false;
    final hasName = (json['name'] ?? '').toString().isNotEmpty;
    final total = json['gold']?['total'] ?? 0;
    return purchasable && onRift && hasName && total > 0;
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
