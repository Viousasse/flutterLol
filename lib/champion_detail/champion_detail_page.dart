import 'package:flutter/material.dart';
import '../champions/models/champion_detail.dart';
import '../champions/services/champion_service.dart';
import 'widgets/ability_tile/ability_tile.dart';

class ChampionDetailPage extends StatefulWidget {
  final String championId;

  const ChampionDetailPage({super.key, required this.championId});

  @override
  State<ChampionDetailPage> createState() => _ChampionDetailPageState();
}

class _ChampionDetailPageState extends State<ChampionDetailPage> {
  ChampionDetail? detail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    final result = await ChampionService.fetchDetail(widget.championId);
    setState(() {
      detail = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['A', 'Z', 'E', 'R'];

    return Scaffold(
      appBar: AppBar(
        title: Text(detail?.name ?? ''),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  detail!.title,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Histoire',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(detail!.lore),
                const SizedBox(height: 24),
                const Text(
                  'Capacités',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AbilityTile(label: 'Passif', ability: detail!.passive),
                ...detail!.spells.asMap().entries.map((entry) {
                  return AbilityTile(
                    label: labels[entry.key],
                    ability: entry.value,
                  );
                }),
              ],
            ),
    );
  }
}
