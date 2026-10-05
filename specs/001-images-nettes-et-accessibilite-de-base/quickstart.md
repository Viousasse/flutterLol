# Quickstart : Images nettes et accessibilité de base

## Validation à la main

1. Lancer l'application (`flutter run -d chrome` ou sur un appareil) avec une connexion active.
2. Ouvrir l'onglet des champions. **Attendu** : chaque carte montre une illustration verticale nette (pas d'icône étirée) et la tête du champion est visible.
3. Ouvrir la comparaison de champions et choisir un champion dans un emplacement. **Attendu** : même illustration, visage dans le cadre.
4. Couper puis rétablir le réseau (ou limiter la vitesse dans les outils du navigateur) et faire défiler la liste. **Attendu** : une case qui pulse doucement à la place des images en attente.
5. Bloquer `ddragon.leagueoflegends.com` (ou saisir un identifiant inexistant) pour un champion. **Attendu** : un rectangle de couleur de surface, aucun bloc d'erreur rouge.
6. Sur mobile, relancer l'application hors ligne après un premier chargement. **Attendu** : les images déjà vues s'affichent depuis le cache disque.
7. Activer TalkBack ou VoiceOver, se placer sur l'étoile d'une carte. **Attendu** : « Ajouter aux favoris, bouton » ; après un appui, « Retirer des favoris ».
8. Se placer sur chaque onglet de la barre du bas. **Attendu** : le libellé, « bouton », et « sélectionné » sur l'onglet actif.
9. Basculer entre le mode clair et le mode sombre. **Attendu** : le texte discret (sous-titres, légendes) reste lisible dans les deux.

## Tests automatisés

```bash
flutter test test/main_navigation/app_nav_bar_test.dart
flutter test test/theme/contrast_test.dart
flutter analyze lib/shared/widgets/remote_image lib/shared/widgets/shimmer_box lib/champions
```

Rappel : aucun test ne couvre directement `RemoteImage`, `ShimmerBox`, `ChampionCard` ni `portraitUrl` (voir « Hypothèses et limites connues » dans `spec.md`).
