import '../../champions/models/champion.dart';
import '../../matchups/models/matchup.dart';
import '../../matchups/services/lane_profile.dart';
import '../../matchups/services/matchup_service.dart';
import '../../team/constants/team_roles.dart';
import '../models/draft_state.dart';
import 'draft_bot.dart';

/// Un champion conseillé pour un rôle, avec les raisons de ce conseil.
class DraftSuggestion {
  /// Index dans [teamRoles].
  final int roleIndex;
  final Champion champion;

  /// 1 à 3 phrases courtes, en français, toutes tirées des données.
  final List<String> reasons;
  final double score;

  const DraftSuggestion({
    required this.roleIndex,
    required this.champion,
    required this.reasons,
    required this.score,
  });
}

/// Propose des champions au joueur qui doit choisir.
///
/// Il reprend le barème du site (duel contre l'adversaire de la voie, taux de
/// victoire, manque de l'équipe) mais sans hasard : le même état donne toujours
/// les mêmes conseils, et chaque conseil dit pourquoi.
class DraftAdvisor {
  /// Phrase quand aucune donnée fiable ne justifie le conseil.
  static const fallbackReason = 'Se joue régulièrement à ce poste.';

  /// Après la préposition « à/au/en », pour construire « contre Zed au milieu ».
  static const _roleLabels = [
    'en haut',
    'en jungle',
    'au milieu',
    'en bas',
    'en support',
  ];

  static const _maxReasons = 3;

  final MatchupDataset dataset;
  final LaneProfile profile;

  DraftAdvisor({required this.dataset})
    : profile = LaneProfile.fromDataset(dataset);

  /// Vide pendant les bannissements, quand la draft est finie, ou quand [side]
  /// n'a plus de rôle libre.
  List<DraftSuggestion> suggest({
    required DraftState state,
    required DraftSide side,
    required List<Champion> pool,
    int count = 3,
  }) {
    if (state.isBanPhase || state.isComplete || count <= 0) return const [];

    final own = state.teamOf(side);
    final opposing = state.teamOf(side.opposite);
    final emptyRoles = [
      for (var index = 0; index < own.length; index++)
        if (own[index] == null) index,
    ];
    if (emptyRoles.isEmpty) return const [];

    final unavailable = state.unavailableIds;
    final available = pool
        .where((champion) => !unavailable.contains(champion.id))
        .toList();
    final teammates = own.whereType<Champion>().toList();

    // Un champion n'est gardé que pour son meilleur rôle : sinon le même nom
    // reviendrait trois fois, une par poste libre.
    final bestByChampion = <String, DraftSuggestion>{};

    for (final roleIndex in emptyRoles) {
      final lane = teamRoleLanes[roleIndex];
      var candidates = available
          .where((champion) => profile.fits(champion.id, lane))
          .toList();
      // Faute de champion connu à ce poste, on ne bloque pas le conseil.
      if (candidates.isEmpty) candidates = available;

      for (final champion in candidates) {
        final suggestion = _evaluate(
          champion,
          roleIndex,
          opposing[roleIndex],
          teammates,
        );
        final known = bestByChampion[champion.id];
        if (known == null || suggestion.score > known.score) {
          bestByChampion[champion.id] = suggestion;
        }
      }
    }

    final ranked = bestByChampion.values.toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;

        // Égalité : l'ordre du rôle puis l'identifiant, pour rester stable.
        final byRole = a.roleIndex.compareTo(b.roleIndex);

        return byRole != 0 ? byRole : a.champion.id.compareTo(b.champion.id);
      });

    return ranked.take(count).toList();
  }

  DraftSuggestion _evaluate(
    Champion champion,
    int roleIndex,
    Champion? laneOpponent,
    List<Champion> teammates,
  ) {
    var score = 0.0;
    final reasons = <String>[];

    if (laneOpponent != null) {
      final duel = MatchupService.headToHead(
        champion.id,
        laneOpponent.id,
        dataset,
      );
      if (duel != null) {
        score += (duel.winRate - 0.5) * DraftBot.counterWeight;
        if (duel.winRate > 0.5) {
          reasons.add(
            'Gagne ${_percent(duel.winRate)} % contre ${laneOpponent.name} '
            '${_roleLabels[roleIndex]} (${duel.games} parties).',
          );
        }
      }
    }

    final record = MatchupService.overallFor(champion.id, dataset);
    if (record.isReliable) {
      score += (record.winRate - 0.5) * DraftBot.winRateWeight;
      if (record.winRate > 0.5) {
        reasons.add('${_percent(record.winRate)} % de victoires en Master+.');
      }
    }

    final filled = DraftBot.needsFilledBy(champion, teammates);
    if (filled.magic) {
      score += DraftBot.needBonus;
      reasons.add('Comble le manque de dégâts magiques de votre équipe.');
    }
    if (filled.physical) {
      score += DraftBot.needBonus;
      reasons.add('Comble le manque de dégâts physiques de votre équipe.');
    }
    if (filled.frontline) {
      score += DraftBot.needBonus;
      reasons.add('Apporte une première ligne qui vous manque.');
    }

    return DraftSuggestion(
      roleIndex: roleIndex,
      champion: champion,
      reasons: reasons.isEmpty
          ? const [fallbackReason]
          : reasons.take(_maxReasons).toList(),
      score: score,
    );
  }

  static int _percent(double rate) => (rate * 100).round();
}
