# Quickstart : valider l'historique, le partage et l'import

## Scénarios à la main

Lancer l'application (`flutter run -d chrome` ou un appareil), puis :

1. **Sauvegarde automatique** : onglet Outils, page Composition, « Entraîneur de draft : jouer contre le site ». Jouer une draft complète (bannissements puis dix choix) jusqu'au verdict. Appuyer sur l'icône horloge de la barre d'en-tête. Attendu : la draft est en tête, avec « Vous contre Le site », le résultat, la date et dix icônes.
2. **Bilan** : en tête de page, « BILAN », « 1 draft jouée », le décompte contre le site et « LES PLUS CHOISIS ». Jouer la même draft avec l'aide des conseils : la tuile porte « AVEC AIDE » et le bilan « dont 1 avec aide (non comptées dans le taux) ».
3. **Persistance** : relancer l'application, rouvrir l'historique. Attendu : les drafts sont toujours là.
4. **Suppression** : icône corbeille d'une tuile, « Supprimer la draft » : elle disparaît. « Annuler » la conserve. Icône « Vider l'historique », « Tout supprimer » : message d'historique vide.
5. **Détail et rejeu** : toucher une tuile. Attendu : page « Détail de la draft ». « Rejouer avec les mêmes bannissements » : les bans sont posés, la page indique « choix 1 sur 10 ».
6. **Partage** : « Copier le résumé » (ou l'icône de partage de la tuile). Attendu : message « Résumé de la draft copié ». Coller le texte quelque part : il se termine par `Code : LOLD1.…`.
7. **Import** : dans l'historique, icône de téléchargement « Importer une draft ». Coller le texte copié à l'étape 6 puis « Importer ». Attendu : si la draft existe déjà, « Cette draft est déjà dans votre historique. » ; après avoir supprimé l'original, « Draft importée » et une tuile « IMPORTÉE » (le taux ne change pas).
8. **Texte invalide** : coller « bonjour » : la boîte reste ouverte avec « Ce texte ne contient pas de code de draft valide. ».
9. **Hors ligne** : couper le réseau et ouvrir l'historique avant tout chargement des champions : message d'erreur avec « Réessayer » et import désactivé.

## Commandes de test

```bash
flutter test test/draft/draft_history_test.dart
flutter test test/draft/draft_history_widgets_test.dart
flutter test test/draft/draft_record_page_test.dart
flutter test test/draft/draft_share_code_test.dart
flutter test test/draft/draft_import_test.dart
flutter test test/draft/draft_page_replay_test.dart
flutter test test/shared/widgets/paste_code_dialog_test.dart
flutter analyze lib/draft lib/shared/services/share_code lib/shared/widgets/paste_code_dialog
```
