# Specification Quality Checklist: Constructeur de builds, partage et import par code

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

**Note**: spécification rédigée après coup ; une case cochée signifie que le critère de qualité est satisfait, pas que le travail est fait.

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans `spec.md` (les exigences disent « le système DOIT… »)
- [x] CHK002 Centrée sur la valeur pour le joueur
- [x] CHK003 Lisible par une personne non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]`
- [x] CHK006 Exigences testables et non ambiguës (six objets, 40 et 60 caractères, préfixe `LOLB1.`)
- [x] CHK007 Critères de réussite mesurables
- [x] CHK008 Critères de réussite indépendants de la technologie
- [x] CHK009 Scénarios d'acceptation définis pour chaque parcours
- [x] CHK010 Cas limites identifiés (entrée illisible, objet retiré, stockage indisponible, code futur)
- [x] CHK011 Périmètre borné (local, sans compte ni synchronisation, pas de feuille de partage système)
- [x] CHK012 Dépendances et hypothèses listées (catalogue Data Dragon, identifiants)

## Feature Readiness

- [x] CHK013 Chaque exigence a un critère d'acceptation ou une vérification citée dans `quickstart.md`
- [x] CHK014 Les parcours couvrent le flux principal (composer, lister, partager, importer)
- [x] CHK015 Les limites connues (nom 40/60, vouvoiement, `importBuildFromText` inutilisée) sont écrites
- [ ] CHK016 Toutes les exigences ont un test automatisé (l'éditeur `BuildEditorPage` n'a pas de test de widget : FR-001, FR-003, FR-007, FR-008, FR-016 en partie manuels)

## Notes

- CHK016 reste décoché : voir Complexity Tracking dans `plan.md`.
