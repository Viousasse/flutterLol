# Data Model: Filtre de rôle

Aucune donnée n'est enregistrée : tout est calculé en mémoire.

## Rôles (`lib/team/constants/team_roles.dart`)

| Rang | Libellé (`teamRoles`) | Voie Riot (`teamRoleLanes`) |
|------|----------------------|-----------------------------|
| 0 | Top | TOP |
| 1 | Jungle | JUNGLE |
| 2 | Milieu | MIDDLE |
| 3 | Bot | BOTTOM |
| 4 | Support | UTILITY |

## LaneProfile (`lib/matchups/services/lane_profile.dart`)

- Contenu : `Map<championId, Map<voie, nombre de parties>>`, construit en additionnant `games` de chaque ligne de matchup du jeu de données.
- `fits(championId, lane)` : faux si le champion est inconnu ; sinon vrai si `parties(lane) >= 8` ET `parties(lane) / total >= 0,15`.
- Constantes : `minShare = 0.15` ; seuil de parties `MatchupService.minGames = 8`.

## ChampionRoleFilter (`lib/shared/widgets/champion_picker_sheet/champion_role_filter.dart`)

| Champ | Sens |
|-------|------|
| `roles` | `Map<libellé, voie>` dans l'ordre d'affichage |
| `fits` | `bool Function(championId, lane)` |
| `initialLane` | voie présélectionnée ou `null` (= « Tous ») |

## État de la feuille

`lane` (`String?`) : `null` = « Tous ». Un champion est listé si : non exclu, son nom (minuscules) contient la recherche, et (pas de filtre, ou `lane == null`, ou `fits(id, lane)`).
