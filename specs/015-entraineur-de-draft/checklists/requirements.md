# Specification Quality Checklist: Entraîneur de draft

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans `spec.md` (langage, classes, fichiers) ; les seuils chiffrés sont des règles métier
- [x] CHK002 Centrée sur la valeur pour l'utilisateur (s'entraîner, comprendre, s'améliorer)
- [x] CHK003 Rédigée pour des lecteurs non techniques
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]`
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [ ] CHK008 Les critères de réussite sont indépendants de la technologie (SC-001 cite le fichier de test qui le vérifie)
- [x] CHK009 Tous les scénarios d'acceptation sont définis
- [x] CHK010 Les cas limites sont identifiés
- [x] CHK011 Le périmètre est borné (filtre de rôle = 018, historique/partage/import = 017, mode à deux = 016)
- [x] CHK012 Les dépendances et hypothèses sont listées

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation ou un test (voir la table de `quickstart.md`)
- [ ] CHK014 Toutes les exigences sont couvertes par un test automatisé (FR-003, FR-019, FR-020 observables seulement ; pas de test dédié pour `DraftSlot`, `BanRow`, `CriterionTile`)
- [x] CHK015 Les scénarios utilisateur couvrent le parcours principal et les secondaires
- [x] CHK016 Les écarts entre la demande et le livré sont notés (« Hypothèses et limites connues »)
- [ ] CHK017 Conformité complète à la constitution (vouvoiement au lieu du tutoiement, deux couleurs en dur : voir `plan.md`, Complexity Tracking)

## Notes

- CHK008 : la mention du fichier de test dans SC-001 est une référence de vérification, pas une contrainte de technologie, mais la case reste vide par rigueur.
- Les cases vides CHK014 et CHK017 correspondent à des écarts réels, pas à des oublis.
