# Specification Quality Checklist: Historique, partage et import des drafts

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans `spec.md` (pas de langage, de framework ni de chemin de fichier dans les exigences)
- [x] CHK002 Centrée sur la valeur pour le joueur
- [x] CHK003 Compréhensible par un lecteur non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Tous les scénarios d'acceptation sont définis
- [x] CHK010 Les cas limites sont identifiés (entrée corrompue, champion retiré, doublon, code abîmé, stockage indisponible)
- [x] CHK011 Le périmètre est borné (bannissements hors périmètre)
- [x] CHK012 Les dépendances et hypothèses sont listées

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation ou un test cité (`tasks.md`, `quickstart.md`)
- [x] CHK014 Les parcours couvrent les flux principaux (P1 à P3)
- [x] CHK015 Les critères mesurables sont satisfaits par le comportement livré
- [ ] CHK016 L'interface respecte le tutoiement de la constitution (non : voir « Assumptions et limites connues » et `plan.md`, Complexity Tracking)

## Notes

- `spec.md` cite des libellés d'interface exacts (« Importer une draft », « Code : ») : ce sont des exigences visibles, pas de l'implémentation.
- CHK016 reste décoché volontairement : l'écart est connu et documenté.
