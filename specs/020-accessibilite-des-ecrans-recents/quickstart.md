# Quickstart : valider l'accessibilité des écrans récents

## Scénarios à la main

1. **Annonce d'une puce** : activer TalkBack (Android), VoiceOver (iOS) ou un lecteur d'écran du navigateur. Ouvrir les contre-picks d'un champion et se placer sur une puce de voie. Attendu : « Toutes les voies, bouton, sélectionné » ; sur une autre puce, « non sélectionné ».
2. **Zone tactile** : dans les contre-picks (ou les points forts), toucher quelques pixels au-dessus ou en dessous d'une puce de voie. Attendu : la puce réagit ; la pastille visible reste d'environ 32 px.
3. **Rangée de rôles** : ouvrir la feuille de choix d'un champion de la draft. Attendu : puces Tous, Top, Jungle, Milieu, Bot, Support facilement touchables, annoncées comme boutons avec leur état.
4. **Titres du bilan** : terminer une draft, parcourir au lecteur d'écran par titres. Attendu : VERDICT, POURQUOI, BANNISSEMENTS, CE QUI VA BIEN, À AMÉLIORER sont des titres ; « SUGGESTIONS » aussi quand l'aide est active.
5. **Feuille Affichage** : ouvrir le choix du thème. Attendu : « Affichage » est un titre.
6. **Contraste** : basculer entre mode sombre et clair ; le texte discret reste lisible partout (vérification automatique en commande ci-dessous).
7. **Changement visible à valider** : les lignes de puces de la barre de voies et de la rangée de rôles sont un peu plus espacées qu'avant.

## Commandes de test

```bash
flutter test test/shared/widgets/app_filter_chip_test.dart
flutter test test/draft/draft_a11y_test.dart
flutter test test/theme/contrast_test.dart
flutter analyze lib/shared/widgets lib/draft lib/theme
```
