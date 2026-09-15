import '../../data_dragon/data_dragon_service.dart';
import '../models/item.dart';
import '../models/item_stack.dart';

class ItemService {
  static List<Item>? _cache;
  static Future<List<Item>>? _pending;

  /// Associe **chaque** identifiant Riot à l'objet retenu, y compris les
  /// identifiants des doublons écartés : les recettes les référencent encore.
  static final Map<String, Item> _indexById = {};

  /// Le futur en cours est mis en cache, pas seulement son résultat : l'onglet
  /// Objets et les conseils d'une fiche champion peuvent demander la liste en
  /// même temps, et téléchargeaient sinon item.json chacun de leur côté.
  static Future<List<Item>> fetchAll() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);

    final pending = _pending;
    if (pending != null) return pending;

    final request = _fetchAll();
    _pending = request;

    return request;
  }

  static Future<List<Item>> _fetchAll() async {
    try {
      final version = await DataDragonService.latestVersion();

      final data = await DataDragonService.fetchJson(
        DataDragonService.dataUrl(version, 'item.json'),
      );
      final itemsMap = data['data'] as Map<String, dynamic>;

      final parsedItems = itemsMap.entries
          .where((entry) => Item.isAvailable(entry.key, entry.value))
          .map((entry) => Item.fromJson(entry.key, entry.value, version))
          .toList();

      _indexById
        ..clear()
        ..addAll(_buildIndex(parsedItems));

      final uniqueItems = _indexById.values.toSet().toList();
      uniqueItems.sort((a, b) => a.name.compareTo(b.name));
      _cache = uniqueItems;

      return uniqueItems;
    } finally {
      _pending = null;
    }
  }

  /// Riot publie plusieurs identifiants pour un même objet (variantes de mode,
  /// entrées héritées). On n'en garde qu'un par nom, mais les identifiants
  /// abandonnés pointent vers lui pour ne pas casser les recettes.
  static Map<String, Item> _buildIndex(List<Item> items) {
    final keptByName = <String, Item>{};

    for (final item in items) {
      final name = item.name.toLowerCase();
      final kept = keptByName[name];

      if (kept == null || _isBetterEntry(item, kept)) {
        keptByName[name] = item;
      }
    }

    return {
      for (final item in items) item.id: keptByName[item.name.toLowerCase()]!,
    };
  }

  /// À nom égal, on privilégie l'entrée dont la recette est la plus complète,
  /// puis le plus petit identifiant, qui est celui de l'objet d'origine.
  static bool _isBetterEntry(Item candidate, Item kept) {
    final candidateRecipeSize =
        candidate.componentIds.length + candidate.upgradeIds.length;
    final keptRecipeSize = kept.componentIds.length + kept.upgradeIds.length;

    if (candidateRecipeSize != keptRecipeSize) {
      return candidateRecipeSize > keptRecipeSize;
    }

    return _numericId(candidate) < _numericId(kept);
  }

  static int _numericId(Item item) {
    return int.tryParse(item.id) ?? 1 << 30;
  }

  /// Objets dans lesquels [item] se transforme directement.
  ///
  /// Les identifiants pointant vers un objet indisponible en solo/duo sont
  /// écartés silencieusement : Riot référence aussi des recettes d'autres modes.
  static List<ItemStack> upgradesOf(Item item) {
    return _resolve(item.upgradeIds);
  }

  /// Composants directs nécessaires pour fabriquer [item].
  static List<ItemStack> componentsOf(Item item) {
    return _resolve(item.componentIds);
  }

  /// Objets finaux atteignables depuis [item], recette complète parcourue.
  static List<ItemStack> finalBuildsOf(Item item) {
    final finalBuilds = <String, Item>{};
    final visitedIds = <String>{item.id};
    final toExplore = <Item>[item];

    while (toExplore.isNotEmpty) {
      final current = toExplore.removeLast();
      final upgrades = upgradesOf(current);

      if (upgrades.isEmpty && current.id != item.id) {
        finalBuilds[current.id] = current;
        continue;
      }

      for (final upgrade in upgrades) {
        if (visitedIds.add(upgrade.item.id)) {
          toExplore.add(upgrade.item);
        }
      }
    }

    final results = finalBuilds.values.toList();
    results.sort((a, b) => a.name.compareTo(b.name));

    return results.map((build) => ItemStack(item: build, count: 1)).toList();
  }

  /// Résout une liste d'identifiants Riot en objets, dans l'ordre donné.
  ///
  /// Un identifiant devenu invalide (objet retiré, clé mal recopiée) est
  /// silencieusement ignoré plutôt que de faire planter l'affichage.
  static Future<List<Item>> byIds(List<String> ids) async {
    await fetchAll();
    return ids.map((id) => _indexById[id]).whereType<Item>().toList();
  }

  /// Une recette répète l'identifiant d'un composant demandé plusieurs fois, et
  /// deux identifiants distincts peuvent viser le même objet retenu : on
  /// regroupe les deux cas en une quantité.
  static List<ItemStack> _resolve(List<String> ids) {
    final resolved = <String, Item>{};
    final counts = <String, int>{};

    for (final id in ids) {
      final item = _indexById[id];
      if (item == null) continue;

      resolved[item.id] = item;
      counts[item.id] = (counts[item.id] ?? 0) + 1;
    }

    return resolved.values
        .map((item) => ItemStack(item: item, count: counts[item.id]!))
        .toList();
  }
}
