import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data_dragon/data_dragon_service.dart';
import '../models/rune.dart';

class RuneService {
  static List<RuneTree>? _cache;

  static final Map<String, RuneTree> _treeByKey = {};
  static final Map<String, Rune> _runeByKey = {};

  static Future<List<RuneTree>> fetchAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final version = await DataDragonService.latestVersion();
    final response = await http.get(
      Uri.parse(DataDragonService.dataUrl(version, 'runesReforged.json')),
    );
    final trees = (jsonDecode(response.body) as List)
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
