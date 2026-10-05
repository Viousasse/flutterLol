# Contrat : services de favoris

## `FavoriteIdsStore` (`lib/shared/services/favorite_ids_store/favorite_ids_store.dart`)

```dart
class FavoriteIdsStore {
  FavoriteIdsStore(String storageKey);

  final String storageKey;
  final ValueNotifier<Set<String>> favorites;   // vide au départ

  Future<void> ensureLoaded();                  // lecture unique et partagée ; échec = départ vide, retentable
  bool isFavorite(String id);
  Future<void> toggle(String id);               // charge si besoin, publie un nouvel ensemble, puis persiste en file
}
```

## `ItemFavoritesService` (`lib/items/services/item_favorites_service.dart`)

```dart
class ItemFavoritesService {
  static ValueNotifier<Set<String>> get favorites;   // clé de stockage : 'favorite_items'
  static Future<void> ensureLoaded();
  static bool isFavorite(String itemId);
  static Future<void> toggleFavorite(String itemId);
}
```

## `FavoritesService` (`lib/champions/services/favorites_service.dart`)

```dart
class FavoritesService {
  static ValueNotifier<Set<String>> get favorites;   // clé de stockage : 'favorite_champions'
  static Future<void> ensureLoaded();
  static bool isFavorite(String championId);
  static Future<void> toggleFavorite(String championId);
}
```

Même contrat que `ItemFavoritesService` ; aucune méthode de réinitialisation n'existe pour les tests : ils posent des valeurs avec `SharedPreferences.setMockInitialValues` avant `ensureLoaded`, et le magasin statique garde son état en mémoire pendant toute l'exécution d'un fichier de test.

## Widgets consommateurs

| Widget | Fichier | Usage |
|--------|---------|-------|
| `ItemCard` | `lib/items/widgets/item_card/item_card.dart` | étoile de 13 px si l'objet est favori |
| `ItemDetailHeader` | `lib/items/widgets/item_detail_sheet/item_detail_header.dart` | `IconButton` étoile ; info-bulle « Ajouter aux favoris » / « Retirer des favoris » |
| `FavoriteItemsTab` | `lib/favorites/widgets/favorite_items_tab/favorite_items_tab.dart` | grille des objets favoris, état vide, erreur avec « Réessayer » |
| `FavoritesPage` | `lib/favorites/favorites_page.dart` | deux onglets « Champions » et « Objets » |

## Initialisation

`lib/main.dart` : `await Future.wait([FavoritesService.ensureLoaded(), ItemFavoritesService.ensureLoaded(), ThemeService.ensureLoaded()])` avant `runApp`.
