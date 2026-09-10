import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/champion.dart';
import 'widgets/champion_tile/champion_tile.dart';

class ChampionsPage extends StatefulWidget {
  const ChampionsPage({super.key});

  @override
  State<ChampionsPage> createState() => _ChampionsPageState();
}

class _ChampionsPageState extends State<ChampionsPage> {
  List<Champion> champions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChampions();
  }

  Future<void> fetchChampions() async {
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

    setState(() {
      champions = championsMap.values
          .map((json) => Champion.fromJson(json, version))
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Champions LoL'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: champions.length,
              itemBuilder: (context, index) {
                return ChampionTile(champion: champions[index]);
              },
            ),
    );
  }
}
