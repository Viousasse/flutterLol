# Implementation Plan: Objets favoris

**Branch**: `004-objets-favoris` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/004-objets-favoris/spec.md`

## Summary

La logique des favoris de champions (`ValueNotifier` + `shared_preferences` + file d'écriture) est extraite dans un `FavoriteIdsStore` partagé (`lib/shared/services/favorite_ids_store/`). `FavoritesService` (champions, clé `favorite_champions`) et le nouveau `ItemFavoritesService` (objets, clé `favorite_items`) n'en sont plus que des façades statiques. La carte d'objet, la fiche d'objet et un nouvel onglet « Objets » de la page « Favoris » lisent ce notifieur ; `main()` relit les deux jeux avant le premier affichage.

## Technical Context

**Language/Version**: Dart 3 / Flutter (SDK `^3.13.3`)

**Primary Dependencies**: `shared_preferences` ; aucune nouvelle dépendance

**Storage**: `shared_preferences`, clés `favorite_items` et `favorite_champions` (listes de chaînes)

**Testing**: `flutter_test` avec `SharedPreferences.setMockInitialValues`

**Target Platform**: mobile et web

**Project Type**: application mobile Flutter

**Performance Goals**: mise à jour immédiate des écrans ouverts via `ValueListenableBuilder`

**Constraints**: lecture avant le premier rendu (`main`) ; aucun appel réseau dans les tests ; liste d'objets fournie par `ItemService` (copie hors ligne possible)

**Scale/Scope**: un ensemble d'identifiants par type (quelques dizaines au plus)

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Entorse, voir Complexity Tracking | Service d'objets dans `lib/items/services/item_favorites_service.dart`, mécanisme dans `lib/shared/services/favorite_ids_store/favorite_ids_store.dart` ; mais `lib/favorites/widgets/favorite_items_tab/favorite_items_tab.dart` importe `ItemCard` et `ItemDetailSheet` de `lib/items/widgets/` |
| II. Données Riot, erreurs affichables | Respecté | `favorite_items_tab.dart` attrape l'erreur de `ItemService.fetchAll`, affiche `userMessageFor` et `ErrorRetryView` |
| III. Images via RemoteImage | Sans objet | Les cartes réutilisent `ItemCard`, qui utilise `RemoteImage` |
| IV. Thème centralisé | Respecté | `AppColors.accent` pour l'étoile ; aucune couleur en dur ajoutée |
| V. État simple et local | Respecté | `ValueNotifier<Set<String>>` exposé par un service, relu dans `main()`, persisté avec `shared_preferences` ; l'onglet est un `StatefulWidget` avec `setState` |
| VI. Tests | Respecté en partie, voir Complexity Tracking | `test/items/services/item_favorites_service_test.dart`, `test/champions/services/favorites_service_test.dart` ; pas de test de widget |
| VII. Lisibilité, français | Respecté | Commentaires qui expliquent le pourquoi dans `favorite_ids_store.dart` et `main.dart` ; textes en français |

## Project Structure

### Documentation (this feature)

```text
specs/004-objets-favoris/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── favorites-services.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── main.dart                                          # relit les favoris avant runApp
├── shared/services/favorite_ids_store/favorite_ids_store.dart   # mécanisme commun
├── champions/services/favorites_service.dart          # façade champions (refactorée)
├── items/
│   ├── services/item_favorites_service.dart           # façade objets
│   └── widgets/
│       ├── item_card/item_card.dart                   # petite étoile
│       └── item_detail_sheet/item_detail_header.dart  # bouton étoile
└── favorites/
    ├── favorites_page.dart                            # deux onglets
    └── widgets/
        ├── favorite_champions_tab/favorite_champions_tab.dart
        └── favorite_items_tab/favorite_items_tab.dart

test/
├── items/services/item_favorites_service_test.dart
└── champions/services/favorites_service_test.dart
```

**Structure Decision**: extraction du mécanisme dans `shared/` (principe I : ce qui sert à plusieurs fonctionnalités va dans `lib/shared/`) ; la page « Favoris » existante est conservée et étendue.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principe I : `lib/favorites/` importe `ItemCard`, `ItemDetailSheet` (`lib/items/widgets/`) et `ChampionCard` (`lib/champions/widgets/`) | La page « Favoris » est un agrégateur : elle doit montrer les mêmes cartes que les pages d'origine, avec le même comportement | Dupliquer les cartes aurait créé deux versions à maintenir ; la constitution voudrait que ces widgets soient déplacés dans `shared/`, ce qui n'a pas été fait (dette) |
| Principe VI : aucun test de widget (onglet, carte, en-tête de fiche) ni test direct de `FavoriteIdsStore` | Le comportement central est couvert par les tests des deux façades | Dette reconnue |
