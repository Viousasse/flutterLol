---

description: "Liste des tâches de la fonctionnalité 008 (rédigée après coup, tout est livré)"
---

# Tasks: Constructeur de builds, partage et import par code

**Input**: Design documents from `/specs/008-constructeur-de-builds/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: inclus (la constitution exige des tests de la logique).

**Organization**: commits d'origine `c86ea71`, `32fac77`, `a4475d7`, `57ca610`, `0afb3b1`, `23ea5c6`.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Aucune dépendance à ajouter : réutilise `shared_preferences`, `lib/items/constants/item_slots.dart` et `lib/shared/widgets/remote_image/remote_image.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 [P] Créer le modèle `Build` (`tryFromJson` tolérant, six objets au plus) dans `lib/builds/models/build.dart`
- [x] T003 [P] Créer le calcul de prix et de bonus cumulés dans `lib/builds/services/build_stats.dart`
- [x] T004 [P] Test du calcul (somme, pourcentages, ordre, statistiques nulles, JSON Data Dragon) dans `test/builds/build_stats_test.dart`
- [x] T005 Créer le magasin persistant `BuildStore` (clé `saved_builds`, file d'écritures) dans `lib/builds/services/build_store.dart`
- [x] T006 Test du magasin (enregistrer, modifier, supprimer, entrée illisible, six objets, ordre et champion) dans `test/builds/build_store_test.dart`

**Checkpoint**: une build se calcule et se conserve.

---

## Phase 3: User Story 1 - Composer et enregistrer une build (Priority: P1)

**Independent Test**: créer une build de deux objets, la retrouver après redémarrage.

- [x] T007 [P] [US1] Créer l'emplacement d'objet numéroté dans `lib/builds/widgets/build_slot/build_slot.dart`
- [x] T008 [P] [US1] Créer le panneau de prix et bonus dans `lib/builds/widgets/build_stats_panel/build_stats_panel.dart`
- [x] T009 [P] [US1] Créer la feuille de choix d'objet dans `lib/shared/widgets/item_picker_sheet/item_picker_sheet.dart`
- [x] T010 [P] [US1] Créer la feuille de choix de champion dans `lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart`
- [x] T011 [US1] Créer l'éditeur (nom 40 caractères, « Ma build » par défaut, six emplacements, champion facultatif, enregistrement désactivé sans objet, Réessayer) dans `lib/builds/build_editor_page.dart`

---

## Phase 4: User Story 2 - Gérer la liste de ses builds (Priority: P1)

**Independent Test**: créer deux builds, modifier la plus ancienne, la supprimer.

- [x] T012 [P] [US2] Créer la vignette de build dans `lib/builds/widgets/build_tile/build_tile.dart`
- [x] T013 [US2] Créer la liste « Mes builds » (chargement, erreur, vide, suppression confirmée) dans `lib/builds/builds_page.dart`
- [x] T014 [P] [US2] Ajouter l'entrée « Mes builds » dans `lib/tools/widgets/tools_section/tools_section.dart`
- [x] T015 [P] [US2] Ajouter le bouton « Builds » de l'onglet Objets dans `lib/items/widgets/builds_button/builds_button.dart`
- [x] T016 [US2] Tests de la liste (chargement, Réessayer, vide, contenu, confirmation de suppression) dans `test/builds/builds_page_test.dart`

---

## Phase 5: User Story 3 - Partager une build (Priority: P2)

**Independent Test**: appuyer sur partager, coller le texte ailleurs.

- [x] T017 [P] [US3] Créer le code de partage `LOLB1.` dans `lib/builds/services/build_share_code.dart`
- [x] T018 [P] [US3] Créer le mécanisme commun `ShareCode` dans `lib/shared/services/share_code/share_code.dart`
- [x] T019 [P] [US3] Créer le résumé texte dans `lib/builds/services/build_share_text.dart`
- [x] T020 [P] [US3] Créer la copie avec confirmation ou échec dans `lib/shared/services/clipboard_copy/clipboard_copy.dart`
- [x] T021 [US3] Tests du résumé dans `test/builds/build_share_text_test.dart`
- [x] T022 [US3] Test du bouton de partage dans `test/builds/builds_page_test.dart`

---

## Phase 6: User Story 4 - Importer une build par code (Priority: P2)

**Independent Test**: copier le résumé d'une build, l'importer.

- [x] T023 [P] [US4] Créer la boîte de collage générique dans `lib/shared/widgets/paste_code_dialog/paste_code_dialog.dart`
- [x] T024 [P] [US4] Créer `importBuildFromText` dans `lib/builds/services/build_import.dart`
- [x] T025 [US4] Ajouter l'action « Importer une build » dans `lib/builds/builds_page.dart`
- [x] T026 [P] [US4] Tests du code (aller-retour, noyé dans un message, corrompu, champs invalides, bornes, champs inconnus, nouvel id) dans `test/builds/build_share_code_test.dart`
- [x] T027 [P] [US4] Tests de l'import dans `test/builds/build_import_test.dart`
- [x] T028 [P] [US4] Tests de la boîte dans `test/shared/widgets/paste_code_dialog_test.dart`
- [x] T029 [US4] Tests d'import dans la page (code valide, texte invalide) dans `test/builds/builds_page_test.dart`

---

## Phase 7: User Story 5 - Depuis une fiche et par rôle (Priority: P3)

**Independent Test**: depuis une fiche avec objets conseillés, créer une build ; choisir un champion par rôle.

- [x] T030 [US5] Ajouter « Créer une build avec ces objets » dans `lib/champion_detail/champion_detail_page.dart`
- [x] T031 [P] [US5] Créer la rangée de rôles dans `lib/shared/widgets/champion_picker_sheet/champion_role_filter.dart`
- [x] T032 [US5] Brancher `RoleFilters.forProfile` dans `lib/builds/build_editor_page.dart` (profil chargé via `lib/team/services/role_filters.dart`)
- [x] T033 [P] [US5] Test de la feuille de choix de champion dans `test/shared/widgets/champion_picker_sheet_test.dart`

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T034 [P] Libellés pour lecteurs d'écran des emplacements et vignettes dans `lib/builds/widgets/build_slot/build_slot.dart` et `lib/builds/widgets/build_tile/build_tile.dart`
- [x] T035 [P] Message d'erreur et « Réessayer » partagés dans `lib/shared/widgets/error_retry_view/error_retry_view.dart`
- [x] T036 Limites connues (vouvoiement, nom 40/60, `importBuildFromText` inutilisée, éditeur sans test) consignées dans `specs/008-constructeur-de-builds/spec.md`

---

## Dependencies & Execution Order

- Phase 2 bloque les parcours ; US1 et US2 avant US3 et US4 (le partage et l'import s'appuient sur la liste) ; US5 est indépendante après US1.
