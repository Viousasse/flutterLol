import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data_dragon/data_dragon_service.dart';
import '../models/champion.dart';
import '../models/champion_detail.dart';

class ChampionService {
  static List<Champion>? _cache;
  static String? _version;

  static Future<List<Champion>> fetchAll() async {
    if (_cache != null) return _cache!;

    _version = await DataDragonService.latestVersion();

    final champsResponse = await http.get(
      Uri.parse(DataDragonService.dataUrl(_version!, 'champion.json')),
    );
    final data = jsonDecode(champsResponse.body);
    final championsMap = data['data'] as Map<String, dynamic>;

    _cache = championsMap.values
        .map((json) => Champion.fromJson(json, _version!))
        .toList();

    return _cache!;
  }

  static Future<ChampionDetail> fetchDetail(String championId) async {
    if (_version == null) {
      await fetchAll();
    }

    final response = await http.get(
      Uri.parse(
        DataDragonService.dataUrl(_version!, 'champion/$championId.json'),
      ),
    );
    final data = jsonDecode(response.body);
    final championJson = data['data'][championId];

    return ChampionDetail.fromJson(championJson, _version!);
  }
}
