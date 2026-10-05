# Quickstart : valider la carte du dernier patch

## Lancer l'application

```bash
flutter pub get
flutter run -d chrome        # ou un appareil mobile
```

## Scénarios à la main

1. **Carte présente** : avec une connexion, ouvrir l'onglet Accueil. Attendu : sous la carte du champion du jour, une carte « DERNIER PATCH » / « Notes de patch 26.xx » (le numéro de saison de la dernière version + 10).
2. **Ouverture** : appuyer sur la carte. Attendu : le navigateur s'ouvre sur la page `…/news/game-updates/league-of-legends-patch-26-xx-notes`. Vérifier à la main que cette page existe pour le patch courant (le motif d'adresse n'est pas testé en réseau).
3. **Échec d'ouverture** : sur un appareil sans navigateur, appuyer sur la carte : le message « Impossible d'ouvrir les notes de patch. » s'affiche.
4. **Sans version** : hors-ligne et sans copie locale de la version du jeu, ouvrir l'accueil. Attendu : accueil complet sans carte, sans message d'erreur propre à la carte.
5. **Lecteur d'écran** : la carte est annoncée « Lire les notes du patch 26.xx », bouton.

## Tests automatisés

```bash
flutter test test/patch_notes
flutter analyze lib/patch_notes lib/home
```

| Exigence | Vérification |
|----------|--------------|
| FR-002 | `test/patch_notes/patch_notes_test.dart` (3 tests : déduction, version sans correctif, version illisible) |
| FR-001, FR-003, FR-004, FR-005, FR-006, FR-007 | à la main (scénarios ci-dessus) ; pas de test de widget |
