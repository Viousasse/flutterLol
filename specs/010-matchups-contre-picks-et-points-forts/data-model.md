# Data Model: Matchups, contre-picks et points forts

## Matchup (`lib/matchups/models/matchup.dart`)

Bilan d'un champion face à un adversaire dans une voie.

| Champ | Type | Règle |
|-------|------|-------|
| `championId` | `String` | identifiant Data Dragon du champion (ex. `Jhin`) ; JSON `champion` |
| `opponentId` | `String` | identifiant de l'adversaire ; JSON `opponent` |
| `lane` | `String` | `TOP`, `JUNGLE`, `MIDDLE`, `BOTTOM` ou `UTILITY` |
| `games` | `int` | parties jouées ; au moins 1 dans le fichier embarqué |
| `wins` | `int` | victoires du champion (0 ≤ wins ≤ games) |
| `winRate` | calculé | `wins / games`, 0 si `games == 0` |

Le fichier contient les deux sens d'un duel : `Jhin` contre `Yunara` et `Yunara` contre `Jhin` sont deux lignes, avec des victoires complémentaires (63 et 72 sur 135 dans le fichier).

## MatchupDataset

| Champ | Type | Règle |
|-------|------|-------|
| `patch` | `String?` | patch ou plage (`16.16–16.19`) ; `null` si absent |
| `matches` | `int` | parties analysées ; 0 si absent |
| `matchups` | `List<Matchup>` | vide si absent |

`MatchupDataset.empty()` : patch `null`, 0 partie, liste vide. `isEmpty` est vrai si la liste est vide. Un fichier sans clé `matches` ou `matchups` est toléré.

## OverallRecord

Bilan global d'un champion (`games`, `wins`, `winRate`). `isReliable` est vrai à partir de `minReliableGames = 100` parties. `OverallRecord.none()` = 0/0.

## CounterPick (`lib/counters/models/counter_pick.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `championId` | `String` | selon la requête : le champion qui contre (`counters`), ou l'adversaire (`strongAgainst`, `weakAgainst`) |
| `games` | `int` | parties additionnées (voies additionnées si aucune voie demandée) |
| `wins` | `int` | victoires du champion **qui est la cible du pourcentage** |
| `winRate` | calculé | `wins / games` |
| `isReliable` | calculé | `games >= MatchupService.minGames` (8) |
| `smoothedWinRate` | calculé | `(wins + 10 × 0,5) / (games + 10)` |

## Constantes de règles

| Constante | Valeur | Rôle |
|-----------|--------|------|
| `MatchupService.minGames` | 8 | seuil de fiabilité d'une paire |
| `MatchupService.minGamesForMainLane` | 30 | seuil pour déclarer une voie principale |
| `OverallRecord.minReliableGames` | 100 | seuil du bilan global |
| `CounterService.maxPicks` | 15 | taille maximale d'une liste de propositions |
| `CounterService.minReliablePicks` | 5 | bilans fiables au-dessous desquels on complète |
| `CounterService.maxWeaknesses` | 5 | taille de « DIFFICILE CONTRE » |
| `CounterPick.priorGames` | 10 | parties fictives à 50 % du taux tempéré |
| `LaneProfile.minShare` | 0,15 | part minimale des parties d'un champion dans une voie |
| `laneLabels` | TOP→Top, JUNGLE→Jungle, MIDDLE→Mid, BOTTOM→Bot, UTILITY→Support | libellés des voies |

## États d'un écran (Contre-picks et Points forts)

`chargement` → `erreur` (message + Réessayer, retour à `chargement`) ou `prêt`. Une fois `prêt` : `aucun champion choisi` → `champion choisi` (voie = toutes) → `voie choisie`. Résultat vide ou jeu de données vide : message dédié.
