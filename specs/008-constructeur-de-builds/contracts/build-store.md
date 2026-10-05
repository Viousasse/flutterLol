# Contrat : `BuildStore` et `Build`

Fichiers : `lib/builds/services/build_store.dart`, `lib/builds/models/build.dart`.

```dart
class Build {
  static const maxItems = maxItemSlots; // 6
  final String id;
  final String name;
  final String? championId;
  final List<String> itemIds;
  const Build({required String id, required String name,
      required List<String> itemIds, String? championId});
  Build copyWith({String? name, String? championId, List<String>? itemIds});
  Map<String, dynamic> toJson();
  static Build? tryFromJson(dynamic raw);
}

class BuildStore {
  static final ValueNotifier<List<Build>> builds;
  static Future<void> ensureLoaded();
  static String newId();
  static Future<void> save(Build build);
  static Future<void> delete(String id);
  @visibleForTesting static void reset();
}
```

## Garanties

- `builds` est mis à jour avant la fin de l'écriture : l'interface réagit tout de suite.
- `save` remplace la build de même `id` et place le résultat en tête.
- `ensureLoaded` peut être appelée plusieurs fois ; un échec du stockage laisse la liste vide et autorise une nouvelle tentative.
- Les écritures s'exécutent l'une après l'autre.
- Persistance : `shared_preferences`, clé `saved_builds`, `List<String>` de JSON (`{id, name, championId, itemIds}`).

## Consommateurs

`BuildsPage`, `BuildEditorPage`, `importBuildFromText`, le chargement d'une build dans la comparaison (`lib/compare`, voir la spécification 005), `BuildShareCode` (`newId`).

## Tests

`test/builds/build_store_test.dart`.
