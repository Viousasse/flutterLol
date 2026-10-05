# Research: Objets favoris

## Extraire un magasin commun plutôt que dupliquer le service des champions

- **Decision**: `FavoriteIdsStore(storageKey)` porte tout le mécanisme ; `FavoritesService` et `ItemFavoritesService` ne sont que des façades statiques d'une ligne par méthode.
- **Rationale**: commentaire de `favorite_ids_store.dart` : champions et objets partagent cette mécanique et ne diffèrent que par leur clé de stockage. Le commit `993ab50` remplace le corps de `favorites_service.dart` (une soixantaine de lignes) par la façade.
- **Alternatives considered**: copier `FavoritesService` pour les objets n'est pas écrit dans les traces ; l'extraction est le choix retenu sans autre discussion.

## Un `ValueNotifier` écouté par tous les écrans

- **Decision**: `favorites` est un `ValueNotifier<Set<String>>` ; la carte, la fiche et l'onglet l'écoutent par `ValueListenableBuilder`. `toggle` crée un nouvel ensemble à chaque changement.
- **Rationale**: commentaire : basculer un favori depuis une fiche met à jour la carte qui l'a ouverte sans que l'une ait à connaître l'autre. Un nouvel ensemble est nécessaire pour que le notifieur déclenche (une mutation en place ne notifierait pas). Principe V de la constitution.
- **Alternatives considered**: aucun gestionnaire d'état externe (interdit sans justification par la constitution).

## Lecture avant le premier rendu

- **Decision**: `main()` attend `FavoritesService.ensureLoaded()` et `ItemFavoritesService.ensureLoaded()` (en parallèle avec `Future.wait`) avant `runApp`.
- **Rationale**: commentaire de `main.dart` : sans cela, les étoiles des cartes s'allumeraient après coup. Le futur de chargement est mis en cache pour que plusieurs écrans n'effectuent pas chacun leur lecture.
- **Alternatives considered**: aucune tracée.

## Écritures en file, sans rupture

- **Decision**: `_persist` enchaîne chaque écriture sur la précédente et avale ses erreurs (`catchError((_) {})`).
- **Rationale**: commentaire : sans cela, une écriture en échec ferait échouer toutes les suivantes et les favoris cesseraient silencieusement d'être enregistrés.
- **Alternatives considered**: aucune tracée.

## Stockage indisponible

- **Decision**: `_load` attrape toute erreur, laisse l'ensemble vide et remet `_loading` à `null`.
- **Rationale**: commentaire : démarrer sans favoris plutôt que de faire planter l'application, et permettre de retenter au prochain appel.
- **Alternatives considered**: aucune.

## Étoile discrète sur la carte, bouton sur la fiche

- **Decision**: la carte montre une étoile de 13 px à côté du prix quand l'objet est favori (aucune étoile sinon) ; la bascule se fait uniquement dans l'en-tête de la fiche, avec un `IconButton` dont l'info-bulle dit l'action.
- **Rationale**: aucune justification écrite dans le code. Constat : la carte est entièrement cliquable pour ouvrir la fiche, donc aucun bouton n'y a été placé, contrairement à la carte de champion qui a son badge.
- **Alternatives considered**: un badge cliquable comme sur la carte de champion n'a pas été retenu ; pas de trace de la raison.

## Page « Favoris » à deux onglets

- **Decision**: `FavoritesPage` passe de la seule liste de champions à un `TabBar` « Champions » / « Objets » ; le contenu de chaque onglet est un widget dédié (`FavoriteChampionsTab`, `FavoriteItemsTab`).
- **Rationale**: `993ab50` déplace le code de la page vers ces deux widgets (la page ne garde que le `TabBar` et le `TabBarView`) ; la grille des objets réutilise `itemGridDelegate` de la page des objets.
- **Alternatives considered**: un écran séparé pour les objets n'est pas évoqué.
