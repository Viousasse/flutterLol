import 'item_profile.dart';

enum ItemTier { basic, epic, legendary }

class Item {
  final String id;
  final String name;
  final String description;
  final String plaintext;
  final int gold;
  final String imageUrl;
  final ItemTier tier;
  final ItemProfile profile;
  final List<String> componentIds;
  final List<String> upgradeIds;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.plaintext,
    required this.gold,
    required this.imageUrl,
    required this.tier,
    required this.profile,
    required this.componentIds,
    required this.upgradeIds,
  });

  bool get canBeUpgraded => upgradeIds.isNotEmpty;

  bool get isBuiltFromComponents => componentIds.isNotEmpty;

  factory Item.fromJson(String id, Map<String, dynamic> json, String version) {
    final componentIds = _readStringList(json['from']);
    final upgradeIds = _readStringList(json['into']);

    return Item(
      id: id,
      name: json['name'] ?? '',
      description: _cleanText(json['description'] ?? ''),
      plaintext: json['plaintext'] ?? '',
      gold: json['gold']?['total'] ?? 0,
      imageUrl:
          'https://ddragon.leagueoflegends.com/cdn/$version/img/item/${json['image']['full']}',
      tier: _resolveTier(componentIds, upgradeIds),
      profile: resolveItemProfile(
        _readStringList(json['tags']),
        json['stats'] as Map<String, dynamic>? ?? const {},
      ),
      componentIds: componentIds,
      upgradeIds: upgradeIds,
    );
  }

  static List<String> _readStringList(dynamic rawValues) {
    final values = rawValues as List?;
    if (values == null) return const [];
    return values.map((value) => value.toString()).toList();
  }

  static ItemTier _resolveTier(
    List<String> componentIds,
    List<String> upgradeIds,
  ) {
    if (componentIds.isEmpty) return ItemTier.basic;
    if (upgradeIds.isNotEmpty) return ItemTier.epic;
    return ItemTier.legendary;
  }

  /// Identifiant de la Faille de l'invocateur, la seule carte jouée en solo/duo.
  static const _summonersRiftMapId = '11';

  /// Vrai uniquement pour les objets achetables en partie classée solo/duo.
  static bool isAvailable(String id, Map<String, dynamic> json) {
    if (_isModeVariant(id)) return false;
    if (!_isOnSummonersRift(json)) return false;
    if (!_isSoldInShop(json)) return false;
    if (_requiresAnAlly(json)) return false;
    if (_isFullyRefunded(json)) return false;
    if (_isRetiredContent(json)) return false;

    return _hasIdentity(json);
  }

  /// Longueur maximale d'un identifiant de la boutique classée.
  static const _maxRankedIdLength = 5;

  /// Riot décline un objet par mode en préfixant son identifiant de deux
  /// chiffres : l'Arena vend 443056, l'événement 663056, le Chant de guerre
  /// 2065 devient 322065. Ces variantes gardent `maps["11"]: true` et restent
  /// achetables, donc seul l'identifiant les distingue de l'objet classé.
  static bool _isModeVariant(String id) {
    return id.length > _maxRankedIdLength;
  }

  static bool _isOnSummonersRift(Map<String, dynamic> json) {
    return json['maps']?[_summonersRiftMapId] == true;
  }

  static bool _isSoldInShop(Map<String, dynamic> json) {
    final purchasable = json['gold']?['purchasable'] ?? false;
    final total = json['gold']?['total'] ?? 0;

    return purchasable == true && total > 0;
  }

  /// Les objets chef-d'oeuvre d'Ornn ne s'achètent pas : ils exigent un allié
  /// précis dans l'équipe et sont forgés, jamais proposés en boutique.
  static bool _requiresAnAlly(Map<String, dynamic> json) {
    return json['requiredAlly'] != null;
  }

  /// La Faille rembourse 70 % d'un objet revendu et 40 % d'un consommable.
  /// Un remboursement intégral signale un objet d'événement, comme le Jus
  /// chapi-chapo vendu 300 et repris 300.
  static bool _isFullyRefunded(Map<String, dynamic> json) {
    final total = json['gold']?['total'] ?? 0;
    final sell = json['gold']?['sell'] ?? 0;

    return sell >= total;
  }

  /// `inStore: false` et `hideFromAll: true` marquent les objets retirés des
  /// modes classés mais toujours présents dans les données de Riot.
  static bool _isRetiredContent(Map<String, dynamic> json) {
    if (json['inStore'] == false) return true;

    return json['hideFromAll'] == true;
  }

  static bool _hasIdentity(Map<String, dynamic> json) {
    return (json['name'] ?? '').toString().isNotEmpty;
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
