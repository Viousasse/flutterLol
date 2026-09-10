import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/champion.dart';

class ChampionService {
  static List<Champion>? _cache;

  static Future<List<Champion>> fetchAll() async {
    if (_cache != null) return _cache!;

    final versionResponse = await http.get(
      Uri.parse('https://ddragon.leagueoflegends.com/api/versions.json'),
    );
    final versions = jsonDecode(versionResponse.body) as List;
    final version = versions.first;

    final champsResponse = await http.get(
      Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/$version/data/fr_FR/champion.json',
      ),
    );
    final data = jsonDecode(champsResponse.body);
    final championsMap = data['data'] as Map<String, dynamic>;

    _cache = championsMap.values
        .map((json) => Champion.fromJson(json, version))
        .toList();

    return _cache!;
  }
}
