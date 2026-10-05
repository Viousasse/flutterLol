import '../../matchups/services/matchup_service.dart';

/// Un champion et son bilan face à un adversaire donné.
class CounterPick {
  /// Nombre de parties fictives à 50 % ajoutées au bilan pour classer les
  /// petits échantillons : 3 victoires sur 3 parties valent alors environ
  /// 62 %, et non 100 %.
  static const priorGames = 10;

  final String championId;
  final int games;
  final int wins;

  const CounterPick({
    required this.championId,
    required this.games,
    required this.wins,
  });

  double get winRate => games == 0 ? 0 : wins / games;

  /// Vrai quand le bilan repose sur assez de parties pour être lu tel quel.
  bool get isReliable => games >= MatchupService.minGames;

  /// Taux de victoire tempéré par [priorGames] parties neutres. Il sert à
  /// classer les bilans peu fournis sans laisser un 2 sur 2 passer devant un
  /// 14 sur 20.
  double get smoothedWinRate => (wins + priorGames * 0.5) / (games + priorGames);
}
