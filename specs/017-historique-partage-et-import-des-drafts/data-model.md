# Data Model: Historique, partage et import des drafts

## DraftRecord (`lib/draft/models/draft_record.dart`)

Une draft terminée, immuable.

| Champ | Type | Règle |
|-------|------|-------|
| `id` | `String` | microsecondes de l'horloge (`DraftHistoryStore.newId()`) ; unique dans l'historique ; neuf à chaque import |
| `playedAt` | `DateTime` | date de la partie ; conservée à l'import |
| `versusFriend` | `bool` | vrai à deux, faux contre le site |
| `blueName`, `redName` | `String` | « Vous » / « Le site » par défaut à la relecture |
| `blue`, `red` | `List<String>` | identifiants dans l'ordre des rôles (`teamRoles`, 5 éléments exactement) ; `''` = rôle vide |
| `blueBans`, `redBans` | `List<String>` | identifiants bannis ; `''` = case vide ; absents = liste vide |
| `championNames` | `Map<String,String>` | identifiant vers nom ; `nameOf` retombe sur l'identifiant |
| `winner` | `DraftWinner` | `blue`, `red`, `tie` |
| `blueScore`, `redScore` | `double` | 0 par défaut à la relecture |
| `verdict` | `String` | texte du bilan ; vide par défaut |
| `assisted` | `bool` | joué avec les conseils ; absent = faux |
| `imported` | `bool` | reçu par code ; absent = faux |

**Validation à la relecture** (`tryFromJson`) : l'entrée est rejetée (`null`) si ce n'est pas une table, si `id` n'est pas une chaîne, si `playedAt` n'est pas une date, si `blue`/`red` ne sont pas des listes de cinq éléments, si `names` n'est pas une table ou si `winner` est inconnu.

**Sérialisation** : clés `id`, `playedAt` (ISO 8601), `versusFriend`, `blueName`, `redName`, `blue`, `red`, `blueBans`, `redBans`, `names`, `winner` (nom de l'énumération), `blueScore`, `redScore`, `verdict`, `assisted`, `imported`.

**Construction** : `DraftRecord.from(state, report, …)` extrait identifiants et noms de l'état de draft (cases vides en `''`).

## DraftHistoryStore (`lib/draft/services/draft_history_store.dart`)

État statique : `records` (`ValueNotifier<List<DraftRecord>>`), plus récent en premier, au plus 50.

Transitions : `ensureLoaded` (lecture unique, échec = historique vide et nouvelle tentative possible) ; `add` (en tête, remplace l'identifiant identique, tronque à 50) ; `delete(id)` ; `clear()`. Chaque modification met à jour la liste en mémoire, puis écrit dans `shared_preferences` (clé `draft_history`) via une file séquentielle.

## DraftHistoryStats (`lib/draft/services/draft_history_stats.dart`)

Calculé à partir de la liste, jamais stocké.

| Champ | Sens |
|-------|------|
| `total` | toutes les drafts |
| `againstSite` | drafts contre le site, jouées seul, non importées |
| `wins`, `ties`, `losses` | issue pour le camp bleu parmi `againstSite` |
| `winRate` | `wins / againstSite`, `null` si `againstSite == 0` |
| `mostPicked` | 5 `PickCount` (identifiant, nom, nombre) triés par nombre décroissant puis nom |
| `assistedCount`, `importedCount` | drafts concernées, tous modes confondus |

Règle de comptage des champions : camp bleu toujours ; camp rouge seulement si `versusFriend`.

## Code de partage `LOLD1.`

Voir `contracts/draft-share-code.md`.

## États d'une draft dans l'historique

```text
(jugée) --add--> enregistrée --delete/clear--> (supprimée)
(code reçu) --decode--> importée --add si non doublon--> enregistrée (imported = true)
enregistrée --Rejouer--> nouvelle draft (nouvel enregistrement à son tour, original inchangé)
```
