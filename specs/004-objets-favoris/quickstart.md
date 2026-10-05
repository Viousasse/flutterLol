# Quickstart : Objets favoris

## Validation à la main

1. Lancer l'application (`flutter run -d chrome`), ouvrir l'onglet des objets et toucher un objet. **Attendu** : la fiche s'ouvre avec une étoile vide en haut à droite.
2. Toucher l'étoile. **Attendu** : elle devient pleine et dorée ; l'info-bulle (appui long ou survol) dit « Retirer des favoris ». Fermer la fiche : la carte de l'objet dans la grille affiche une petite étoile à côté du prix.
3. Marquer un deuxième objet, puis revenir à l'accueil et ouvrir le raccourci des favoris (« Mes champions favoris »). **Attendu** : la page « Favoris » a deux onglets, « Champions » et « Objets ».
4. Ouvrir l'onglet « Objets ». **Attendu** : les deux objets, dans une grille de même présentation que la page des objets. Toucher l'un d'eux : sa fiche s'ouvre ; retirer son favori : la carte disparaît de la grille derrière la fiche.
5. Retirer le dernier favori. **Attendu** : « Aucun objet favori pour le moment ».
6. Marquer un objet et un champion, fermer complètement l'application, la rouvrir. **Attendu** : les deux étoiles sont déjà allumées au premier affichage.
7. Retirer l'objet : le champion reste en favori (et inversement).
8. Hors ligne, sans copie des objets (premier lancement), ouvrir l'onglet « Objets ». **Attendu** : message d'erreur et « Réessayer » ; après rétablissement du réseau, le bouton recharge la liste.

## Tests automatisés

```bash
flutter test test/items/services/item_favorites_service_test.dart
flutter test test/champions/services/favorites_service_test.dart
flutter analyze lib/items lib/favorites lib/shared/services/favorite_ids_store lib/champions/services/favorites_service.dart lib/main.dart
```

Correspondance exigences et tests :

| Exigence | Test |
|----------|------|
| FR-001, FR-008, SC-003 | `garde les objets favoris à part des champions favoris` (bascule, clé `favorite_items` distincte de `favorite_champions`) |
| FR-003, FR-012 | `relit les favoris enregistres et previent a chaque changement` (une notification par bascule) |
| FR-009, FR-010, FR-011 | vérifiés à la main (étape 6) et par lecture du code ; pas de test automatisé |
| FR-002, FR-004 à FR-007 | vérifiés à la main (étapes 2 à 5, 8) ; pas de test de widget |
