# Contrat : `DataDragonService` et `OfflineJsonCache`

## `DataDragonService` (`lib/data_dragon/data_dragon_service.dart`)

```dart
class DataDragonService {
  /// Dernière version du jeu. Le futur est partagé entre appelants ; un échec
  /// n'est pas conservé (le prochain appel retente). Hors ligne : version de la copie `versions`.
  static Future<String> latestVersion();

  /// Forme commune {"data": {...}} ; sert de `isValid`.
  static bool hasDataMap(dynamic decoded);

  /// Télécharge et décode un JSON. Lève toujours une DataDragonException en cas de panne.
  static Future<dynamic> fetchJson(
    String url, {
    String? offlineKey,                       // active la copie hors ligne
    bool Function(dynamic decoded)? isValid,  // forme attendue ; refus = panne
    int? offlineKeepLast,                     // borne la famille `famille:nom`
  });

  static String dataUrl(String version, String fileName);
  static String mapImageUrl(String version, String mapId);
  static String perkIconUrl(String iconPath);
}
```

Garanties :

- délai de 15 secondes ; exceptions réseau converties en `DataDragonException` ;
- document accepté seulement s'il est décodable et passe `isValid` ; alors seulement la copie est écrite ;
- en cas de panne avec `offlineKey` : copie resservie si elle est lisible et valide, sinon la panne d'origine ;
- sans `offlineKey` : jamais de copie ni de relecture.

## `DataDragonException` (`lib/data_dragon/data_dragon_exception.dart`)

```dart
class DataDragonException implements Exception {
  const DataDragonException(String message);
  final String message; // affichable à l'utilisateur
}
```

## `OfflineJsonCache` (`lib/data_dragon/offline_json_cache.dart`)

```dart
class OfflineJsonCache {
  static Future<void> write(String key, String body, {int? keepLast}); // n'échoue jamais
  static Future<String?> read(String key);                              // null si absent ou erreur
}
```

Interne à `lib/data_dragon/` : les autres modules passent par `fetchJson`.

## Consommateurs

| Service | Nom de copie | `isValid` | Borne |
|---------|-------------|-----------|-------|
| `ChampionService.fetchAll` | `champions` | `hasDataMap` | — |
| `ChampionService.fetchDetail` | `champion:<id>` | `hasDataMap` | 12 |
| `ItemService` | `items` | `hasDataMap` | — |
| `RuneService` | `runes` | liste | — |
| `SummonerSpellService` | `summoners` | `hasDataMap` | — |

## `MapPage` (`lib/map/map_page.dart`)

```dart
const MapPage({Key? key, Future<String> Function() loadVersion = DataDragonService.latestVersion});
```

`loadVersion` est injectable pour tester sans réseau ; chaque « Réessayer » l'appelle de nouveau.

## Messages utilisateur

`userMessageFor(Object error)` (`lib/shared/errors/user_message.dart`) : le message de la `DataDragonException`, sinon « Chargement impossible pour le moment. ».
