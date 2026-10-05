# Data Model: Composition d'équipe

Aucune donnée n'est persistée : l'équipe vit dans l'état de l'écran et disparaît quand on le quitte.

## Rôles (`lib/team/constants/team_roles.dart`)

| Index | `teamRoles` | `teamRoleLanes` |
|-------|-------------|-----------------|
| 0 | Top | TOP |
| 1 | Jungle | JUNGLE |
| 2 | Milieu | MIDDLE |
| 3 | Bot | BOTTOM |
| 4 | Support | UTILITY |

Les voies sont celles de l'API de Riot, utilisées par le filtre de rôle.

## État de l'écran (`_TeamPageState`)

| Champ | Type | Rôle |
|-------|------|------|
| `champions` | `List<Champion>` | liste de Data Dragon |
| `slots` | `List<Champion?>` (5) | un champion ou rien par rôle |
| `details` | `Map<String, ChampionDetail>` | fiches déjà téléchargées, par identifiant |
| `loadingIds` | `Set<String>` | fiches en cours de téléchargement |
| `laneProfile` | `LaneProfile?` | où se joue chaque champion, pour le filtre |
| `isLoading`, `errorMessage` | | état de chargement de la liste |

Relation : un `TeamMember` = un champion de `slots` dont la fiche est dans `details`.

## TeamMember (`lib/team/models/team_member.dart`)

`champion: Champion` (portrait, nom, tags) et `detail: ChampionDetail` (sorts, `stats.attackRating`, `stats.magicRating`, `stats.defenseRating`).

## TeamAnalysis (`lib/team/models/team_insight.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `physicalShare` | `double` | 0 à 1 ; 0 si équipe vide ou dégâts nuls |
| `magicShare` | `double` | 0 à 1 ; `physicalShare + magicShare` vaut 1 ou 0 |
| `frontlineCount` | `int` | membres Tank ou de défense ≥ 7 |
| `controlSpellCount` | `int` | sorts (hors passif) dont la description contient un mot-clé |
| `memberCount` | `int` | membres analysés |
| `insights` | `List<TeamInsight>` | voir règles ci-dessous |

## TeamInsight

`kind` (`InsightKind.good`, `warning`, `info`), `title`, `message`.

### Règles de génération des constats

| Membres analysés | Constats |
|------------------|----------|
| 0 | aucun |
| 1 ou 2 | « Équipe incomplète » (info) |
| 3 à 5 | dégâts, première ligne, contrôle, puis « Équipe incomplète » (info) s'il manque des champions |

Constat de dégâts : magie < 20 % → « Peu de dégâts magiques » (warning) ; sinon physique < 20 % → « Peu de dégâts physiques » (warning) ; sinon « Dégâts équilibrés » (good). Première ligne : 0 → « Pas de première ligne » (warning) ; sinon « Première ligne présente » (good). Contrôle : < 3 → « Peu de contrôle » (warning) ; sinon « Contrôle suffisant » (good).

### Constantes

| Constante | Valeur |
|-----------|--------|
| `TeamAnalyzer.fullTeamSize` | 5 |
| `TeamAnalyzer.minMembersForVerdict` | 3 |
| `TeamAnalyzer.minDamageShare` | 0,2 |
| `TeamAnalyzer.frontlineDefense` | 7 |
| `TeamAnalyzer.minControlSpells` | 3 |
