# Data Model : Draft à deux

## DraftMode (`lib/draft/models/draft_mode.dart`)

| Valeur | Sens |
|--------|------|
| `vsSite` | le joueur (bleu) affronte le site (rouge) ; `players` vaut `null` |
| `vsFriend` | deux joueurs, un appareil ; `players` vaut `friendPlayers` |

`friendPlayers = DraftPlayers(blue: 'Joueur 1', red: 'Joueur 2')`.

## DraftPlayers (`lib/draft/models/draft_report.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `blue` | `String` | nom du joueur du camp bleu |
| `red` | `String` | nom du joueur du camp rouge |

`of(DraftSide side)` renvoie le nom du camp. Un `DraftReport` à deux porte `players`, `redStrengths`, `redImprovements`, `redBanNotes` (voir spec 015).

## Règle d'un nom (`validatePlayerName`, `lib/draft/widgets/player_name_dialog/player_name_dialog.dart`)

- Le nom est nettoyé des espaces autour.
- Vide : refusé (« Saisissez un nom. »).
- Égal à l'autre nom, casse et espaces autour ignorés : refusé (« Ce nom est déjà pris par l'autre joueur. »).
- Longueur : 12 caractères au plus (`playerNameMaxLength`), contrôlée par le champ de saisie, non par la fonction.

## FriendSession (`lib/draft/services/friend_session_store.dart`)

| Champ | Type | Défaut | Règle |
|-------|------|--------|-------|
| `players` | `DraftPlayers` | `friendPlayers` | deux noms valides et distincts |
| `blueWins` | `int` | 0 | ≥ 0 |
| `redWins` | `int` | 0 | ≥ 0 |
| `ties` | `int` | 0 | ≥ 0 |

Dérivé : `isScoreEmpty` (les trois compteurs à 0). `copyWith(...)`. Immuable.

### Format de stockage

`shared_preferences`, clé `friend_session`, chaîne JSON :

```json
{"blue":"Léa","red":"Tom","blueWins":3,"redWins":2,"ties":1}
```

`FriendSession.tryFromJson(Object?)` renvoie `null` (donc les valeurs par défaut) si : l'objet n'est pas une table, `blue` ou `red` n'est pas une chaîne, un compteur n'est pas un entier, un compteur est négatif, un nom (après nettoyage) est vide ou égal à l'autre.

## Transitions de la soirée

| Événement | Effet |
|-----------|-------|
| Premier accès (`ensureLoaded`) | lit la clé ; absente, illisible ou invalide : valeurs par défaut |
| `rename(side, name)` | remplace le nom du camp (nettoyé) ; ignoré si vide ou égal à l'autre ; garde le score |
| `recordResult(winner)` | +1 victoire bleue, +1 victoire rouge ou +1 égalité |
| `resetScore()` | les trois compteurs à 0, noms conservés |

Chaque transition met à jour `FriendSessionStore.session` immédiatement, puis écrit (file d'écritures séquentielle ; un échec d'écriture est ignoré).

## Relations

- La page lit la soirée seulement si `replayOf == null` et le mode est `vsFriend`.
- Une draft à deux jugée est enregistrée dans l'historique (`DraftRecord`, spec 017) avec `versusFriend: true`, `blueName`, `redName` ; un rejeu relit ces champs.
