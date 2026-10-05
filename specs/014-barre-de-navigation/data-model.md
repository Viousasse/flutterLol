# Modèle de données : Barre de navigation

Aucune donnée n'est persistée. L'état est local à `MainNavigation`.

## AppNavDestination (valeur immuable)

| Champ | Type | Sens |
|-------|------|------|
| `label` | `String` | libellé affiché et annoncé |
| `icon` | `IconData` | icône au trait, onglet inactif |
| `selectedIcon` | `IconData` | icône pleine, onglet actif |

Les six destinations, dans l'ordre (index 0 à 5) :

| Index | Libellé | Icône inactive | Icône active | Page |
|-------|---------|----------------|--------------|------|
| 0 | Accueil | `home_outlined` | `home` | `HomePage` |
| 1 | Champions | `shield_outlined` | `shield` | `ChampionsPage` |
| 2 | Quiz | `quiz_outlined` | `quiz` | `QuizPage` |
| 3 | Objets | `backpack_outlined` | `backpack` | `ItemsPage` |
| 4 | Outils | `build_outlined` | `build` | `ToolsPage` |
| 5 | Carte | `map_outlined` | `map` | `MapPage` |

## État de `MainNavigation`

- `currentIndex : int` (0 au départ) : onglet actif.
- `visitedTabs : Set<int>` (`{0}` au départ) : onglets déjà ouverts.

**Transition** : appui sur l'onglet `i` → `currentIndex = i` et `i` est ajouté à `visitedTabs`. Un onglet n'est jamais retiré de `visitedTabs` pendant la session. L'état est perdu à la fermeture de l'application.
