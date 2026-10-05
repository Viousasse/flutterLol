# Specification Quality Checklist: Filtre de rôle

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans les exigences de `spec.md`
- [x] CHK002 Centrée sur la valeur pour le joueur
- [x] CHK003 Compréhensible par un lecteur non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Tous les scénarios d'acceptation sont définis
- [x] CHK010 Les cas limites sont identifiés
- [x] CHK011 Le périmètre est borné
- [x] CHK012 Les dépendances et hypothèses sont listées

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un test ou un comportement observable cité
- [ ] CHK014 Les seuils de FR-005 (8 parties, 15 %) ont un test dédié (non : aucun test de `LaneProfile.fits` sur les seuils)
- [ ] CHK015 L'intégration du filtre dans chaque écran client est testée (non : seule la feuille et le constructeur le sont)

## Notes

- FR-005 cite deux seuils chiffrés : ce sont des règles observables, mais leur origine n'est pas documentée au-delà du commentaire du code.
- CHK014 et CHK015 restent décochés : lacunes de couverture connues.
