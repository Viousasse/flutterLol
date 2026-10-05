# Implementation Plan: Draft à deux

**Branch**: `016-draft-a-deux` (livré sur `main`) | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/016-draft-a-deux/spec.md`

## Summary

La page `DraftPage` (spec 015) gagne un mode `DraftMode.vsFriend` où les deux camps se jouent au doigt, un bilan neutre qui nomme les joueurs (`DraftPlayers`), des noms modifiables (`PlayerNameDialog`) et un score de la soirée (`FriendSession`, `FriendSessionStore`, `FriendScoreBar`) conservé avec `shared_preferences` dans un `ValueNotifier`, sur le modèle de l'historique des drafts. Un duel rejoué depuis l'historique (`replayOf`) ne touche pas à la soirée.

## Technical Context

**Language/Version**: Dart 3 / Flutter SDK `^3.13`

**Primary Dependencies**: `flutter` (Material), `shared_preferences` `^2.2.3` ; `dart:convert` pour la sérialisation JSON. Aucune dépendance ajoutée.

**Storage**: `shared_preferences`, clé `friend_session`, une chaîne JSON `{blue, red, blueWins, redWins, ties}` ; état en mémoire dans `FriendSessionStore.session` (`ValueNotifier<FriendSession>`).

**Testing**: `flutter_test` ; `SharedPreferences.setMockInitialValues`, `FriendSessionStore.reset()` entre les tests ; chargeurs de la page injectés (aucun réseau).

**Target Platform**: mobile et web

**Project Type**: application mobile/web Flutter (projet unique)

**Performance Goals**: aucun ; écritures de sauvegarde mises en file pour ne pas se doubler.

**Constraints**: hors-ligne (stockage local) ; sauvegarde illisible ou en échec sans erreur visible ; noms de 12 caractères au plus à la saisie.

**Scale/Scope**: un service (~190 lignes avec le modèle), deux widgets (~90 lignes chacun), la part « à deux » de `draft_page.dart`.

## Constitution Check

| Principe | Verdict | Preuve |
|----------|---------|--------|
| I. Organisation par fonctionnalité | Respecté avec réserves | `lib/draft/services/friend_session_store.dart`, `lib/draft/widgets/friend_score_bar/friend_score_bar.dart`, `lib/draft/widgets/player_name_dialog/player_name_dialog.dart`. Réserves : (a) `friend_session_store.dart` contient deux classes publiques (`FriendSession` et `FriendSessionStore`) ; (b) le service importe un fichier de widget pour `validatePlayerName`, ce qui inverse le sens habituel services/widgets (voir Complexity Tracking). |
| II. Données Riot / erreurs affichables | Sans objet | Aucun appel réseau propre à la fonctionnalité ; un échec de stockage est absorbé (`try/catch` dans `_load` et `_persist`). |
| III. Images via RemoteImage | Sans objet | Aucune image. |
| IV. Thème centralisé | Respecté | `friend_score_bar.dart` et `player_name_dialog.dart` n'emploient que `AppColors.*` et `AppTheme.serif/mono` ; aucun `Color(...)`. |
| V. État simple et local | Respecté | `FriendSessionStore.session` est un `ValueNotifier` exposé par un service, relu avant le premier rendu (`ensureLoaded` dans `loadData`), persisté avec `shared_preferences` ; la page s'abonne dans `initState` et se désabonne dans `dispose` (`lib/draft/draft_page.dart`). |
| VI. Tests | Respecté | `test/draft/friend_session_store_test.dart` (9 cas), `friend_score_bar_test.dart` (5), `player_name_dialog_test.dart` (6), `draft_page_friend_session_test.dart` (5), `draft_page_replay_score_test.dart` (3), `draft_evaluator_test.dart` (groupe « draft à deux »), `draft_report_view_test.dart` ; pas de test du critère `CriterionTile` en duel seul. |
| VII. Lisibilité, français | Entorse | Commentaires utiles (« Seul un duel neuf partage la soirée », « un fichier abîmé ne doit pas réintroduire un nom vide »), mais l'interface vouvoie (« Saisissez un nom. », « Remettre le score à zéro ? »). |

## Project Structure

### Documentation (this feature)

```text
specs/016-draft-a-deux/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── friend-session.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/draft/
├── draft_page.dart                                  # mode vsFriend : colonnes, tours, renommage, session, rejeu
├── models/
│   ├── draft_mode.dart                              # DraftMode.vsFriend, friendPlayers
│   └── draft_report.dart                            # DraftPlayers, bilan à deux
├── services/
│   ├── friend_session_store.dart                    # FriendSession + FriendSessionStore
│   └── draft_evaluator.dart                         # bilan neutre et conseils pour chaque camp (players:)
└── widgets/
    ├── friend_score_bar/friend_score_bar.dart
    ├── player_name_dialog/player_name_dialog.dart   # PlayerNameDialog, validatePlayerName
    ├── criterion_tile/criterion_tile.dart           # « Avantage à <nom> »
    └── draft_report_view/draft_report_view.dart     # un bloc de conseils par joueur

test/draft/
├── friend_session_store_test.dart
├── friend_score_bar_test.dart
├── player_name_dialog_test.dart
├── draft_page_friend_session_test.dart
├── draft_page_replay_score_test.dart
├── draft_evaluator_test.dart                        # groupe « draft à deux »
├── draft_report_view_test.dart
└── draft_page_flow_test.dart                        # test « une draft à deux se joue sans le site »
```

**Structure Decision**: la soirée suit le patron de l'historique des drafts (`DraftHistoryStore` : `ValueNotifier` statique + `shared_preferences`, file d'écritures) pour rester cohérente avec le principe V ; la page décide si elle utilise la soirée (`_usesSession` : mode à deux et pas un rejeu).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Deux classes publiques dans `friend_session_store.dart` | Le modèle (`FriendSession`) n'a de sens qu'avec son magasin. | Aucune trace écrite d'un arbitrage ; le principe I ne vise que les widgets, c'est donc une entorse de forme. |
| `friend_session_store.dart` importe `widgets/player_name_dialog/player_name_dialog.dart` pour `validatePlayerName` | La même règle de validation sert à la boîte de saisie, au service et à la relecture d'un fichier. | La règle aurait pu vivre dans `models/` ou `services/` ; aucune trace de cette décision, c'est une dépendance à l'envers non justifiée. |
| Vouvoiement des textes (principe VII) | Même ton que le reste de la draft (spec 015). | Non justifié ; voir 015. |
