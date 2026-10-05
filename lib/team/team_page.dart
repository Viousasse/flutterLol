import 'package:flutter/material.dart';

import '../champions/models/champion.dart';
import '../champions/models/champion_detail.dart';
import '../champions/services/champion_service.dart';
import '../shared/errors/user_message.dart';
import '../shared/widgets/champion_picker_sheet/champion_picker_sheet.dart';
import '../shared/widgets/error_retry_view/error_retry_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'models/team_insight.dart';
import 'models/team_member.dart';
import 'services/team_analyzer.dart';
import 'widgets/damage_split_bar/damage_split_bar.dart';
import 'widgets/insight_tile/insight_tile.dart';
import 'widgets/team_slot/team_slot.dart';

/// Les cinq rôles d'une équipe, dans l'ordre des voies.
const teamRoles = ['Top', 'Jungle', 'Milieu', 'Bot', 'Support'];

/// Compose une équipe de cinq champions et dit ce qui lui manque : dégâts
/// physiques ou magiques, première ligne, contrôle.
class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Champion> champions = const [];
  late final List<Champion?> slots = List.filled(teamRoles.length, null);

  /// Fiches détaillées déjà téléchargées, pour ne pas les redemander quand un
  /// champion revient dans l'équipe.
  final Map<String, ChampionDetail> details = {};
  final Set<String> loadingIds = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadChampions();
  }

  Future<void> loadChampions() async {
    try {
      final loaded = await ChampionService.fetchAll();

      if (!mounted) return;
      setState(() {
        champions = loaded;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = userMessageFor(error);
        isLoading = false;
      });
    }
  }

  void retry() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    loadChampions();
  }

  Set<String> get _teamIds => {
    for (final champion in slots) ?champion?.id,
  };

  Future<void> pick(int index) async {
    final chosen = await ChampionPickerSheet.show(
      context,
      champions: champions,
      excludedIds: _teamIds,
    );
    if (chosen == null || !mounted) return;

    setState(() => slots[index] = chosen);
    await loadDetail(chosen.id);
  }

  /// La fiche détaillée donne les jauges et les sorts que l'analyse lit. Un
  /// échec laisse le champion dans l'équipe, simplement absent du bilan.
  Future<void> loadDetail(String championId) async {
    if (details.containsKey(championId)) return;

    setState(() => loadingIds.add(championId));

    try {
      final detail = await ChampionService.fetchDetail(championId);
      if (!mounted) return;
      setState(() => details[championId] = detail);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    } finally {
      if (mounted) setState(() => loadingIds.remove(championId));
    }
  }

  void clear(int index) {
    setState(() => slots[index] = null);
  }

  void reset() {
    setState(() {
      for (var index = 0; index < slots.length; index++) {
        slots[index] = null;
      }
    });
  }

  List<TeamMember> get _members {
    return [
      for (final champion in slots)
        if (champion != null && details[champion.id] != null)
          TeamMember(champion: champion, detail: details[champion.id]!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Composition', style: AppTheme.serif(size: 24)),
        actions: [
          if (slots.any((champion) => champion != null))
            IconButton(
              tooltip: "Vider l'équipe",
              onPressed: reset,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final failure = errorMessage;
    if (failure != null) {
      return ErrorRetryView(message: failure, onRetry: retry);
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final members = _members;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 32),
      children: [
        for (var index = 0; index < teamRoles.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TeamSlot(
              role: teamRoles[index],
              champion: slots[index],
              isLoading:
                  slots[index] != null && loadingIds.contains(slots[index]!.id),
              onTap: () => pick(index),
              onClear: () => clear(index),
            ),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _analysis(members),
        ),
      ],
    );
  }

  Widget _analysis(List<TeamMember> members) {
    if (members.isEmpty) {
      return Text(
        "Placez des champions dans l'équipe pour voir si elle est équilibrée.",
        style: AppTheme.serif(size: 14, color: AppColors.textMuted),
      );
    }

    final analysis = TeamAnalyzer.analyze(members);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DÉGÂTS', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        DamageSplitBar(
          physicalShare: analysis.physicalShare,
          magicShare: analysis.magicShare,
        ),
        const SizedBox(height: 20),
        Text('BILAN', style: AppTheme.mono(size: 9)),
        const SizedBox(height: 8),
        for (final TeamInsight insight in analysis.insights)
          InsightTile(insight: insight),
      ],
    );
  }
}
