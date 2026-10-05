# Contrat : `MatchupService` et `LaneProfile`

Fichiers : `lib/matchups/services/matchup_service.dart`, `lib/matchups/services/lane_profile.dart`.

```dart
class MatchupService {
  static const minGames = 8;
  static const minGamesForMainLane = 30;

  /// Lit l'asset une seule fois (futur en cours et résultat mis en cache).
  /// Un échec n'est pas mis en cache.
  static Future<MatchupDataset> load();

  static List<Matchup> hardestFor(String championId, MatchupDataset dataset); // pire d'abord
  static List<Matchup> easiestFor(String championId, MatchupDataset dataset); // meilleur d'abord
  static OverallRecord overallFor(String championId, MatchupDataset dataset);
  static String? mainLaneOf(String championId, MatchupDataset dataset);       // null si < 30 parties
  static Matchup? headToHead(String championId, String opponentId, MatchupDataset dataset); // null si < 8 parties
}

class LaneProfile {
  static const minShare = 0.15;
  factory LaneProfile.fromDataset(MatchupDataset dataset);
  bool fits(String championId, String lane);
}
```

- `hardestFor` et `easiestFor` ne gardent que les paires d'au moins `minGames` parties.
- `headToHead` additionne toutes les voies ; la voie renvoyée est la première rencontrée.
- `LaneProfile.fits` : au moins `minGames` parties dans la voie et au moins 15 % des parties du champion.
- Consommateurs hors de cette fonctionnalité : fiche champion (`matchup_section`, `mainLaneOf`), comparaison (`headToHead`), filtre de rôle (`LaneProfile`).
