/// Bilan d'un champion face à un adversaire précis dans une voie, compté sur de
/// vraies parties classées par `tool/generate_matchups.dart`.
class Matchup {
  final String championId;
  final String opponentId;
  final String lane;
  final int games;
  final int wins;

  const Matchup({
    required this.championId,
    required this.opponentId,
    required this.lane,
    required this.games,
    required this.wins,
  });

  factory Matchup.fromJson(Map<String, dynamic> json) {
    return Matchup(
      championId: json['champion'] as String,
      opponentId: json['opponent'] as String,
      lane: json['lane'] as String,
      games: json['games'] as int,
      wins: json['wins'] as int,
    );
  }

  double get winRate => games == 0 ? 0 : wins / games;
}

/// Le fichier de matchups entier, avec de quoi dire d'où viennent les chiffres.
class MatchupDataset {
  final String? patch;
  final int matches;
  final List<Matchup> matchups;

  const MatchupDataset({
    required this.patch,
    required this.matches,
    required this.matchups,
  });

  const MatchupDataset.empty()
    : this(patch: null, matches: 0, matchups: const []);

  factory MatchupDataset.fromJson(Map<String, dynamic> json) {
    return MatchupDataset(
      patch: json['patch'] as String?,
      matches: json['matches'] as int? ?? 0,
      matchups: (json['matchups'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Matchup.fromJson)
          .toList(),
    );
  }

  bool get isEmpty => matchups.isEmpty;
}
