# Quickstart : valider la composition d'équipe

## Scénarios à la main

Lancer l'application (`flutter run -d chrome` ou un appareil), réseau disponible (Data Dragon).

1. Onglet Outils, entrée « Composition ». L'écran affiche cinq lignes vides (TOP, JUNGLE, MILIEU, BOT, SUPPORT) et la phrase « Placez des champions dans l'équipe… ».
2. Toucher la ligne TOP : la feuille de choix s'ouvre déjà filtrée sur le rôle Top. Choisir un champion : sa ligne affiche son portrait ; un petit indicateur tourne le temps que sa fiche se charge, puis la barre « DÉGÂTS » et la section « BILAN » apparaissent.
3. Placer un second champion : le bilan montre uniquement « Équipe incomplète » (moins de trois champions).
4. Placer un troisième puis un quatrième champion : trois constats (dégâts, première ligne, contrôle) puis « Il manque 2 champions… » (avec trois champions), « Il manque 1 champion… » (avec quatre).
5. Remplir avec cinq champions à dégâts surtout physiques (par exemple Garen, Darius, Jax, Yasuo, Zed) : « Peu de dégâts magiques » en avertissement orange ; barre entièrement physique.
6. Ajouter un tank (Malphite, Ornn…) : « Première ligne présente ».
7. Toucher la croix d'une ligne : le champion est retiré et le bilan se recalcule. Toucher l'icône corbeille de la barre du haut : toute l'équipe se vide ; l'icône disparaît.
8. Ouvrir la feuille de choix d'une place : les champions déjà placés n'y figurent pas.
9. Couper le réseau avant d'ouvrir l'écran (sans cache) : message d'erreur et bouton « Réessayer ».
10. Lecteur d'écran : une ligne se lit « Top, vide, appuyer pour choisir un champion » ; la barre « Dégâts : 60 % physiques, 40 % magiques ».

## Tests automatisés

```bash
flutter test test/team
flutter analyze lib/team test/team
```

Aucun test ne passe par le réseau : `test/team/team_analyzer_test.dart` construit des fiches de champions sur place.
