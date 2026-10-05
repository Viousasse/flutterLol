# Data Model: Outil de mise à jour des matchups

## Tally (`tool/matchup_tally.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `games` | `int` | parties de la paire dans la voie |
| `wins` | `int` | victoires du champion ; ne dépasse jamais `games` après vieillissement |

Clé de regroupement : `champion|adversaire|voie` (chaîne). Chaque partie crée deux lignes symétriques (A contre B et B contre A) : les deux champions de la voie.

## Fichier de matchups (`assets/data/champion_matchups.json`)

Voir `contracts/matchups-file.md`. Lu par `MatchupDataset.fromJson` (`lib/matchups/models/matchup.dart`), qui retient `patch` (nullable), `matches` (0 par défaut) et `matchups` ; il ignore `generatedAt`, `platform`, `rank` et `patches`.

## Progression (`<sortie>.progress.json`)

| Champ | Type | Sens |
|-------|------|------|
| `used` | `int` | parties exploitées (au moins une voie comptée) |
| `patches` | `Map<patch,int>` | parties par patch |
| `matchIds` | `List<String>` | parties déjà traitées (y compris 404 et patchs trop anciens) |
| `tally` | `Map<clé,[games,wins]>` | bilans déjà comptés |

Écrite toutes les 100 parties traitées, à l'arrêt sur erreur et en fin de lecture, via un fichier `.tmp` renommé.

## États d'une exécution

```text
démarrage -> lecture du classement -> collecte des identifiants -> traitement des parties
          -> (sauvegarde périodique) -> [fusion avec l'existant, vieillissement] -> écriture du fichier final
erreur HTTP autre que 404 : sauvegarde -> arrêt
```

## Règles de vieillissement

`games' = round(games × f)` ; paire supprimée si `games' <= 0` ; `wins' = min(round(wins × f), games')` ; `matches' = round(matches × f)` ; `patches[p]' = round(n × f)`, retiré si 0.

## Étiquette de patch

`patchRange(a, b)` : identiques = un patch ; sinon plage `plus ancien–plus récent` sur les extrémités lisibles ; si rien n'est lisible, `a`.
