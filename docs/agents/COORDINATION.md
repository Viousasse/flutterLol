# Coordination des agents

Ce fichier est le **tableau commun** des agents du projet. Il sert à trois
choses : savoir qui fait quoi, ne jamais éditer le même fichier en même temps,
et se parler. **Lis-le en entier avant ta première modification, puis relis les
sections « Verrous » et « Journal » avant chaque fichier que tu ne possèdes pas.**

## 1. Rôles

- **Architecte** : l'instance principale de Claude. Elle découpe le travail,
  lance les agents, tranche les conflits, vérifie les résultats (analyse, tests,
  rendu dans le navigateur) et relance un successeur quand un agent a relayé.
  Elle est la seule à parler à l'utilisateur et la seule à commiter.
- **Agents** : des instances Sonnet. Chacune a une fiche
  `docs/agents/tasks/T<n>.md`. Elle ne fait que sa fiche.

## 2. Limite de contexte : 250 000 tokens, relais obligatoire

Un agent ne doit **jamais** dépasser 250 000 tokens de contexte.

- **Surveille ton budget** dès le début. Si tu vois un compteur de tokens
  restants, ton usage est « budget de départ − restant ». Sinon, estime-le :
  compte environ 3 000 tokens par appel d'outil, et davantage pour une lecture
  de gros fichier ou une sortie de test.
- **À 180 000 tokens utilisés (marge de sécurité), arrête de travailler** et
  fais le relais :
  1. Finis l'action en cours (ne laisse pas un fichier à moitié écrit ni du
     code qui ne compile pas).
  2. Écris **tout ce que tu sais** dans `docs/agents/handoffs/T<n>-<k>.md`
     (`k` = 1 pour le premier relais, 2 pour le suivant…), avec le modèle de la
     section 7.
  3. Ajoute une ligne au journal (section 6) : `RELAIS T<n> → handoffs/T<n>-<k>.md`.
  4. Termine ta réponse par la ligne exacte `HANDOFF NEEDED: docs/agents/handoffs/T<n>-<k>.md`.
- L'architecte lance alors un **nouvel agent** qui lit sa fiche, le dernier
  relais, ce fichier, puis reprend exactement où tu t'es arrêté.
- Pour économiser le contexte : ne relis pas un fichier que tu viens d'écrire,
  lis seulement les parties utiles (`offset`/`limit`), ne lance pas la suite de
  tests complète, filtre les sorties longues (`| tail -20`).

## 3. Règles de travail communes

1. **Constitution** : `.specify/memory/constitution.md` fait loi. Résumé :
   dossier par fonctionnalité `lib/<feature>/{models,services,widgets/<nom>/<nom>.dart,constants}`,
   code partagé dans `lib/shared`, `RemoteImage` pour toute image réseau,
   `AppColors`/`AppTheme` seulement (jamais de couleur codée en dur, sauf
   couleurs de sens existantes), **interface en français**, commentaires qui
   expliquent le **pourquoi**, un seul widget public par fichier, les tests
   reflètent `lib/`.
2. **Style du code** : imite le code voisin (densité de commentaires, noms,
   idiomes Dart 3 : motifs, enregistrements, éléments nuls `?x`).
3. **Interdictions** :
   - **Ne commite jamais, ne pousse jamais** (`git add/commit/push` interdits).
   - **Ne lance jamais `flutter run`**, ne touche pas au navigateur : le rendu
     est vérifié par l'architecte.
   - **N'écris pas `Co-Authored-By`** nulle part.
   - Ne lance jamais `dart format` sur un dossier : **uniquement sur les
     fichiers que tu as créés ou modifiés** (`dart format a.dart b.dart`).
     Reformater les voisins pollue le diff.
   - Ne touche pas aux fichiers d'une autre tâche (section 4 et 5).
4. **Vérification** : lance `flutter analyze <tes fichiers ou dossiers>` et
   `flutter test <tes fichiers de test>`. **Pas** de `flutter test` global ni
   de `flutter analyze` global : d'autres agents travaillent en même temps et
   une erreur dans leurs fichiers n'est pas la tienne. Si une erreur vient d'un
   fichier qui n'est pas à toi, écris un message au journal et passe.
5. **Pièges connus de cet environnement** (Windows, PowerShell/Git Bash) :
   - Pas de Python. Pour éditer, utilise les outils **Edit/Write** ; évite les
     `sed`/`perl` multi-lignes (les fichiers de `lib/builds` et
     `lib/shared/widgets/champion_picker_sheet` ont des fins de ligne CRLF, les
     `perl -0` à base de `\n` échouent silencieusement).
   - Pas de heredoc contenant une apostrophe dans une commande : utilise Write.
   - Sur les tests de widgets : `pumpAndSettle` ne se calme jamais dès qu'un
     `RemoteImage` est affiché (l'effet de chargement boucle et le réseau ne
     répond jamais en test). Utilise des `pump(Duration)` répétés. Les
     `ListTile` de la page sont aussi comptés par `find.byType(ListTile)` :
     cible la feuille avec `find.descendant`.
   - `DraftHistoryStore.reset()` existe pour les tests (réinitialise le
     stockage statique) ; fais pareil pour tout store statique que tu crées.
   - `flutter analyze` signale `curly_braces_in_flow_control_structures` : mets
     des accolades aux `if`.
6. **Fin de tâche** : mets ta ligne du tableau (section 4) à `FAIT`, ajoute un
   message de fin au journal, puis réponds par un compte rendu court : ce qui
   est fait, fichiers créés/modifiés, tests passants, ce qui reste ou bloque.

## 4. Tâches

Statuts : `A FAIRE` · `EN COURS` · `FAIT` · `RELAIS` · `BLOQUÉ`.
Phases : une tâche de phase 2 ne démarre qu'après les tâches listées en
« Dépend de ». L'architecte lance les agents.

| Id  | Phase | Titre | Dépend de | Statut | Fiche |
|-----|-------|-------|-----------|--------|-------|
| T1  | 1 | Filtre de rôle : finir le câblage (équipe, points forts, builds) | — | FAIT | tasks/T1.md |
| T2  | 1 | Outil de génération : `--decay`, `--min-patch`, guide de mise à jour | — | FAIT | tasks/T2.md |
| T4  | 1 | Conseiller de draft (`DraftAdvisor`) | — | FAIT | tasks/T4.md |
| T5  | 1 | Session « à deux » : noms mémorisés et score de la soirée | — | FAIT | tasks/T5.md |
| T6  | 1 | Quiz « Qui bat qui ? » à partir des matchups | — | FAIT | tasks/T6.md |
| T7  | 1 | Codes de partage (builds et drafts) | — | FAIT | tasks/T7.md |
| T8  | 1 | Audit et correctifs du mode hors-ligne | — | FAIT | tasks/T8.md |
| T9a | 1 | Page de draft : rejouer une draft (`replayOf`) | — | FAIT | tasks/T9a.md |
| T10 | 1 | Historique : drafts « avec aide », page de détail | — | FAIT | tasks/T10.md |
| T3  | 2 | Note « d'où viennent les données » partout | T1 | FAIT | tasks/T3.md |
| T9b | 2 | Page de draft : conseils, session à deux | T4, T5, T9a, T10 | A FAIRE | tasks/T9b.md |
| T13 | 2 | Import par code (builds, drafts) | T7, T10 | FAIT | tasks/T13.md |
| T14 | 3 | Tests d'écran des pages contre-picks, points forts, builds | T1, T3, T13 | A FAIRE | tasks/T14.md |
| T11 | 3 | Accessibilité : passage sur les écrans récents | T9b, T13 | A FAIRE | tasks/T11.md |

Non fait volontairement : **profil d'invocateur** (rang, parties récentes). Il
exige un serveur pour ne pas embarquer la clé Riot dans l'application.

## 5. Verrous : un fichier = un propriétaire à la fois

Avant de modifier un fichier qui n'est pas dans ta fiche, regarde ce tableau.
S'il est libre, **ajoute une ligne** (avec Edit) avant d'y toucher et retire-la
dès que tu as fini. S'il est pris, **n'y touche pas** : écris au journal et
travaille sur autre chose.

Fichiers « chauds » (touchés par plusieurs tâches, donc séquencés) :

| Fichier | Propriétaires, dans l'ordre |
|---------|------------------------------|
| `lib/draft/draft_page.dart` | T9a, puis T9b (et personne d'autre) |
| `lib/draft/models/draft_record.dart` | T10 seul |
| `lib/draft/draft_history_page.dart` | T10, puis T13 |
| `lib/draft/services/draft_history_stats.dart` | T10 seul |
| `lib/draft/widgets/draft_history_tile/draft_history_tile.dart` | T10 seul |
| `lib/draft/services/draft_bot.dart` | T4 seul (exposer ce que le conseiller réutilise) |
| `lib/strengths/strengths_page.dart` | T1, puis T3, puis T14 |
| `lib/counters/counters_page.dart` | T3, puis T14 |
| `lib/builds/builds_page.dart` | T13, puis T14 |
| `lib/builds/build_editor_page.dart` | T1 seul |
| `lib/team/team_page.dart` | T1 seul |
| `lib/shared/widgets/app_filter_chip/**`, `lib/shared/widgets/champion_picker_sheet/**` | T11 seul |
| `lib/builds/services/build_share_text.dart`, `lib/draft/services/draft_share_text.dart` | T7 seul |

Verrous posés en cours de route (une ligne par fichier, retire-la en finissant) :

| Fichier | Pris par | Depuis |
|---------|----------|--------|
| _(aucun)_ | | |

## 6. Journal des messages (ajout seulement)

Pour écrire, **ajoute en fin de fichier avec la commande shell** (jamais Edit sur
tout le fichier : tu écraserais le message d'un autre) :

```bash
echo "- [T4 · 14:32] Message court, utile, daté." >> docs/agents/COORDINATION.md
```

Le journal est la **dernière section** : tout ce qui est écrit sous le titre
suivant, c'est du journal. Format : `- [Tn · HH:MM] message`. Écris quand :
tu commences/finis une tâche, tu changes une API que d'autres utilisent, tu
découvres un piège, tu es bloqué, tu relaies.

## 7. Modèle de relais (`docs/agents/handoffs/T<n>-<k>.md`)

```markdown
# Relais T<n>-<k> — <titre de la tâche>
Date/heure : … · Raison : contexte à ~180 k
## Où j'en suis (1 paragraphe)
## Fait (fichiers créés/modifiés, avec une ligne par fichier)
## Reste à faire (liste ordonnée, la première action concrète en premier)
## Décisions prises et pourquoi
## Pièges rencontrés
## État des tests (commande lancée, résultat)
## Questions ouvertes pour l'architecte
```

## 8. Contrats d'interface entre tâches

Respecte exactement ces signatures : d'autres agents codent contre elles.

- **T4 → T9b** — `lib/draft/services/draft_advisor.dart`
  ```dart
  class DraftSuggestion {
    final int roleIndex;          // index dans teamRoles
    final Champion champion;
    final List<String> reasons;   // 1 à 3 phrases courtes, en français
    final double score;
  }
  class DraftAdvisor {
    DraftAdvisor({required MatchupDataset dataset});
    /// Vide pendant les bannissements ou si la draft est finie. Déterministe.
    List<DraftSuggestion> suggest({
      required DraftState state,
      required DraftSide side,
      required List<Champion> pool,
      int count = 3,
    });
  }
  ```
- **T5 → T9b** — `lib/draft/services/friend_session_store.dart`
  ```dart
  class FriendSession { final DraftPlayers players; final int blueWins, redWins, ties; }
  class FriendSessionStore {
    static final ValueNotifier<FriendSession> session;
    static Future<void> ensureLoaded();
    static Future<void> rename(DraftSide side, String name);
    static Future<void> recordResult(DraftWinner winner);
    static Future<void> resetScore();
    @visibleForTesting static void reset();
  }
  ```
  et le widget `lib/draft/widgets/friend_score_bar/friend_score_bar.dart` :
  `FriendScoreBar({required FriendSession session, required VoidCallback onReset})`.
- **T10 → T9b** — `DraftRecord` gagne `final bool assisted;` (défaut `false`,
  sérialisé dans `toJson`/`tryFromJson`, absent = `false`) et `DraftRecord.from`
  gagne `bool assisted = false`.
- **T9a → T10** — `DraftPage({..., DraftRecord? replayOf})` : rejoue une draft
  avec **les mêmes bannissements** (cases pré-remplies depuis `replayOf`), les
  choix repartent de zéro. Le mode (site/à deux) est repris de
  `replayOf.versusFriend`.
- **T7 → T13** — `lib/builds/services/build_share_code.dart` :
  `static String encode(Build)` ; `static Build? decode(String texte)` (accepte
  un texte collé contenant le code). `lib/draft/services/draft_share_code.dart` :
  `static String encode(DraftRecord)` ; `static DraftRecord? decode(String texte)`
  (nouvel `id`, `playedAt` conservée). Préfixes `LOLB1.` (build) et `LOLD1.`
  (draft). Les textes de partage se terminent par une ligne `Code : <code>`.

## 9. Fichiers de rapport

Les audits et analyses vont dans `docs/agents/reports/<sujet>.md`.

---

## Journal (ajout seulement, ne rien écrire au-dessus de cette ligne)

- [Architecte · 17:10] Lancement. Arbre de travail déjà modifié (non commité) : `lib/matchups/services/lane_profile.dart` (déplacé depuis `lib/draft/services`), `lib/team/services/role_filters.dart` (nouveau), filtre de rôle câblé dans `counters_page`, `compare_page` ; imports déjà ajoutés (mais pas encore utilisés) dans `strengths_page`, `team_page`, `build_editor_page` → c'est le travail de T1.
- [T2 · début] Démarrage : outil de génération (--decay, --min-patch, README).
- [T5 · début] Démarrage : friend_session_store + friend_score_bar + tests.
- [T6 · début] Démarre le quiz Duels (lib/quiz, test/quiz).
- [T1 · 17:20] Début. Je tiens strengths_page, team_page, build_editor_page.
- [T8 · 17:08] Début audit hors-ligne.
- [T9a · début] Démarrage : DraftPage(replayOf:).
- [T7 · 18:00] Début T7 (codes de partage).
- [T4 · début] Démarrage du conseiller de draft.
- [T10 · 17:08] Début T10.
- [T10 · 17:09] DraftRecord.assisted FAIT (constructeur, from, toJson/tryFromJson) ; DraftHistoryStats.assistedCount aussi. T7/T9b peuvent s'y appuyer.
- [T2 · fin] Terminé : tool/matchup_tally.dart, --decay, --min-patch, champ patches, tool/README.md, test/tool/matchup_tally_test.dart (13 tests OK, analyze propre).
- [T4 · fin] FAIT. DraftAdvisor conforme au contrat §8 (lib/draft/services/draft_advisor.dart, test/draft/draft_advisor_test.dart). draft_bot.dart expose maintenant static needBonusFor, needsFilledBy, isFrontliner (comportement inchangé). Constante DraftAdvisor.fallbackReason publique.
- [T5 · fin] Terminé : friend_session_store.dart (FriendSession, FriendSessionStore) + friend_score_bar.dart + 2 fichiers de tests (14 tests OK, analyse propre). Contrat §8 respecté.
- [T1 · 17:35] strengths_page.dart LIBÉRÉ (T3 peut le prendre). T1 FAIT : filtre de rôle câblé (équipe, points forts, builds), test/team/role_filters_test.dart vert, analyze propre.
- [T3 · début] Démarrage : DataSourceNote.
- [T7 · 18:20] FAIT. API : BuildShareCode.encode(Build) / decode(String)->Build? (LOLB1.) ; DraftShareCode.encode(DraftRecord) / decode(String)->DraftRecord? (LOLD1.) ; décodeur commun lib/shared/services/share_code/share_code.dart. BuildShareText.of et DraftShareText.of finissent par 'Code : <code>'. Ajouté un test dans le groupe DraftShareText de draft_history_test.dart. 'assisted' non codé (absent de DraftRecord à ce jour : T10 devra l'ajouter au code si besoin, champ 'a').
- [Architecte · 17:15] T7 fait. À faire par T13 (il hérite des fichiers de code de T7) : quand T10 aura ajouté `DraftRecord.assisted`, l'ajouter à `DraftShareCode` (clé `a`, absent = false) avec test. T1, T2, T4, T5, T7 faits. T3 lancé.
- [T9a · fin] T9a fait : `DraftPage(replayOf:)` disponible (bans repris dans l'ordre, arrêt au premier champion introuvable puis phase de ban normale). Tests flow+replay passent.
- [T10 · 17:16] T10 FINI. Page de détail draft_record_page.dart (DraftRecordPage(record, imageUrls)), tuile avec onTap optionnel, draftOutcomeLabel() public. draft_history_page.dart LIBRE pour T13.
- [T8 · 17:16] FAIT. DataDragonService.fetchJson gagne isValid et offlineKeepLast (optionnels, rétro-compatibles) ; fetchDetail a maintenant un cache hors-ligne (12 dernières fiches). Pour les pages : lib/map/map_page.dart ~178 n'a pas de bouton Réessayer (voir docs/agents/reports/offline-audit.md). Reste OK.
- [T6 · fin] Quiz Duels fait : duel_question_builder.dart, catégorie matchups relibellée « Duels » (ancienne _bestMatchup remplacée), QuizCategoryBar gagne available:, matchups illisibles tolérés dans quiz_page. Tests test/quiz OK.
- [T13 · début] Démarrage : import par code.
- [T9b · début] Démarrage : aide au choix + session à deux dans draft_page.
- [T3 · fin] FAIT. Widget DataSourceNote(dataset:) dans lib/shared/widgets/data_source_note/data_source_note.dart (aussi static DataSourceNote.textFor(dataset)). T9b : utilise-le dans la page de draft. Affiché dans counters_page, strengths_page, matchup_section, head_to_head_card ; ces deux pages sont LIBÉRÉES pour T14.
- [Architecte · 17:17] T6, T8, T9a, T10 faits. T3, T9b, T13 en cours. T15 lancé (page carte, Réessayer). Phase 3 (T14, T11) après T3, T9b, T13.
- [T15 · début] Démarrage : page carte, Réessayer.
- [T15 · fin] FAIT. MapPage(loadVersion:) injectable, ErrorRetryView + Réessayer recrée le futur ; test/map/map_page_retry_test.dart vert, analyze propre.
- [T9b · fin] FAIT. Aide au choix (SuggestionCard, panneau SUGGESTIONS, record.assisted), session à deux (noms/score/FriendScoreBar), DataSourceNote sous le bilan. Interrupteur d'aide masqué en rejeu comme les bans. NOTE: draft_page_flow_test.dart modifié (3 lignes: find.byType(Switch) -> .first) car deux Switch existent désormais. 27 tests OK.
- [T16 · début] Démarrage : pas de FriendScoreBar en rejeu.
- [T16 · fin] FAIT. FriendScoreBar masquée en rejeu (condition _usesSession dans draft_page.dart), test/draft/draft_page_replay_score_test.dart (3 tests), 27 tests draft OK, analyze propre.
- [T13 · fin] FAIT. DraftRecord.imported + DraftShareCode (assisted 'a', imported:true au décodage), stats/tuile/bilan, PasteCodeDialog (lib/shared/widgets/paste_code_dialog), build_import.dart (importBuildFromText), import dans BuildsPage (action AppBar 'Importer une build') et DraftHistoryPage (gagne loadChampions injectable). builds_page.dart LIBRE pour T14. Tests draft/builds/paste dialog verts.
