import 'package:flutter/material.dart';
import '../../../champions/models/champion.dart';
import '../../../champions/services/champion_service.dart';

class ChampionOfTheDay extends StatefulWidget {
  const ChampionOfTheDay({super.key});

  @override
  State<ChampionOfTheDay> createState() => _ChampionOfTheDayState();
}

class _ChampionOfTheDayState extends State<ChampionOfTheDay> {
  Champion? champion;

  @override
  void initState() {
    super.initState();
    loadChampionOfTheDay();
  }

  Future<void> loadChampionOfTheDay() async {
    final champions = await ChampionService.fetchAll();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % champions.length;

    setState(() {
      champion = champions[index];
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(champion!.imageUrl, width: 70, height: 70),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Champion du jour',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    champion!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(champion!.title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
