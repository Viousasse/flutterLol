import '../../data_dragon/data_dragon_service.dart';
import '../models/rune.dart';

class RuneService {
  static List<RuneTree>? _cache;
  static Future<List<RuneTree>>? _pending;

  static final Map<String, RuneTree> _treeByKey = {};
  static final Map<String, Rune> _runeByKey = {};

  /// Le futur en cours est mis en cache, pas seulement son résultat : deux
  /// fiches champion ouvertes coup sur coup ne retéléchargent pas les runes.
  static Future<List<RuneTree>> fetchAll() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);

    final pending = _pending;
    if (pending != null) return pending;

    final request = _fetchAll();
    _pending = request;

    return request;
  }

  static Future<List<RuneTree>> _fetchAll() async {
    try {
      return await _download();
    } finally {
      _pending = null;
    }
  }

  static Future<List<RuneTree>> _download() async {
    final version = await DataDragonService.latestVersion();
    final response = await DataDragonService.fetchJson(
      DataDragonService.dataUrl(version, 'runesReforged.json'),
    );
    final trees = (response as List)
        .map((json) => RuneTree.fromJson(json))
        .toList();

    _treeByKey
      ..clear()
      ..addAll({for (final tree in trees) tree.key: tree});

    _runeByKey.clear();
    for (final tree in trees) {
      for (final slot in tree.slots) {
        for (final rune in slot) {
          _runeByKey[rune.key] = rune;
        }
      }
    }

    _cache = trees;
    return trees;
  }

  /// `null` si la clé Data Dragon a changé depuis la rédaction des
  /// recommandations : l'appelant doit ignorer l'entrée plutôt que planter.
  static RuneTree? treeByKey(String key) => _treeByKey[key];

  static Rune? runeByKey(String key) => _runeByKey[key];
}
