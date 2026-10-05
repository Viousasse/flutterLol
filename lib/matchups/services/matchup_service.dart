import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/matchup.dart';

class MatchupService {
  static const _asset = 'assets/data/champion_matchups.json';

  /// En dessous, un pourcentage ne veut rien dire : trois parties gagnées sur
  /// quatre n'est pas un « counter ». Ces paires sont tues plutôt qu'affichées.
  static const minGames = 8;

  static MatchupDataset? _cache;
  static Future<MatchupDataset>? _pending;

  /// Le futur en cours est mis en cache, pas seulement son résultat, comme
  /// pour les autres services.
  static Future<MatchupDataset> load() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);

    final pending = _pending;
    if (pending != null) return pending;

    final request = _load();
    _pending = request;

    return request;
  }

  static Future<MatchupDataset> _load() async {
    try {
      final raw = await rootBundle.loadString(_asset);
      final dataset = MatchupDataset.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _cache = dataset;

      return dataset;
    } finally {
      _pending = null;
    }
  }

  /// Adversaires contre lesquels [championId] perd le plus, du pire au moins
  /// mauvais, en ne gardant que les paires assez jouées pour être parlantes.
  static List<Matchup> hardestFor(String championId, MatchupDataset dataset) {
    return _significantFor(championId, dataset)
      ..sort((a, b) => a.winRate.compareTo(b.winRate));
  }

  /// Adversaires contre lesquels [championId] gagne le plus, du meilleur au
  /// moins bon.
  static List<Matchup> easiestFor(String championId, MatchupDataset dataset) {
    return _significantFor(championId, dataset)
      ..sort((a, b) => b.winRate.compareTo(a.winRate));
  }

  /// Bilan global de [championId] : toutes ses parties du fichier, quel que
  /// soit l'adversaire, ce qui donne un taux de victoire bien plus stable que
  /// chaque paire prise seule.
  static OverallRecord overallFor(String championId, MatchupDataset dataset) {
    var games = 0;
    var wins = 0;

    for (final matchup in dataset.matchups) {
      if (matchup.championId != championId) continue;
      games += matchup.games;
      wins += matchup.wins;
    }

    return OverallRecord(games: games, wins: wins);
  }

  /// Le bilan face à un adversaire précis, toutes voies confondues, ou `null`
  /// si les deux champions ne se sont jamais rencontrés assez souvent.
  static Matchup? headToHead(
    String championId,
    String opponentId,
    MatchupDataset dataset,
  ) {
    var games = 0;
    var wins = 0;
    String? lane;

    for (final matchup in dataset.matchups) {
      if (matchup.championId != championId) continue;
      if (matchup.opponentId != opponentId) continue;
      games += matchup.games;
      wins += matchup.wins;
      lane ??= matchup.lane;
    }

    if (games < minGames) return null;

    return Matchup(
      championId: championId,
      opponentId: opponentId,
      lane: lane ?? '',
      games: games,
      wins: wins,
    );
  }

  static List<Matchup> _significantFor(
    String championId,
    MatchupDataset dataset,
  ) {
    return dataset.matchups
        .where((m) => m.championId == championId && m.games >= minGames)
        .toList();
  }
}
