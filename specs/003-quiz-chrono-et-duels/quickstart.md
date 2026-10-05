# Quickstart : Quiz : chrono, historique des séries et duels

## Validation à la main

1. Lancer l'application (`flutter run -d chrome`), ouvrir l'onglet Quiz. **Attendu** : score, puces de familles (« Tout », Champions, Régions, Objets, Duels) et une puce « Chrono 15 s ».
2. Appuyer sur « Chrono 15 s ». **Attendu** : une barre et « 15 s » apparaissent ; le nombre baisse chaque seconde.
3. Laisser passer le temps. **Attendu** : à 5 s, la barre et le nombre passent en rouge ; à 0, « Temps écoulé : <réponse>. » s'affiche avec le bouton pour la question suivante ; la série retombe à 0.
4. Répondre avant la fin sur une autre question. **Attendu** : la barre disparaît dès la réponse ; sur « Suivante », le chrono repart à 15 s.
5. Pendant une question chronométrée, ouvrir un autre onglet, attendre plus de 15 s, revenir. **Attendu** : la question n'a pas expiré, le compte reprend.
6. Faire une série de 3 bonnes réponses, puis se tromper. **Attendu** : « DERNIÈRES SÉRIES  3 » apparaît sous le score. Relancer l'application : la ligne est toujours là. Désactiver le chrono : la barre disparaît.
7. Appuyer sur « Duels ». **Attendu** : question de la forme « En Mid, qui gagne le plus souvent : A ou B ? » (2 choix) ou « Quel champion gagne le plus souvent contre X en Mid ? » (3 à 4 choix, image de X). Aucun pourcentage dans l'énoncé ; après la réponse, une phrase « … gagne N % de ses duels contre … (M parties). ».
8. Pour tester le masquage : retirer temporairement l'asset des matchups (ou renommer son chemin) et relancer. **Attendu** : la puce « Duels » n'existe plus, les autres familles fonctionnent.
9. Réduire la fenêtre à 360 px. **Attendu** : toutes les puces sont visibles sans défilement.

## Tests automatisés

```bash
flutter test test/quiz/
flutter analyze lib/quiz test/quiz
```

Correspondance exigences et tests :

| Exigence | Test |
|----------|------|
| FR-003 | `quiz_timer_bar_test.dart` : `affiche les secondes restantes`, `la barre vire au rouge sur les dernières secondes` |
| FR-008, FR-009 | `quiz_score_service_test.dart` : `retient les séries terminées…`, `une série de zéro n est pas retenue`, `l historique est borné` |
| FR-011, FR-012, FR-013 | `matchup_quiz_test.dart` : `un face-a-face a deux choix…`, `la bonne réponse est la meilleure…`, `un duel trop peu joué est écarté`, `un écart trop faible ne donne aucune question`, `un champion inconnu de la liste ne sort jamais` |
| FR-014 | `les chiffres sont dans l explication, pas dans l énoncé` ; `quiz_generator_test.dart` : `les questions de matchup citent le nombre de parties` |
| FR-015 | `pas de doublon dans une même série` ; `quiz_generator_test.dart` : `deux questions de suite ne répètent pas le même énoncé` |
| FR-016 | `la famille disparaît sans données de duels` ; `quiz_category_bar_test.dart` : `une famille indisponible est masquée` |
| FR-018 | `reproductible avec la même graine` |
| SC-006 | `quiz_category_bar_test.dart` : `les cinq puces tiennent à 360 px` et `375 px` |
| FR-001, FR-002, FR-004 à FR-007, FR-010, FR-017 | vérifiés à la main uniquement (étapes 2 à 6) ; aucun test automatisé |
