# Research: Filtre de rôle

## 1. La feuille ne connaît pas la notion de rôle

- **Decision**: `ChampionPickerSheet` reçoit un `ChampionRoleFilter` (rôles, règle `fits`, voie de départ) ; sans lui, pas de puces.
- **Rationale**: commentaire de `champion_role_filter.dart` : « La feuille ne sait pas ce qu'est un rôle : l'écran qui l'ouvre lui donne les rôles à proposer et la façon de savoir si un champion s'y joue. » La feuille reste utilisée par des écrans qui n'ont pas de rôle.
- **Alternatives considered**: pas de trace.

## 2. Les rôles viennent des parties analysées, pas d'une liste officielle

- **Decision**: `LaneProfile` additionne les parties de chaque champion par voie dans le fichier de matchups.
- **Rationale**: c'est la seule donnée de poste embarquée ; la liste de champions de Data Dragon ne donne que des classes (Mage, Tireur…), pas des postes.
- **Alternatives considered**: pas de trace écrite d'une autre source.

## 3. Seuils : 8 parties et 15 %

- **Decision**: un champion « se joue » dans une voie s'il y a au moins `MatchupService.minGames` (8) parties et au moins `LaneProfile.minShare` (0,15) de ses parties.
- **Rationale**: commentaire : la part minimale « écarte les paris isolés (un mage en jungle une fois sur cinquante) sans exclure les vrais choix polyvalents ». Le plancher de 8 parties réutilise celui des matchups. Les valeurs ne sont pas chiffrées autrement ; pas de test dédié.

## 4. Un échec ne bloque jamais le choix

- **Decision**: `RoleFilters.loadProfile` capture toute erreur et renvoie `null` ; `forProfile(null)` renvoie `null` ; la feuille s'ouvre sans puces.
- **Rationale**: « le filtre est un confort, son absence ne doit jamais empêcher de choisir un champion ».

## 5. Voie de départ selon la case touchée

- **Decision**: choix = voie du rôle de la case ; bannissement = « Tous ».
- **Rationale**: commentaire de `draft_page.dart` : « pour un bannissement, aucun rôle n'est imposé » (on peut bannir un champion de n'importe quel poste). Message du commit : « avec le role de la case touchee preselectionne ».

## 6. Déplacement de `LaneProfile`

- **Decision**: `lib/draft/services/lane_profile.dart` devient `lib/matchups/services/lane_profile.dart`.
- **Rationale**: il est utilisé par le bot, le conseiller et désormais par les filtres de plusieurs écrans ; la constitution interdit à une fonctionnalité d'importer les services internes d'une autre. Le commit `0afb3b1` le montre comme un renommage ; aucune justification écrite autre que celle-là.

## 7. Rangée de puces défilante

- **Decision**: `ListView` horizontal de 44 px de haut, « Tous » en tête.
- **Rationale**: commentaire « défilante pour tenir sur un petit écran ». La hauteur de 44 px est celle de la zone tactile (voir fonctionnalité 020).
