# Specification Quality Checklist: Images nettes et accessibilité de base

**Purpose**: valider la complétude et la qualité de la spécification avant le plan
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [ ] CHK001 Aucun détail d'implémentation dans `spec.md` (cas limites et limites connues citent `ShimmerBox`, CORS, `<img>` et des fichiers, pour rester vérifiables)
- [x] CHK002 Centrée sur la valeur pour l'utilisateur (netteté, lisibilité, accessibilité)
- [x] CHK003 Rédigée pour des lecteurs non techniques
- [x] CHK004 Toutes les sections obligatoires sont renseignées

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Les scénarios d'acceptation sont définis pour chaque parcours
- [x] CHK010 Les cas limites sont identifiés (web, taille nulle, lien mort, visuel de remplacement)
- [x] CHK011 Le périmètre est borné (cartes de la liste et de la comparaison, barre d'onglets, badge)
- [x] CHK012 Les hypothèses et limites connues sont écrites (absence de tests dédiés, palette remplacée depuis)

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation
- [x] CHK014 Les parcours couvrent les flux principaux
- [x] CHK015 La fonctionnalité répond aux critères de réussite
- [ ] CHK016 Chaque exigence est couverte par un test automatisé (FR-001 à FR-006 et FR-008 n'en ont pas)

## Notes

- CHK016 reste décoché volontairement : la dette de test est documentée dans `plan.md` (Complexity Tracking).
