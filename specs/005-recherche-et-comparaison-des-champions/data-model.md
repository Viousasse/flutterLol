# Data Model: Recherche et comparaison des champions

Aucune donnée n'est créée ni persistée par cette fonctionnalité : les entités ci-dessous sont lues (Data Dragon, fichier embarqué, builds enregistrées) ou calculées à l'affichage.

## ChampionStats (`lib/champions/models/champion_stats.dart`)

Caractéristiques de base au niveau 1, lues dans la fiche détaillée.

| Champ | Type | Règle |
|-------|------|-------|
| health, armor, magicResist, attackDamage, attackSpeed, moveSpeed, attackRange | double | 0 si absent du JSON |
| healthPerLevel, armorPerLevel, magicResistPerLevel, attackDamagePerLevel | double | gain par niveau ; 0 par défaut |
| attackSpeedPerLevel | double | exprimé en pourcentage (2,5 pour 2,5 %) |
| attackRating, defenseRating, magicRating, difficulty | int | jauges de 0 à 10 ; 0 si absent |

`ChampionStats.empty()` : toutes les valeurs à 0. `ChampionDetail.stats` en porte une ; `Champion.difficulty` (int, 0 par défaut) existe aussi pour le tri de la liste.

## CombatStats (`lib/compare/models/combat_stats.dart`)

Valeurs d'un champion à un niveau donné, objets compris : `health`, `attackDamage`, `abilityPower`, `attackSpeed`, `armor`, `magicResist`, `moveSpeed`, `attackRange` (double) ; `critChance`, `lifeSteal` (fractions de 0 à 1) ; `difficulty` (int).

Règles de calcul (`CombatStatsCalculator.compute(base, level, items)`) :

- `growth = growthFactor(clamp(level, 1, 18))`, avec `growthFactor(n) = (n−1) × (0,7025 + 0,0175 × (n−1))`.
- `health = base.health + base.healthPerLevel × growth + Σ FlatHPPoolMod` ; idem pour dégâts (`FlatPhysicalDamageMod`), armure (`FlatArmorMod`), résistance magique (`FlatSpellBlockMod`).
- `abilityPower = Σ FlatMagicDamageMod` (aucun gain naturel).
- `attackSpeed = base.attackSpeed × (1 + base.attackSpeedPerLevel/100 × growth + Σ PercentAttackSpeedMod)`, plafonné à 2,5.
- `moveSpeed = (base.moveSpeed + Σ FlatMovementSpeedMod) × (1 + Σ PercentMovementSpeedMod)`.
- `attackRange = base.attackRange` ; `difficulty = base.difficulty` (insensibles au niveau et aux objets).
- `critChance = clamp(Σ FlatCritChanceMod, 0, 1)` ; `lifeSteal = Σ PercentLifeStealMod`.
- Un bonus d'objet absent de `Item.stats` compte pour 0.

## StatComparison (`lib/compare/models/stat_comparison.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| label | String | libellé français affiché |
| left, right | double | valeurs affichées ; critique et vol de vie multipliés par 100 |
| decimals | int | 2 pour la vitesse d'attaque, 0 sinon |

Dérivés : `winner` (`left`, `right` ou `tie` si valeurs égales) ; `leftFraction`/`rightFraction` = valeur / plus grande des deux, 0 si la plus grande est ≤ 0.

Ordre des lignes : Points de vie, Dégâts d'attaque, [Puissance], Vitesse d'attaque, Armure, Résistance magique, Vitesse de déplacement, Portée d'attaque, [Chances de coup critique (%)], [Vol de vie (%)], Difficulté. Les lignes entre crochets n'existent que si l'un des deux côtés est strictement positif.

## État de l'écran de comparaison (`ComparePage`)

| Champ | Valeur initiale | Remarque |
|-------|-----------------|----------|
| left, right | `left` = champion de la fiche d'origine ou vide ; `right` vide | deux champions distincts |
| level | 1 | conservé quand on change de champion |
| leftItems, rightItems | listes vides | 0 à 6 objets chacune (la case « + » disparaît à 6) |
| leftDetail, rightDetail | null | remis à null quand le champion change |
| isLoading, isLoadingDetails, errorMessage | true / false / null | états de chargement |

Transitions : choisir un champion → fiche remise à null puis rechargée ; ajout d'objet → ajoute en fin ; retrait → supprime l'index ; charger une build → remplace la liste d'objets.

## Résultats de recherche (`lib/search/services/global_search.dart`)

`SearchResults { champions, items }` : chacune au plus 8 éléments ; `isEmpty` si les deux sont vides. Une saisie dont la forme normalisée est vide donne `SearchResults.empty()`.

## Duel et bilan global (`lib/matchups/`)

- `Matchup` : `championId`, `opponentId`, `lane`, `games`, `wins` ; `winRate = wins/games`.
- `MatchupService.headToHead(championId, opponentId, dataset)` : additionne parties et victoires de toutes les voies ; `null` sous 8 parties (`minGames`).
- `OverallRecord { games, wins }` : `winRate`, `isReliable = games >= 100`. `MatchupService.overallFor` additionne toutes les parties du champion.

## Tri de la liste (`lib/champions/models/champion_sort.dart`)

`ChampionSort { name, difficultyAsc, difficultyDesc, winRate }` ; le bouton de tri les parcourt dans cet ordre en boucle (A-Z, Plus facile, Plus dur, Victoires).
