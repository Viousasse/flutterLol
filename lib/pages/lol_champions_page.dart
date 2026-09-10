import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Version simple : juste une liste de champions avec image + nom
class LolChampionsPage extends StatefulWidget {
  const LolChampionsPage({super.key});

  @override
  State<LolChampionsPage> createState() => _LolChampionsPageState();
}

class _LolChampionsPageState extends State<LolChampionsPage> {
  List<dynamic> champions = [];
  bool isLoading = true;
  String version = '';

  @override
  void initState() {
    super.initState();
    fetchChampions();
  }

  Future<void> fetchChampions() async {
    // 1. On récupère la dernière version du jeu
    final versionResponse = await http.get(
      Uri.parse('https://ddragon.leagueoflegends.com/api/versions.json'),
    );
    final versions = jsonDecode(versionResponse.body) as List;
    version = versions.first;

    // 2. On récupère la liste des champions pour cette version
    final champsResponse = await http.get(
      Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/$version/data/fr_FR/champion.json',
      ),
    );
    final data = jsonDecode(champsResponse.body);
    final championsMap = data['data'] as Map<String, dynamic>;

    setState(() {
      champions = championsMap.values.toList();
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
                final champ = champions[index];
                final imageUrl =
                    'https://ddragon.leagueoflegends.com/cdn/$version/img/champion/${champ['image']['full']}';

                return ListTile(
                  leading: Image.network(imageUrl, width: 50, height: 50),
                  title: Text(champ['name']),
                  subtitle: Text(champ['title']),
                );
              },
            ),
    );
  }
}