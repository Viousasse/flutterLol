# Quickstart : validation de la barre de navigation

## Scénarios à la main

1. **Lancer** l'application (`flutter run -d chrome` ou un appareil) : six onglets en bas (Accueil, Champions, Quiz, Objets, Outils, Carte), chacun avec icône et libellé ; filet doré au-dessus ; l'onglet Accueil a une icône pleine, un libellé gras doré et un trait doré au-dessus de l'icône.
2. **Changer d'onglet** : appuyer sur « Quiz ». La page du quiz s'ouvre, le trait glisse (s'élargit) sur Quiz, l'icône de Quiz devient pleine, celle d'Accueil redevient au trait. La barre ne change pas de hauteur.
3. **État conservé** : dans « Champions », saisir une recherche, aller sur « Objets », revenir sur « Champions » : la recherche est toujours là.
4. **Chargement différé** : au démarrage, ne pas ouvrir « Carte » ; vérifier (réseau du navigateur) qu'aucune donnée de la carte n'est demandée avant le premier appui sur cet onglet.
5. **Écran étroit** : réduire la fenêtre à ~320 px de large : les libellés rétrécissent sans déborder.
6. **Modes** : en mode clair puis sombre (voir 013), la barre prend la surface, le filet et l'accent du mode.
7. **Lecteur d'écran** : chaque onglet est annoncé comme bouton ; l'actif comme sélectionné.

## Tests automatisés

```bash
flutter test test/main_navigation/app_nav_bar_test.dart
flutter analyze lib/main_navigation
```

Couverture : icône et libellé par destination, icône pleine pour l'actif, rappel `onSelect` au toucher, sémantique bouton/sélectionné. Les scénarios 3, 4 et 5 ne sont pas couverts par un test automatisé.
