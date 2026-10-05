# Quickstart : valider les contre-picks et les points forts

## Scénarios à la main

Lancer l'application (`flutter run -d chrome` ou sur un appareil), connexion disponible pour les portraits (les résultats eux-mêmes sont hors-ligne).

1. **Contre-picks depuis Outils** : onglet Outils, entrée « Contre-picks ». L'écran invite à choisir le champion à affronter. Toucher la carte « JE JOUE CONTRE », choisir un champion très joué (Ahri, par exemple) : une liste « MEILLEURS CHOIX » apparaît, numérotée, avec pourcentage à droite et nombre de parties ; pourcentages décroissants.
2. **Voies** : sous la carte, la barre de voies propose « Toutes les voies » et les voies jouées. Choisir une voie : la liste change ; changer d'adversaire : la barre revient sur « Toutes les voies ».
3. **Peu de données** : choisir un champion rare. Les lignes à moins de 8 parties affichent « N parties · peu de données » en orange et une phrase explique qu'elles sont indicatives. La liste n'est jamais vide.
4. **Provenance** : sous la liste, lire « Données : 7 600 parties classées Master+ (EUW), patchs 16.16–16.19. » puis « Le pourcentage est celui du champion proposé face à … ».
5. **Ouvrir une fiche** : toucher une ligne ; la fiche du champion s'ouvre.
6. **Points forts** : Outils, « Points forts », carte « JE JOUE », choisir un champion. Sections « FORT CONTRE » puis « DIFFICILE CONTRE » (cette dernière peut manquer). Essayer le filtre de voie.
7. **Depuis la fiche d'un champion** : ouvrir une fiche, toucher « Qui jouer contre lui ? » (Contre-picks avec ce champion comme adversaire) puis « Contre qui est-il fort ? » (Points forts avec ce champion).
8. **Échec** : couper le réseau avant d'ouvrir l'écran sans cache de champions : message d'erreur avec « Réessayer ».
9. **Lecteur d'écran** : activer TalkBack ou VoiceOver ; une ligne se lit « Ahri, 55 % de victoires sur 120 parties » (avec « , peu de données » le cas échéant).

## Tests automatisés

```bash
flutter test test/counters test/strengths test/matchups
flutter test test/shared/widgets/data_source_note_test.dart test/shared/widgets/app_filter_chip_test.dart
flutter analyze lib/counters lib/strengths lib/matchups lib/shared/widgets/counter_tile lib/shared/widgets/lane_filter_bar lib/shared/widgets/data_source_note
```

Aucun de ces tests n'appelle le réseau. `test/counters/counter_service_test.dart` et `test/strengths/strengths_page_test.dart` lisent aussi le vrai fichier `assets/data/champion_matchups.json` pour garantir qu'aucun champion n'a de liste vide.
