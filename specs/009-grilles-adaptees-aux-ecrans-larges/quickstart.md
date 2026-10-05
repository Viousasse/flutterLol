# Quickstart : valider les grilles adaptées aux écrans larges

## Scénarios à la main

1. Lancer l'application sur le web (`flutter run -d chrome`) avec une fenêtre d'environ 1200 px.
2. Ouvrir l'onglet **Objets** : les cartes sont petites (130 px au plus) et plus nombreuses par ligne ; aucune carte géante.
3. Réduire la fenêtre à 360 px (ou ouvrir sur un téléphone) : 3 colonnes, nom sur deux lignes entièrement lisible.
4. Augmenter la taille de police du système (ou l'échelle de texte du navigateur) : les cartes d'objets grandissent en hauteur sans rogner le texte.
5. Ouvrir l'onglet **Champions** : 2 colonnes à 360 px, davantage en fenêtre large, cartes de 220 px au plus.
6. Mettre un champion et un objet en favoris, ouvrir **Favoris** : mêmes tailles de cartes que dans les listes.

## Tests automatisés

Aucun test dédié à cette fonctionnalité (voir `plan.md`, Complexity Tracking). Vérifier au moins que rien n'est cassé :

```bash
flutter analyze lib/champions lib/items lib/favorites
flutter test test/champions test/items
```
