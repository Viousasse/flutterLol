import 'package:flutter/material.dart';
import 'models/champion.dart';
import 'services/champion_service.dart';
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
    loadChampions();
  }

  Future<void> loadChampions() async {
    final result = await ChampionService.fetchAll();
    setState(() {
      champions = result;
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
