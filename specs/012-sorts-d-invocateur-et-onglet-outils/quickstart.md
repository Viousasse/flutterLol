# Quickstart : valider les sorts d'invocateur et l'onglet Outils

## Scénarios à la main

Lancer l'application (`flutter run -d chrome` ou un appareil), réseau disponible.

1. **Barre de navigation** : six onglets au bas de l'écran, dans l'ordre Accueil, Champions, Quiz, Objets, Outils, Carte. L'onglet actif a une icône pleine, un libellé plus gras et un trait doré au-dessus.
2. **Page Outils** : toucher « Outils ». Titre « Outils », sous-titre « Préparez votre partie », cinq tuiles sur deux colonnes : Contre-picks, Points forts, Composition, Comparer, Mes builds.
3. **Ouverture d'un outil** : toucher « Contre-picks » : l'écran s'ouvre avec une flèche de retour ; revenir ramène à la page Outils. Faire de même pour les quatre autres tuiles.
4. **État conservé** : sur la page Outils, faire défiler (fenêtre basse), changer d'onglet puis revenir : la position est conservée.
5. **Accueil** : l'accueil ne contient plus de section « Outils ».
6. **Sorts d'un jungler** : onglet Champions, ouvrir par exemple Lee Sin ou Vi. Après le chargement, la section « Sorts d'invocateur » (sous « Runes conseillées ») montre Châtiment et Saut éclair avec leur recharge, leur description et « En jungle, Châtiment sert à sécuriser les monstres et les objectifs. »
7. **Sorts d'un tireur** : ouvrir Jinx ou Caitlyn : Saut éclair et Soins.
8. **Sorts d'un combattant en haut** : ouvrir Garen : Saut éclair et Téléportation.
9. **Voie inconnue** : ouvrir un champion très peu présent dans les données (moins de 30 parties) : les sorts dépendent alors de son premier tag.
10. **Échec silencieux** : couper le réseau après avoir ouvert une fiche déjà en cache : la fiche reste complète, et la section de sorts peut être absente sans message.
11. **Lecteur d'écran** : les onglets sont annoncés « Outils, bouton, sélectionné » quand actifs ; une tuile se lit « Contre-picks, Qui jouer contre lui ? ».

## Tests automatisés

```bash
flutter test test/summoner_spells test/main_navigation test/matchups/main_lane_test.dart
flutter analyze lib/summoner_spells lib/tools lib/main_navigation lib/champion_detail/widgets/summoner_spell_section
```

Les tests n'appellent pas le réseau. Il n'existe pas de test d'écran de l'onglet Outils (voir `plan.md`, Complexity Tracking).
