# Quickstart : Entraîneur de draft

## Lancer l'application

```bash
flutter run            # mobile ou émulateur
flutter run -d chrome  # web
```

Aller dans l'onglet « Outils », ouvrir « Composition » (page d'équipe), puis toucher « Entraîneur de draft : jouer contre le site ».

## Scénario 1 : draft complète contre le site, avec bannissements (US1, US3, US4)

1. L'écran « Entraîneur de draft » s'ouvre. L'interrupteur « Bannissements » est actif, « Aide au choix » éteint. Le statut dit « À vous de bannir un champion (ban 1 sur 10) ».
2. Toucher la rangée de bannissements du côté « VOUS » : la feuille de choix s'ouvre ; toucher un champion. Il apparaît barré en gris ; le statut passe à « Le site bannit… » puis le site pose son ban.
3. Répéter jusqu'à dix bannis (cinq par camp). Le statut dit « À vous de choisir (choix 1 sur 10) ». Les deux interrupteurs ont disparu.
4. Toucher un rôle libre : la feuille s'ouvre sur ce rôle ; les bannis n'y figurent pas. Choisir. Le site « choisit… » puis répond.
5. Après le dixième choix, un indicateur « Analyse des deux drafts… » s'affiche puis le bilan apparaît : VERDICT, POURQUOI (5 critères), BANNISSEMENTS, CE QUI VA BIEN, À AMÉLIORER, la note de source des données, « Copier le résumé à partager » et « Refaire une draft ».

## Scénario 2 : sans bannissements (US3)

1. Ouvrir l'entraîneur, désactiver « Bannissements » avant tout geste.
2. Le statut dit « choix 1 sur 10 ». Les rangées de bannissements restent vides (aucune icône de blocage).
3. Terminer la draft : le bilan n'a pas de section « BANNISSEMENTS ».

## Scénario 3 : lire le bilan (US2)

1. Dans le bilan, vérifier que chaque critère affiche « Avantage à vous », « Avantage au site » ou « Égalité », ce que fait chaque camp et une explication.
2. Dans « À AMÉLIORER », une voie perdue cite un champion libre et son taux de victoire contre l'adversaire de voie.
3. Toucher « Refaire une draft » : une grille vide revient, le bilan disparaît ; l'historique (icône horloge de la barre) garde la draft précédente.

## Scénario 4 : aide au choix (US5)

1. Ouvrir l'entraîneur, activer « Aide au choix » (et, si on veut, désactiver les bannissements).
2. Au tour du joueur, trois cartes « SUGGESTIONS » s'affichent avec leurs raisons. Pendant les bannissements ou le tour du site, elles sont absentes.
3. Toucher une carte : le champion est posé au rôle indiqué, sans feuille de choix.
4. Terminer la draft puis ouvrir l'historique et la page de détail de cette draft : elle indique « jouée avec aide » (le marquage lui-même est décrit par la spec 017).

## Scénario 5 : erreurs (FR-019)

1. Couper le réseau (cache vide) et ouvrir l'entraîneur : message en français et « Réessayer ».
2. Couper le réseau juste avant le dixième choix : l'analyse échoue, un message et « Réessayer » apparaissent sous la grille ; « Réessayer » relance l'analyse sans perdre la draft.

## Lecteur d'écran (FR-021)

Chaque case annonce « Top, vide, appuyer pour choisir un champion » ou « Top : Ahri » ; la rangée de bans annonce « Bannissements de vous : Ahri, libre, … » ; une carte de conseil annonce « Conseil : Ahri au rôle Milieu. … Appuyer pour le choisir. » ; les titres du bilan sont des en-têtes.

## Tests automatisés

```bash
flutter test test/draft/draft_state_test.dart test/draft/draft_ban_test.dart
flutter test test/draft/draft_bot_test.dart test/draft/draft_evaluator_test.dart
flutter test test/draft/ban_analyzer_test.dart test/draft/draft_advisor_test.dart
flutter test test/draft/draft_report_view_test.dart test/draft/suggestion_card_test.dart
flutter test test/draft/draft_page_flow_test.dart test/draft/draft_page_advice_test.dart
flutter test test/draft/draft_a11y_test.dart
flutter analyze
```

Ou tout le dossier : `flutter test test/draft`.

Correspondance exigences / tests :

| Exigence | Test |
|----------|------|
| FR-002, FR-006 | `draft_state_test.dart`, `draft_ban_test.dart` |
| FR-005 | `draft_bot_test.dart` |
| FR-007, FR-008, FR-009 | `draft_ban_test.dart`, `draft_page_flow_test.dart` |
| FR-001, FR-004, FR-010, FR-018, SC-001, SC-002, SC-006 | `draft_page_flow_test.dart` |
| FR-011 à FR-014 | `draft_evaluator_test.dart` |
| FR-015 | `ban_analyzer_test.dart` |
| FR-016, FR-017, SC-003 | `draft_advisor_test.dart`, `draft_page_advice_test.dart`, `suggestion_card_test.dart` |
| FR-021 | `draft_a11y_test.dart`, `suggestion_card_test.dart` |
| FR-003, FR-019, FR-020 | observables dans `draft_page.dart` ; pas de test automatisé dédié |
