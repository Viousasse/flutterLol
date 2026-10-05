# Quickstart : validation du thème clair / sombre

## Scénarios à la main

1. **Lancer** l'application (`flutter run -d chrome` ou un appareil). Ouvrir l'onglet Accueil.
2. **Bascule** : appuyer sur l'icône de lune/soleil à droite du message d'accueil (info-bulle « Changer l'affichage (clair ou sombre) »). La feuille « Affichage » s'ouvre avec trois lignes.
   - Choisir « Clair » : tout l'écran passe en parchemin avec accent or foncé ; la feuille ouverte se repeint aussi ; la coche est sur « Clair ».
   - Choisir « Sombre » : bleu nuit et or pâle.
3. **Saisie conservée** : écrire quelques lettres dans la recherche, ouvrir la feuille, changer de mode ; le texte et l'onglet sont inchangés.
4. **Mémoire** : choisir « Clair », fermer complètement l'application, la rouvrir : elle démarre en clair sans clignotement du sombre.
5. **Automatique** : choisir « Automatique », changer le réglage clair/sombre de l'appareil (ou du navigateur) pendant que l'application est ouverte : elle suit.
6. **Carte du jour** : en mode clair, le nom, le titre, l'étiquette de rôle et « Lire son histoire › » de la carte « Champion du jour » restent lisibles sur la photo (texte clair, voile sombre).
7. **Teinte** : en mode clair, faire défiler une longue liste sous la barre du haut ; aucune teinte rosée.

## Tests automatisés

```bash
flutter test test/theme
flutter test test/draft/draft_a11y_test.dart
flutter analyze lib/theme lib/main.dart lib/home/widgets/champion_hero_card
```

Couverture : `app_palette_test.dart` (contrastes, mode actif), `contrast_test.dart` (texte sur puce sélectionnée), `theme_service_test.dart` (relecture, enregistrement, notifications, résolution automatique), `draft_a11y_test.dart` (titre « Affichage » annoncé comme titre). Les scénarios 3, 4 (premier rendu) et 6 ne sont pas couverts par un test automatisé.
