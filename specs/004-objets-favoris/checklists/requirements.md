# Specification Quality Checklist: Objets favoris

**Purpose**: valider la complétude et la qualité de la spécification avant le plan
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans la partie exigences de `spec.md` (les noms de fichiers n'apparaissent que dans « Hypothèses et limites connues » et le contexte)
- [x] CHK002 Centrée sur la valeur pour l'utilisateur (marquer et retrouver ses objets)
- [x] CHK003 Rédigée pour des lecteurs non techniques
- [x] CHK004 Toutes les sections obligatoires sont renseignées

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Les scénarios d'acceptation sont définis pour chaque parcours
- [x] CHK010 Les cas limites sont identifiés (objet disparu, écriture en échec, double bascule)
- [x] CHK011 Le périmètre est borné (pas de filtre « favoris » sur la page des objets)
- [x] CHK012 Les hypothèses et limites connues sont écrites (libellé du raccourci, étoile sans étiquette)

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation
- [x] CHK014 Les parcours couvrent les flux principaux
- [x] CHK015 La fonctionnalité répond aux critères de réussite
- [ ] CHK016 Chaque exigence est couverte par un test automatisé (FR-002, FR-004 à FR-007, FR-009 à FR-011 ne le sont pas)

## Notes

- CHK016 reste décoché volontairement ; la dette de test est dans `plan.md` (Complexity Tracking).
