---

description: "Liste des tâches : accessibilité des écrans récents"
---

# Tasks: Accessibilité des écrans récents

**Input**: Design documents from `/specs/020-accessibilite-des-ecrans-recents/`

**Prerequisites**: plan.md, spec.md, research.md, contracts/

**Tests**: inclus (principe VI).

**Statut**: livré (commit `e6e506c`). Les deux tâches de suivi connues (T016, T017) ne sont pas faites et restent décochées.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Auditer les écrans récents et consigner le tableau dans `docs/agents/reports/a11y-audit.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T002 Ajouter `minTapHeight` (44) et `visibleHeight` (32) et séparer la pastille dans `lib/shared/widgets/app_filter_chip/app_filter_chip.dart`

---

## Phase 3: User Story 1 - Puces annoncées (Priority: P1) 🎯 MVP

**Independent Test**: `flutter test test/shared/widgets/app_filter_chip_test.dart`.

- [x] T003 [P] [US1] Test « la puce est annoncée comme un bouton, avec son état » dans `test/shared/widgets/app_filter_chip_test.dart`
- [x] T004 [US1] Envelopper la puce dans `Semantics(button, selected, label, onTap)` dans `lib/shared/widgets/app_filter_chip/app_filter_chip.dart`

---

## Phase 4: User Story 2 - Zones tactiles de 44 px (Priority: P1)

- [x] T005 [P] [US2] Tests « zone tactile 44 px, pastille 32 » et « la barre de voies offre des zones tactiles de 44 px » dans `test/shared/widgets/app_filter_chip_test.dart`
- [x] T006 [US2] Passer chaque puce à `AppFilterChip.minTapHeight` et `runSpacing` à 0 dans `lib/shared/widgets/lane_filter_bar/lane_filter_bar.dart`
- [x] T007 [US2] Retirer la marge verticale de la rangée de rôles dans `lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart`

---

## Phase 5: User Story 3 - Titres sémantiques (Priority: P2)

- [x] T008 [P] [US3] Tests des titres du bilan et de la feuille d'affichage dans `test/draft/draft_a11y_test.dart`
- [x] T009 [US3] Ajouter `_SectionTitle` et envelopper VERDICT dans `lib/draft/widgets/draft_report_view/draft_report_view.dart`
- [x] T010 [P] [US3] Envelopper « SUGGESTIONS » dans `lib/draft/draft_page.dart`
- [x] T011 [P] [US3] Envelopper « Affichage » dans `lib/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart`

---

## Phase 6: User Story 4 - Contraste garanti (Priority: P2)

- [x] T012 [US4] Test de contraste WCAG sur les deux palettes dans `test/theme/contrast_test.dart` (aucune modification de `lib/theme/app_colors.dart` n'a été nécessaire)

---

## Phase 7: User Story 5 - Contrôles déjà conformes (Priority: P3)

- [x] T013 [US5] Constater la conformité de `lib/draft/widgets/draft_slot/draft_slot.dart`, `lib/draft/widgets/ban_row/ban_row.dart`, `lib/draft/widgets/suggestion_card/suggestion_card.dart`, `lib/shared/widgets/paste_code_dialog/paste_code_dialog.dart`, `lib/shared/widgets/data_source_note/data_source_note.dart`, `lib/shared/widgets/counter_tile/counter_tile.dart`, `lib/main_navigation/widgets/app_nav_bar/app_nav_bar.dart` (aucun changement ; lignes « ok » de l'audit)

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T014 Vérifier `flutter analyze` sur `lib/shared/widgets`, `lib/draft`, `lib/theme`
- [x] T015 Journaliser les changements visibles (lignes de puces plus espacées) dans `docs/agents/COORDINATION.md`
- [ ] T016 Passer `AppFilterChip.minTapHeight` aux autres appelants (région, objets, carte, quiz, régions) : suivi non fait, voir `spec.md`
- [ ] T017 Agrandir la zone tactile de `_ColumnTitle` (environ 22 px) dans `lib/draft/draft_page.dart` : décision de mise en page en attente
- [ ] T018 Ajouter un test de titre sémantique pour BANNISSEMENTS et SUGGESTIONS dans `test/draft/draft_a11y_test.dart`

## Dependencies & Execution Order

T002 avant T004 à T007. T006 et T007 dépendent de T002.
