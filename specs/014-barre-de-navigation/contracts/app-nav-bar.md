# Contrat : `AppNavBar`

Fichier : `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart`

```dart
class AppNavDestination {
  final String label;
  final IconData icon;          // onglet inactif
  final IconData selectedIcon;  // onglet actif
  const AppNavDestination({required this.label, required this.icon, required this.selectedIcon});
}

class AppNavBar extends StatelessWidget {
  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;   // reçoit l'index touché
  const AppNavBar({super.key, required this.destinations, required this.currentIndex, required this.onSelect});
}
```

## Comportement garanti

- Un onglet par destination, répartis à largeur égale (`Expanded`).
- L'onglet `currentIndex` affiche `selectedIcon`, un libellé en gras de couleur `AppColors.accent` et un trait de 28 px ; les autres affichent `icon`, un libellé de couleur `AppColors.textMuted` et aucun trait.
- Un appui (ou l'action sémantique « toucher ») appelle `onSelect(index)`, y compris sur l'onglet déjà actif.
- Sémantique : chaque onglet est un bouton, son libellé est celui de la destination, `selected` vaut vrai pour l'onglet actif ; les enfants sont exclus de l'arbre sémantique.
- Le widget est destiné à `Scaffold.bottomNavigationBar` ; il gère lui-même la zone de sécurité inférieure.

## Consommateur

`lib/main_navigation/main_navigation.dart` (`MainNavigation`) construit la liste de six destinations et passe `_openTab` comme `onSelect`.
