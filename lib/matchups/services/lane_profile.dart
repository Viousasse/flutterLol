import '../models/matchup.dart';
import 'matchup_service.dart';

/// Où chaque champion se joue, d'après les parties analysées.
class LaneProfile {
  /// Part minimale des parties d'un champion dans une voie pour qu'on l'y
  /// considère à sa place : elle écarte les paris isolés (un mage en jungle une
  /// fois sur cinquante) sans exclure les vrais choix polyvalents.
  static const minShare = 0.15;

  final Map<String, Map<String, int>> _games;

  const LaneProfile._(this._games);

  factory LaneProfile.fromDataset(MatchupDataset dataset) {
    final games = <String, Map<String, int>>{};

    for (final matchup in dataset.matchups) {
      final byLane = games.putIfAbsent(matchup.championId, () => {});
      byLane[matchup.lane] = (byLane[matchup.lane] ?? 0) + matchup.games;
    }

    return LaneProfile._(games);
  }

  /// Vrai si [championId] se joue régulièrement dans [lane].
  bool fits(String championId, String lane) {
    final byLane = _games[championId];
    if (byLane == null) return false;

    final total = byLane.values.fold(0, (sum, games) => sum + games);
    final inLane = byLane[lane] ?? 0;

    return inLane >= MatchupService.minGames && inLane / total >= minShare;
  }
}
