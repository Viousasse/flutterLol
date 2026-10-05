# Data Model : Entraîneur de draft

Aucune donnée n'est stockée par cette fonctionnalité : l'état d'une draft vit en mémoire dans la page. La draft jugée est transformée en `DraftRecord` et confiée à l'historique (spec 017).

## DraftSide (`lib/draft/models/draft_state.dart`)

| Valeur | Sens |
|--------|------|
| `blue` | Le joueur (en mode à deux, le premier joueur) |
| `red` | Le site (en mode à deux, le second joueur) |

`opposite` renvoie l'autre camp.

## Constantes d'ordre (`lib/draft/models/draft_state.dart`)

- `draftPickOrder` : 10 entrées (B, R, R, B, B, R, R, B, B, R). Le rouge a le dernier choix.
- `bansPerSide` = 5 ; `draftBanOrder` : 10 entrées, alternance B, R, B, R…

## DraftState

| Champ | Type | Règle |
|-------|------|-------|
| `blue`, `red` | `List<Champion?>` de 5 | un champion par rôle, dans l'ordre de `teamRoles` (Top, Jungle, Milieu, Bot, Support) ; `null` = rôle libre |
| `blueBans`, `redBans` | `List<Champion?>` de 5, ou vides | vides quand la draft se joue sans bannissements ; un ban prend la première case libre |

Valeurs dérivées : `pickCount`, `banCount`, `totalBans`, `hasBans`, `isBanPhase` (`banCount < totalBans`), `isComplete` (`pickCount >= 10`), `nextSide` (camp qui doit jouer : ban pendant la phase de bannissements, choix ensuite, `null` quand terminé), `pickedIds`, `unavailableIds` (choisis ∪ bannis).

Validations (toutes par `StateError`) :

- `pick` : refus pendant la phase de bannissements, si le rôle du camp est pris, si le champion est choisi ou banni.
- `ban` : refus hors phase de bannissements, hors du tour du camp, si le champion est choisi ou banni.

Transitions : `empty(withBans)` → `ban`×10 (si bannissements) → `pick`×10 → complet. Chaque transition renvoie un nouvel état.

## DraftCriterion

| Champ | Type |
|-------|------|
| `title` | `String` : « Répartition des dégâts », « Première ligne », « Contrôle », « Duels de voie », « Taux de victoire moyen » |
| `winner` | `DraftWinner` (`blue`, `red`, `tie`) |
| `blueText`, `redText` | `String` : ce que fait chaque camp (« 62 % physiques, 38 % magiques », « 2 champions », « 3 sorts », « 2 voies », « 51,3 % ») |
| `explanation` | `String` : une phrase ; pour les voies, une phrase puis une ligne par rôle |

## DraftReport

| Champ | Type | Règle |
|-------|------|-------|
| `criteria` | `List<DraftCriterion>` | toujours 5, dans l'ordre ci-dessus |
| `blueScore`, `redScore` | `double` | 1 par critère gagné, 0,5 par nul |
| `winner` | `DraftWinner` | `tie` si `|blueScore − redScore| < 0,5` |
| `verdict` | `String` | « Votre draft est meilleure (3 contre 2), grâce à : … » ou « Les deux drafts se valent (… ). » |
| `strengths` | `List<String>` | critères gagnés par le bleu |
| `improvements` | `List<String>` | jamais vide (message de repli) |
| `players` | `DraftPlayers?` | `null` contre le site |
| `redStrengths`, `redImprovements` | `List<String>` | vides contre le site |
| `banNotes`, `redBanNotes` | `List<String>` | vides sans bannissements ; `redBanNotes` vide contre le site |

## DraftPlayers

`blue` et `red` (noms) ; `of(side)`. Utilisé seulement en mode à deux (016).

## BanAnalysis (`lib/draft/services/ban_analyzer.dart`)

`blue` et `red` : listes de remarques ; `isEmpty` ; `BanAnalysis.none()`.

## DraftSuggestion (`lib/draft/services/draft_advisor.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `roleIndex` | `int` | index dans `teamRoles` |
| `champion` | `Champion` | libre (ni choisi ni banni) |
| `reasons` | `List<String>` | 1 à 3 phrases ; `[DraftAdvisor.fallbackReason]` s'il n'y a aucune raison positive |
| `score` | `double` | barème du site sans aléa |

## DraftChoice (`lib/draft/services/draft_bot.dart`)

`roleIndex` et `champion` : le coup du site.

## Données externes lues

- `Champion` (nom, notes d'attaque, de défense, de magie, étiquettes) et `ChampionDetail` (sorts) : fonctionnalité champions.
- `MatchupDataset` / `Matchup` / `OverallRecord` : fonctionnalité 010 ; un bilan global est « fiable » à partir de 100 parties, un duel est utilisable à partir de 8 parties.
- `TeamAnalysis` (parts de dégâts, première ligne, sorts de contrôle) : outil « Composition ».
