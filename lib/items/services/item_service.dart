import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ItemService {
  static List<Item>? _cache;

  static Future<List<Item>> fetchAll() async {
    if (_cache != null) return _cache!;

    final versionResponse = await http.get(
      Uri.parse('https://ddragon.leagueoflegends.com/api/versions.json'),
    );
    final versions = jsonDecode(versionResponse.body) as List;
    final version = versions.first;

    final itemsResponse = await http.get(
      Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/$version/data/fr_FR/item.json',
      ),
    );
    final data = jsonDecode(itemsResponse.body);
    final itemsMap = data['data'] as Map<String, dynamic>;

    _cache = itemsMap.entries
        .where((entry) => Item.isAvailable(entry.value))
        .map((entry) => Item.fromJson(entry.key, entry.value, version))
        .toList();

    _cache!.sort((a, b) => a.name.compareTo(b.name));

    return _cache!;
  }
}
