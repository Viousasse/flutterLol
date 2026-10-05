# Quickstart : Draft à deux

## Lancer l'application

```bash
flutter run            # mobile ou émulateur
flutter run -d chrome  # web
```

Onglet « Outils », « Composition », puis « Draft à deux : jouer contre un ami ».

## Scénario 1 : une draft à deux (US1)

1. L'écran s'intitule « Draft à deux ». Le score de la soirée est tout en haut (« Joueur 1 0 – 0 Joueur 2 »). Les colonnes sont « Joueur 1 · BLEU » et « Joueur 2 · ROUGE ».
2. Désactiver « Bannissements » pour aller plus vite (ou les jouer : chaque joueur touche sa propre rangée de bans à son tour).
3. Le statut dit « Au tour de Joueur 1, camp bleu (choix 1 sur 10). Passez l'appareil si besoin, puis appuyez sur un rôle libre. » Toucher un rôle de la colonne bleue puis un champion.
4. Le statut passe à « Joueur 2, camp rouge (choix 2 sur 10) ». Les cases de la colonne bleue ne réagissent plus ; jouer dans la colonne rouge. Le site ne joue jamais.
5. Après dix choix, le bilan s'affiche : « La draft de Joueur 1 l'emporte » (ou « Joueur 2 », ou « Drafts équivalentes »), critères « Avantage à Joueur 1/2 » de même couleur, puis « CE QUI VA BIEN · JOUEUR 1 », « À AMÉLIORER · JOUEUR 1 » et les mêmes blocs pour « JOUEUR 2 ».

## Scénario 2 : nommer les joueurs (US2)

1. Toucher « Joueur 1 · BLEU » (un crayon est affiché) : la boîte « Nom du joueur » s'ouvre.
2. Saisir « Joueur 2 » (ou « joueur 2 ») puis « Valider » : la boîte reste ouverte avec « Ce nom est déjà pris par l'autre joueur. ». Vider le champ : « Saisissez un nom. »
3. Saisir « Léa », valider : la colonne devient « Léa · BLEU », la barre de score et le statut aussi.
4. Terminer la draft : les titres de colonne n'ont plus de crayon ni de réaction au toucher.
5. Fermer et relancer l'application, rouvrir la draft à deux : « Léa » est toujours là.

## Scénario 3 : score de la soirée (US3)

1. Terminer une draft : la barre passe à « Léa 1 – 0 Joueur 2 » (ou « 0 – 1 », ou « 1 égalité »).
2. Terminer une seconde draft : le total des compteurs augmente de 1.
3. Renommer un joueur : le score ne bouge pas.
4. Toucher le bouton de remise à zéro (icône de flèche circulaire dans la barre) : boîte « Remettre le score à zéro ? ». « Annuler » ne change rien ; « Remettre à zéro » vide les compteurs, garde les noms, et grise le bouton.
5. Relancer l'application : noms et score sont relus.

## Scénario 4 : rejouer un duel (US4)

1. Terminer une draft à deux, ouvrir l'historique (icône horloge), ouvrir la draft puis « Rejouer avec les mêmes bannissements » (spec 017).
2. L'écran reprend les noms et les bans de l'original, affiche « Vous rejouez la draft du … : mêmes bannissements. » et **pas** de barre de score.
3. Terminer : retourner à une draft à deux neuve ; le score de la soirée n'a pas changé.

## Lecteur d'écran

- La barre annonce « Score de la soirée : Léa 3, Tom 2, 1 égalité ».
- Le titre d'une colonne annonce « Modifier le nom : Léa · BLEU » comme un bouton.

## Tests automatisés

```bash
flutter test test/draft/friend_session_store_test.dart
flutter test test/draft/friend_score_bar_test.dart
flutter test test/draft/player_name_dialog_test.dart
flutter test test/draft/draft_page_friend_session_test.dart
flutter test test/draft/draft_page_replay_score_test.dart
flutter test test/draft/draft_evaluator_test.dart test/draft/draft_report_view_test.dart
flutter test test/draft/draft_page_flow_test.dart
flutter analyze
```

| Exigence | Test |
|----------|------|
| FR-001, FR-002, SC-001 | `draft_page_flow_test.dart` (« une draft à deux se joue sans le site ») |
| FR-004 | `draft_evaluator_test.dart` (groupe « draft à deux »), `draft_report_view_test.dart` |
| FR-005, FR-006 | `player_name_dialog_test.dart`, `draft_page_friend_session_test.dart` (« renommer un joueur met à jour la session ») |
| FR-007, SC-003 | `friend_session_store_test.dart` (relecture, entrée illisible, entrée de mauvaise forme) |
| FR-008, FR-013 | `friend_score_bar_test.dart` |
| FR-009, SC-002 | `draft_page_friend_session_test.dart` (« la fin de la draft incrémente le score ») |
| FR-010 | `draft_page_friend_session_test.dart` (« la remise à zéro demande confirmation »), `friend_session_store_test.dart` |
| FR-011 | `friend_session_store_test.dart` (« renommer un joueur garde le score ») |
| FR-012 | `draft_page_replay_score_test.dart`, `draft_page_friend_session_test.dart` (« un duel rejoué… ») |
| FR-003 (aide en duel), FR-014 | non couverts en mode à deux ; FR-014 couvert par `draft_page_flow_test.dart` (enregistrement `versusFriend`) |
