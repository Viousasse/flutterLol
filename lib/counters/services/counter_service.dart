import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../models/counter_pick.dart';

class CounterService {
  /// Nombre de propositions affichées : au-delà, la liste se lit comme un
  /// classement complet plutôt que comme un conseil.
  static const maxPicks = 15;

  /// Les champions qui s'en sortent le mieux face à [opponentId], du meilleur
  /// au moins bon.
  ///
  /// Sans [lane], les voies sont additionnées : un champion qui a affronté
  /// l'adversaire à deux endroits cumule ses parties. Les champions qui ont
  /// affronté l'adversaire moins de [MatchupService.minGames] fois sont écartés,
  /// car leur pourcentage ne veut rien dire.
  static List<CounterPick> counters(
    String opponentId,
    MatchupDataset dataset, {
    String? lane,
  }) {
    final games = <String, int>{};
    final wins = <String, int>{};

    for (final matchup in dataset.matchups) {
      if (matchup.opponentId != opponentId) continue;
      if (lane != null && matchup.lane != lane) continue;

      games[matchup.championId] =
          (games[matchup.championId] ?? 0) + matchup.games;
      wins[matchup.championId] = (wins[matchup.championId] ?? 0) + matchup.wins;
    }

    final picks = [
      for (final entry in games.entries)
        if (entry.value >= MatchupService.minGames)
          CounterPick(
            championId: entry.key,
            games: entry.value,
            wins: wins[entry.key] ?? 0,
          ),
    ];

    // À pourcentage égal, celui qui a le plus de parties derrière lui est plus
    // fiable ; puis l'ordre alphabétique garde une liste stable.
    picks.sort((a, b) {
      final byRate = b.winRate.compareTo(a.winRate);
      if (byRate != 0) return byRate;

      final byGames = b.games.compareTo(a.games);

      return byGames != 0 ? byGames : a.championId.compareTo(b.championId);
    });

    return picks.take(maxPicks).toList();
  }

  /// Les voies où [opponentId] a été affronté, par ordre de volume de parties :
  /// proposer une voie sans donnée mènerait à une liste vide.
  static List<String> lanesFor(String opponentId, MatchupDataset dataset) {
    final games = <String, int>{};

    for (final matchup in dataset.matchups) {
      if (matchup.opponentId != opponentId) continue;
      games[matchup.lane] = (games[matchup.lane] ?? 0) + matchup.games;
    }

    final lanes = games.keys.toList()
      ..sort((a, b) => games[b]!.compareTo(games[a]!));

    return lanes;
  }
}
