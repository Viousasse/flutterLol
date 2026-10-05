# Data Model: Sorts d'invocateur conseillés et onglet Outils

## SummonerSpell (`lib/summoner_spells/models/summoner_spell.dart`)

Lu depuis `summoner.json` de Data Dragon (`data` : un objet par sort, indexé par identifiant Riot).

| Champ | Type | Source JSON | Règle |
|-------|------|-------------|-------|
| `id` | `String` | `id` | ex. `SummonerFlash` |
| `name` | `String` | `name` | nom français (Data Dragon localisé) |
| `description` | `String` | `description` | texte vide si absent |
| `imageUrl` | `String` | `image.full` + version | `https://ddragon.leagueoflegends.com/cdn/<version>/img/spell/<fichier>` |
| `cooldown` | `int` | `cooldown[0]` | 0 si la liste est absente ou vide |

Validation : `SummonerSpell.isClassic(json)` est vrai si `modes` contient `CLASSIC` ; sinon (y compris `modes` absent) le sort est écarté.

## SummonerSpellPlan (`lib/summoner_spells/services/summoner_spell_recommender.dart`)

| Champ | Type | Règle |
|-------|------|-------|
| `spellIds` | `List<String>` | toujours deux identifiants |
| `reason` | `String` | phrase non vide expliquant le choix |

### Table de décision

| Voie principale | Profil (premier tag) | Sorts | 
|-----------------|----------------------|-------|
| `JUNGLE` | tous | Châtiment, Saut éclair |
| `BOTTOM` | tous | Saut éclair, Soins |
| `UTILITY` | Support | Saut éclair, Épuisement |
| `UTILITY` | autres | Saut éclair, Embrasement |
| `TOP` | Tank ou Fighter | Saut éclair, Téléportation |
| `TOP` | autres | Saut éclair, Embrasement |
| `MIDDLE` | Tank ou Fighter | Saut éclair, Téléportation |
| `MIDDLE` | autres | Saut éclair, Embrasement |
| inconnue (`null`) | Marksman | Saut éclair, Soins |
| inconnue | Support | Saut éclair, Épuisement |
| inconnue | Tank ou Fighter | Saut éclair, Téléportation |
| inconnue | autres | Saut éclair, Embrasement |

Un champion sans tag a le profil `Fighter`. Identifiants : `SummonerFlash`, `SummonerSmite`, `SummonerDot` (Embrasement), `SummonerTeleport`, `SummonerHeal`, `SummonerExhaust`.

## Outil (`_Tool`, privé à `tools_section.dart`)

`icon`, `label`, `hint`, `page` (constructeur d'écran).

| Ordre | Icône | Nom | Accroche | Écran |
|-------|-------|-----|----------|-------|
| 1 | `person_search` | Contre-picks | Qui jouer contre lui ? | `CountersPage` |
| 2 | `military_tech` | Points forts | Contre qui je suis fort ? | `StrengthsPage` |
| 3 | `groups_outlined` | Composition | Équilibrer son équipe | `TeamPage` |
| 4 | `compare_arrows` | Comparer | Deux champions, un niveau | `ComparePage` |
| 5 | `construction` | Mes builds | Objets et statistiques | `BuildsPage` |

## AppNavDestination (`lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`)

`label`, `icon` (au trait), `selectedIcon` (pleine). Destinations, par index : 0 Accueil, 1 Champions, 2 Quiz, 3 Objets, 4 Outils (`build_outlined` / `build`), 5 Carte.

## État de navigation (`_MainNavigationState`)

`currentIndex` (début : 0) et `visitedTabs` (ensemble d'index, début : `{0}`). Un onglet passe dans `visitedTabs` quand on le touche et n'en sort jamais.
