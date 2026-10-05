# Data Model: Carte du dernier patch

Aucune donnée n'est persistée par cette fonctionnalité.

## PatchNotes (`lib/patch_notes/models/patch_notes.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| label | String | numéro tel qu'affiché sur le site, `"<saison+10>.<patch>"` (ex. `26.19`) |
| url | String | `https://www.leagueoflegends.com/fr-fr/news/game-updates/league-of-legends-patch-<saison+10>-<patch>-notes` |

Constantes : `_baseUrl` (adresse de base des mises à jour du jeu), `_seasonOffset = 10`.

### Construction

`PatchNotes.fromVersion(String version)` :

1. Découpe `version` sur `.` ; moins de deux parties → `null`.
2. Lit la première partie (saison) et la deuxième (patch) comme entiers ; l'une illisible → `null`.
3. Les parties suivantes (correctif) sont ignorées.

### Exemples

| Version Data Dragon | Résultat |
|---------------------|----------|
| `16.19.1` | label `26.19`, url `…league-of-legends-patch-26-19-notes` |
| `16.3` | label `26.3` |
| `abc`, `16.x.1`, `` | `null` |

## État de l'accueil

`_HomePageState.patchNotes : PatchNotes?` — `null` tant que la version n'est pas chargée ou si elle est inutilisable ; la carte n'est dans l'arbre que s'il est non nul.
