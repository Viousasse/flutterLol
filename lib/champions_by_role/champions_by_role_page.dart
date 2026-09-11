import 'package:flutter/material.dart';
import '../champions/models/champion.dart';
import '../champions/services/champion_service.dart';
import '../champions/widgets/champion_tile/champion_tile.dart';

class ChampionsByRolePage extends StatefulWidget {
  final String role;

  const ChampionsByRolePage({super.key, required this.role});

  @override
  State<ChampionsByRolePage> createState() => _ChampionsByRolePageState();
}

class _ChampionsByRolePageState extends State<ChampionsByRolePage> {
  List<Champion> champions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    final allChampions = await ChampionService.fetchAll();
    setState(() {
      champions =
          allChampions.where((c) => c.tags.contains(widget.role)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role),
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
