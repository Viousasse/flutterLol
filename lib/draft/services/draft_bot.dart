import 'dart:math';

import '../../champions/models/champion.dart';
import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../../team/constants/team_roles.dart';
import '../../team/services/team_analyzer.dart';
import '../models/draft_state.dart';
import 'lane_profile.dart';

/// Le choix du site : un rôle et le champion qui l'occupera.
class DraftChoice {
  final int roleIndex;
  final Champion champion;

  const DraftChoice({required this.roleIndex, required this.champion});
}

/// Joue le camp du site.
///
/// Il applique les mêmes idées qu'un joueur : jouer un champion qui se joue
/// vraiment à ce poste, contrer l'adversaire déjà choisi dans la voie, viser un
/// champion qui gagne souvent, et combler ce qui manque à son équipe.
class DraftBot {
  /// Nombre de meilleures options parmi lesquelles le site tire : choisir
  /// toujours la première rendrait chaque draft identique.
  static const shortlistSize = 3;

  /// Poids d'un duel gagné ou perdu contre l'adversaire de la voie : un
  /// champion à 60 % de victoire dans le duel gagne 15 points.
  static const counterWeight = 150.0;

  /// Poids du taux de victoire global : 55 % rapporte 5 points.
  static const winRateWeight = 100.0;

  /// Bonus quand le champion comble un manque de l'équipe.
  static const needBonus = 6.0;

  /// Dispersion aléatoire ajoutée à chaque score, pour départager les égalités.
  static const jitter = 2.0;

  final MatchupDataset dataset;
  final LaneProfile profile;
  final Random random;

  DraftBot({required this.dataset, Random? random})
    : profile = LaneProfile.fromDataset(dataset),
      random = random ?? Random();

  /// Choisit pour le camp [side], parmi les champions de [pool] pas encore pris.
  DraftChoice choose({
    required DraftState state,
    required DraftSide side,
    required List<Champion> pool,
  }) {
    final own = state.teamOf(side);
    final opposing = state.teamOf(side.opposite);

    final emptyRoles = [
      for (var index = 0; index < own.length; index++)
        if (own[index] == null) index,
    ];

    // On choisit en priorité un rôle que l'adversaire a déjà pris : c'est là
    // qu'un contre-pick est possible.
    final contested = emptyRoles.where((i) => opposing[i] != null).toList();
    final roles = contested.isNotEmpty ? contested : emptyRoles;
    final roleIndex = roles[random.nextInt(roles.length)];

    final available = pool
        .where((champion) => !state.pickedIds.contains(champion.id))
        .toList();
    final lane = teamRoleLanes[roleIndex];

    // Faute de champion connu à ce poste, on prend n'importe quel champion
    // libre plutôt que de bloquer la draft.
    var candidates = available
        .where((champion) => profile.fits(champion.id, lane))
        .toList();
    if (candidates.isEmpty) candidates = available;

    final scored = [
      for (final champion in candidates)
        (
          champion,
          _score(champion, opposing[roleIndex], own.whereType<Champion>()),
        ),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    final shortlist = scored.take(shortlistSize).toList();
    final picked = shortlist[random.nextInt(shortlist.length)].$1;

    return DraftChoice(roleIndex: roleIndex, champion: picked);
  }

  double _score(
    Champion candidate,
    Champion? laneOpponent,
    Iterable<Champion> teammates,
  ) {
    var score = random.nextDouble() * jitter;

    final record = MatchupService.overallFor(candidate.id, dataset);
    if (record.isReliable) score += (record.winRate - 0.5) * winRateWeight;

    if (laneOpponent != null) {
      final duel = MatchupService.headToHead(
        candidate.id,
        laneOpponent.id,
        dataset,
      );
      if (duel != null) score += (duel.winRate - 0.5) * counterWeight;
    }

    return score + _needBonus(candidate, teammates);
  }

  /// Ce que le champion apporte à une équipe qui en manque.
  double _needBonus(Champion candidate, Iterable<Champion> teammates) {
    if (teammates.isEmpty) return 0;

    final attack = teammates.fold(0, (sum, c) => sum + c.attackRating);
    final magic = teammates.fold(0, (sum, c) => sum + c.magicRating);
    final total = attack + magic;
    var bonus = 0.0;

    if (total > 0) {
      final magicShare = magic / total;
      if (magicShare < TeamAnalyzer.minDamageShare + 0.1 &&
          candidate.magicRating >= 6) {
        bonus += needBonus;
      }
      if (1 - magicShare < TeamAnalyzer.minDamageShare + 0.1 &&
          candidate.attackRating >= 6) {
        bonus += needBonus;
      }
    }

    if (!teammates.any(_isFrontliner) && _isFrontliner(candidate)) {
      bonus += needBonus;
    }

    return bonus;
  }

  static bool _isFrontliner(Champion champion) {
    return champion.tags.contains('Tank') ||
        champion.defenseRating >= TeamAnalyzer.frontlineDefense;
  }
}
