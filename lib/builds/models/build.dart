import '../../items/constants/item_slots.dart';

/// Une composition d'objets enregistrée par le joueur.
class Build {
  /// Nombre d'emplacements d'objets dans le jeu.
  static const maxItems = maxItemSlots;

  final String id;
  final String name;

  /// Champion pour lequel la build est pensée, ou `null` si elle vaut pour
  /// tous.
  final String? championId;

  /// Identifiants des objets, dans l'ordre des emplacements. Jamais plus de
  /// [maxItems].
  final List<String> itemIds;

  const Build({
    required this.id,
    required this.name,
    required this.itemIds,
    this.championId,
  });

  Build copyWith({String? name, String? championId, List<String>? itemIds}) {
    return Build(
      id: id,
      name: name ?? this.name,
      championId: championId ?? this.championId,
      itemIds: itemIds ?? this.itemIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'championId': championId,
    'itemIds': itemIds,
  };

  /// Lit une build enregistrée, ou renvoie `null` si l'entrée est illisible :
  /// une seule entrée corrompue ne doit pas faire perdre toutes les autres.
  static Build? tryFromJson(dynamic raw) {
    if (raw is! Map) return null;

    final id = raw['id'];
    final name = raw['name'];
    final itemIds = raw['itemIds'];
    if (id is! String || name is! String || itemIds is! List) return null;

    return Build(
      id: id,
      name: name,
      championId: raw['championId'] as String?,
      itemIds: itemIds.map((value) => '$value').take(maxItems).toList(),
    );
  }
}
