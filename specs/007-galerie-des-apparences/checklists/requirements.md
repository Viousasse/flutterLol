# Specification Quality Checklist: Galerie des apparences d'un champion

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
- [x] CHK006 Exigences testables et non ambiguës (zoom ×4, 250 ms, deux lignes, section masquée à une apparence)
- [x] CHK007 Critères de réussite mesurables
- [x] CHK008 Critères de réussite indépendants de la technologie
- [x] CHK009 Scénarios d'acceptation définis pour chaque parcours
- [x] CHK010 Cas limites identifiés (chromas, liste absente, lien mort, tailles d'illustration)
- [x] CHK011 Périmètre borné (pas de partage ni de recherche)
- [x] CHK012 Dépendances et hypothèses listées (fiche Data Dragon, CDN d'images)

## Feature Readiness

- [x] CHK013 Chaque exigence a un critère d'acceptation ou une vérification citée dans `quickstart.md`
- [x] CHK014 Les parcours couvrent le flux principal (galerie, plein écran)
- [x] CHK015 Les limites connues (couleurs fixes du visualiseur, lisibilité du nom) sont écrites
- [ ] CHK016 Toutes les exigences ont un test automatisé (FR-003 à FR-007 et FR-009 n'ont que des vérifications manuelles)

## Notes

- CHK016 reste décoché : voir Complexity Tracking dans `plan.md`.
