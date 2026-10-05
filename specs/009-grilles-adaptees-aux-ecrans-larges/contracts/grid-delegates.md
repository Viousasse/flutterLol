# Contrat : délégués de grille

## `championGridDelegate`

Fichier : `lib/champions/constants/champion_grid.dart`

```dart
const championGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 0.82,
);
```

Consommateurs : `lib/champions/champions_page.dart` (`SliverGrid`), `lib/favorites/widgets/favorite_champions_tab/favorite_champions_tab.dart` (`GridView.builder`).

## `itemGridDelegate`

Fichier : `lib/items/constants/item_grid.dart`

```dart
SliverGridDelegate itemGridDelegate(BuildContext context)
```

- Largeur maximale d'une carte : 130 px ; espacement 12 px dans les deux axes.
- Hauteur de carte (`mainAxisExtent`) : `100 + 50 × MediaQuery.textScalerOf(context).scale(1)` px.
- Doit être appelée dans `build` (dépend de `MediaQuery`).

Consommateurs : `lib/items/items_page.dart` (`GridView.builder`), `lib/favorites/widgets/favorite_items_tab/favorite_items_tab.dart`.
