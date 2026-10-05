# Quickstart : valider le filtre de rôle

## Scénarios à la main

1. **Draft, choix** : ouvrir l'entraîneur de draft, passer les bannissements, toucher la case « Milieu ». Attendu : feuille « Rechercher un champion » avec les puces Tous, Top, Jungle, Milieu, Bot, Support ; « Milieu » est sélectionnée et seuls des champions de milieu sont listés.
2. **Changer de rôle** : toucher « Support » puis « Tous ». Attendu : la liste change à chaque toucher ; « Tous » rend la liste complète.
3. **Recherche** : sur « Top », taper « fio ». Attendu : Fiora seule (si elle est du poste), sinon « Aucun champion ne correspond. ».
4. **Bannissement** : toucher une case de bannissement. Attendu : « Tous » est sélectionnée.
5. **Composition** : ouvrir la page Composition, toucher la 2e case. Attendu : « Jungle » présélectionnée.
6. **Contre-picks, points forts, comparateur, éditeur de builds** : ouvrir la feuille de choix. Attendu : puces présentes, « Tous » sélectionnée.
7. **Sans données** : (test seulement) voir `test/team/role_filters_test.dart` : sans profil, pas de filtre.

## Commandes de test

```bash
flutter test test/shared/widgets/champion_picker_sheet_test.dart
flutter test test/team/role_filters_test.dart
flutter analyze lib/shared/widgets/champion_picker_sheet lib/team/services lib/matchups/services/lane_profile.dart
```
