# Contrat : onglet Outils et barre de navigation

## `ToolsPage` (`lib/tools/tools_page.dart`)

```dart
class ToolsPage extends StatelessWidget { const ToolsPage({super.key}); }
```

Titre « Outils » (serif 32), sous-titre « Préparez votre partie », puis `ToolsSection`. Contenu dans une `SafeArea` et une `ListView`.

## `ToolsSection` (`lib/tools/widgets/tools_section/tools_section.dart`)

```dart
class ToolsSection extends StatelessWidget { const ToolsSection({super.key}); }
```

Cinq tuiles sur deux colonnes (largeur = `(largeur disponible − 10) / 2`, espacement 10). Une tuile : `Semantics(button, label: '<nom>, <accroche>')`, ouvre l'écran par `Navigator.push(MaterialPageRoute)`. La liste des outils est une constante privée du fichier (voir data-model.md pour l'ordre).

## `MainNavigation` (`lib/main_navigation/main_navigation.dart`)

```dart
class MainNavigation extends StatefulWidget { const MainNavigation({super.key}); }
```

Six destinations, index 0 à 5 : Accueil (`HomePage`), Champions (`ChampionsPage`), Quiz (`QuizPage`), Objets (`ItemsPage`), Outils (`ToolsPage`), Carte (`MapPage`). Un onglet n'est construit qu'après une première sélection ; il reste ensuite vivant dans un `IndexedStack`.

## `AppNavBar` (`lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`)

```dart
class AppNavDestination {
  const AppNavDestination({required String label, required IconData icon,
      required IconData selectedIcon});
}
class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required List<AppNavDestination> destinations,
      required int currentIndex, required ValueChanged<int> onSelect});
}
```

Chaque destination : `Semantics(button: true, selected, label)`, icône pleine quand elle est active, trait doré animé (3 px, 28 px de large) sur l'onglet actif, libellé en 10,5 pt réduit si besoin par `FittedBox`.
