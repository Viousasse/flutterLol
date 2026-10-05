import 'dart:math';

import '../../champions/models/champion.dart';
import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../../team/constants/team_roles.dart';
import '../../team/services/team_analyzer.dart';
import '../models/draft_state.dart';
import '../../matchups/services/lane_profile.dart';

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
        .where((champion) => !state.unavailableIds.contains(champion.id))
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

  /// Nombre de champions parmi lesquels le site tire son bannissement.
  static const banShortlistSize = 4;

  /// Poids du nombre de parties dans le score de bannissement : un champion
  /// très joué est une menace plus probable qu'un champion rare.
  static const banPopularityWeight = 4.0;

  /// Bannit un champion libre : de préférence un de ceux qui gagnent souvent
  /// et qu'on croise souvent, car ce sont ceux qu'un adversaire reprendra.
  Champion chooseBan({
    required DraftState state,
    required List<Champion> pool,
  }) {
    final available = pool
        .where((champion) => !state.unavailableIds.contains(champion.id))
        .toList();

    final records = {
      for (final champion in available)
        champion.id: MatchupService.overallFor(champion.id, dataset),
    };
    final mostGames = records.values.fold(
      1,
      (most, record) => max(most, record.games),
    );

    final scored = [
      for (final champion in available)
        (champion, _banScore(records[champion.id]!, mostGames)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    final shortlist = scored.take(banShortlistSize).toList();

    return shortlist[random.nextInt(shortlist.length)].$1;
  }

  double _banScore(OverallRecord record, int mostGames) {
    var score = random.nextDouble() * jitter;
    if (record.isReliable) score += (record.winRate - 0.5) * winRateWeight;

    return score + record.games / mostGames * banPopularityWeight;
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

    return score + needBonusFor(candidate, teammates);
  }

  /// Ce que le champion apporte à une équipe qui en manque : un bonus de
  /// [needBonus] par manque comblé. Partagé avec le conseiller de draft.
  static double needBonusFor(Champion candidate, Iterable<Champion> teammates) {
    final filled = needsFilledBy(candidate, teammates);
    var bonus = 0.0;
    if (filled.magic) bonus += needBonus;
    if (filled.physical) bonus += needBonus;
    if (filled.frontline) bonus += needBonus;

    return bonus;
  }

  /// Les manques de [teammates] que [candidate] comble : dégâts magiques,
  /// dégâts physiques, première ligne. Rien quand l'équipe est encore vide.
  static ({bool magic, bool physical, bool frontline}) needsFilledBy(
    Champion candidate,
    Iterable<Champion> teammates,
  ) {
    if (teammates.isEmpty) {
      return (magic: false, physical: false, frontline: false);
    }

    final attack = teammates.fold(0, (sum, c) => sum + c.attackRating);
    final magic = teammates.fold(0, (sum, c) => sum + c.magicRating);
    final total = attack + magic;
    var fillsMagic = false;
    var fillsPhysical = false;

    if (total > 0) {
      final magicShare = magic / total;
      fillsMagic =
          magicShare < TeamAnalyzer.minDamageShare + 0.1 &&
          candidate.magicRating >= 6;
      fillsPhysical =
          1 - magicShare < TeamAnalyzer.minDamageShare + 0.1 &&
          candidate.attackRating >= 6;
    }

    return (
      magic: fillsMagic,
      physical: fillsPhysical,
      frontline: !teammates.any(isFrontliner) && isFrontliner(candidate),
    );
  }

  static bool isFrontliner(Champion champion) {
    return champion.tags.contains('Tank') ||
        champion.defenseRating >= TeamAnalyzer.frontlineDefense;
  }
}
