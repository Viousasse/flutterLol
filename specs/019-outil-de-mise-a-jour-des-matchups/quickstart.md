# Quickstart : valider l'outil de mise à jour des matchups

## Scénarios à la main (nécessitent une clé de développement Riot valide, 24 h)

Ne jamais écrire la clé dans un fichier : la passer par l'environnement le temps de la commande.

1. **Clé absente** : `dart run tool/generate_matchups.dart`. Attendu : « RIOT_API_KEY manquante dans l'environnement. », code de sortie 2, aucun fichier écrit.
2. **Petite génération** : `RIOT_API_KEY=RGAPI-... dart run tool/generate_matchups.dart --matches 400 --output build/matchups.json`. Attendu : progression « N parties exploitées », puis « … paires distinctes sur N parties (patch X.Y) → build/matchups.json ». Le fichier contient `generatedAt`, `patch`, `platform`, `rank`, `matches`, `patches`, `matchups`.
3. **Reprise** : interrompre (Ctrl+C) puis relancer la même commande avec `--resume`. Attendu : « Reprise : N parties déjà traitées. ».
4. **Mise à jour** : `… --matches 2000 --merge-with assets/data/champion_matchups.json --decay 0.5 --min-patch 16.20 --output build/matchups.json`. Attendu : « Fusion avec … : +N parties (M × 0.5, patch …) » et un `patch` en plage si plusieurs patchs.
5. **Arguments invalides** : `--decay 2` ou `--min-patch abc`. Attendu : message d'erreur, code 2.
6. **Installation** : copier `build/matchups.json` vers `assets/data/champion_matchups.json`, lancer `flutter test`, puis ouvrir une fiche champion : la section des contre-picks s'affiche, la note « d'où viennent les données » donne le patch ou la plage (« patchs 16.16–16.19 »).
7. **Couverture** : exécuter le script PowerShell du guide (`tool/README.md`, « Vérifier la couverture ») : il compte les champions ayant au moins un contre-pick à 8 parties ; comparer à environ 170.

## Commandes de test (sans clé, sans réseau)

```bash
flutter test test/tool/matchup_tally_test.dart
flutter test test/counters/counter_service_test.dart
flutter test test/matchups
flutter test test/quiz/quiz_generator_test.dart
dart analyze tool
```
