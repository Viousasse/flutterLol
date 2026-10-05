import '../../matchups/models/matchup.dart';
import '../models/counter_pick.dart';

class CounterService {
  /// Nombre de propositions affichées : au-delà, la liste se lit comme un
  /// classement complet plutôt que comme un conseil.
  static const maxPicks = 15;

  /// Nombre de bilans fiables à partir duquel on ne complète pas la liste : en
  /// dessous, on ajoute des champions moins rencontrés plutôt que de ne rien
  /// montrer.
  static const minReliablePicks = 5;

  /// Nombre de faiblesses listées pour un champion.
  static const maxWeaknesses = 5;

  /// Les champions qui s'en sortent le mieux face à [opponentId].
  ///
  /// Sans [lane], les voies sont additionnées : un champion qui a affronté
  /// l'adversaire à deux endroits cumule ses parties.
  ///
  /// Les bilans fiables (au moins `MatchupService.minGames` parties) viennent
  /// d'abord, du meilleur au moins bon. S'il y en a moins de [minReliablePicks]
  /// et que [includeLowConfidence] est vrai, la liste est complétée par les
  /// champions moins rencontrés, classés avec un taux tempéré : un adversaire
  /// peu joué reçoit ainsi des propositions, marquées comme peu fiables.
  static List<CounterPick> counters(
    String opponentId,
    MatchupDataset dataset, {
    String? lane,
    bool includeLowConfidence = true,
  }) {
    final all = _collect(
      dataset,
      lane,
      (matchup) => matchup.opponentId == opponentId ? matchup.championId : null,
    );

    return _rank(all, includeLowConfidence);
  }

  /// Les adversaires contre lesquels [championId] gagne le plus, du meilleur au
  /// moins bon. Le résultat a la même forme que [counters] : `championId` y
  /// désigne l'**adversaire**, et les taux sont ceux de [championId].
  static List<CounterPick> strongAgainst(
    String championId,
    MatchupDataset dataset, {
    String? lane,
    bool includeLowConfidence = true,
  }) {
    final all = _collect(
      dataset,
      lane,
      (matchup) => matchup.championId == championId ? matchup.opponentId : null,
    );

    return _rank(all, includeLowConfidence);
  }

  /// Les adversaires contre lesquels [championId] perd le plus, du pire au moins
  /// mauvais. Seuls les bilans fiables et défavorables sont retenus : une
  /// faiblesse annoncée sur trois parties ne servirait à rien.
  static List<CounterPick> weakAgainst(
    String championId,
    MatchupDataset dataset, {
    String? lane,
  }) {
    final all = _collect(
      dataset,
      lane,
      (matchup) => matchup.championId == championId ? matchup.opponentId : null,
    );

    final losing = all.where((pick) => pick.isReliable && pick.winRate < 0.5)
        .toList()
      ..sort((a, b) {
        final byRate = a.winRate.compareTo(b.winRate);
        if (byRate != 0) return byRate;

        final byGames = b.games.compareTo(a.games);

        return byGames != 0 ? byGames : a.championId.compareTo(b.championId);
      });

    return losing.take(maxWeaknesses).toList();
  }

  /// Les voies où [opponentId] a été affronté, par ordre de volume de parties :
  /// proposer une voie sans donnée mènerait à une liste vide.
  static List<String> lanesFor(String opponentId, MatchupDataset dataset) {
    return _lanesBy(dataset, (matchup) => matchup.opponentId == opponentId);
  }

  /// Les voies où [championId] a joué, par ordre de volume de parties.
  static List<String> lanesPlayedBy(String championId, MatchupDataset dataset) {
    return _lanesBy(dataset, (matchup) => matchup.championId == championId);
  }

  // --- Outils -----------------------------------------------------------

  /// Additionne parties et victoires par champion cible. [target] renvoie le
  /// champion à regrouper pour un duel, ou `null` s'il ne concerne pas la
  /// recherche.
  static List<CounterPick> _collect(
    MatchupDataset dataset,
    String? lane,
    String? Function(Matchup matchup) target,
  ) {
    final games = <String, int>{};
    final wins = <String, int>{};

    for (final matchup in dataset.matchups) {
      final key = target(matchup);
      if (key == null) continue;
      if (lane != null && matchup.lane != lane) continue;

      games[key] = (games[key] ?? 0) + matchup.games;
      wins[key] = (wins[key] ?? 0) + matchup.wins;
    }

    return [
      for (final entry in games.entries)
        if (entry.value > 0)
          CounterPick(
            championId: entry.key,
            games: entry.value,
            wins: wins[entry.key] ?? 0,
          ),
    ];
  }

  static List<CounterPick> _rank(
    List<CounterPick> all,
    bool includeLowConfidence,
  ) {
    // À pourcentage égal, celui qui a le plus de parties derrière lui est plus
    // fiable ; puis l'ordre alphabétique garde une liste stable.
    final reliable = all.where((pick) => pick.isReliable).toList()
      ..sort((a, b) {
        final byRate = b.winRate.compareTo(a.winRate);
        if (byRate != 0) return byRate;

        final byGames = b.games.compareTo(a.games);

        return byGames != 0 ? byGames : a.championId.compareTo(b.championId);
      });

    if (!includeLowConfidence || reliable.length >= minReliablePicks) {
      return reliable.take(maxPicks).toList();
    }

    final limited = all.where((pick) => !pick.isReliable).toList()
      ..sort((a, b) {
        final bySmoothed = b.smoothedWinRate.compareTo(a.smoothedWinRate);
        if (bySmoothed != 0) return bySmoothed;

        final byGames = b.games.compareTo(a.games);

        return byGames != 0 ? byGames : a.championId.compareTo(b.championId);
      });

    return [...reliable, ...limited].take(maxPicks).toList();
  }

  static List<String> _lanesBy(
    MatchupDataset dataset,
    bool Function(Matchup matchup) concerned,
  ) {
    final games = <String, int>{};

    for (final matchup in dataset.matchups) {
      if (!concerned(matchup)) continue;
      games[matchup.lane] = (games[matchup.lane] ?? 0) + matchup.games;
    }

    return games.keys.toList()
      ..sort((a, b) => games[b]!.compareTo(games[a]!));
  }
}
