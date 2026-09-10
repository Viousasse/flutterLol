import 'dart:math';
import 'package:flutter/material.dart';
import '../../../champions/models/champion.dart';
import '../../../champions/services/champion_service.dart';

class RandomLore extends StatefulWidget {
  const RandomLore({super.key});

  @override
  State<RandomLore> createState() => _RandomLoreState();
}

class _RandomLoreState extends State<RandomLore> {
  Champion? champion;
  List<Champion> allChampions = [];

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    final champions = await ChampionService.fetchAll();
    setState(() {
      allChampions = champions;
      champion = champions[Random().nextInt(champions.length)];
    });
  }

  void pickAnother() {
    if (allChampions.isEmpty) return;
    setState(() {
      champion = allChampions[Random().nextInt(allChampions.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (champion == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Une histoire de LoL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: pickAnother,
                ),
              ],
            ),
            Text(
              champion!.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(champion!.blurb),
          ],
        ),
      ),
    );
  }
}
