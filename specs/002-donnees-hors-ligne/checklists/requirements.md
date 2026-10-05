# Specification Quality Checklist: Données hors ligne

**Purpose**: valider la complétude et la qualité de la spécification avant le plan
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [ ] CHK001 Aucun détail d'implémentation dans `spec.md` (les noms de jeux de données et la limite de 12 fiches sont des choix de produit ; le stockage du navigateur et un rapport d'audit sont cités pour le contexte)
- [x] CHK002 Centrée sur la valeur pour l'utilisateur (ouvrir l'application sans réseau)
- [x] CHK003 Rédigée pour des lecteurs non techniques
- [x] CHK004 Toutes les sections obligatoires sont renseignées

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Les scénarios d'acceptation sont définis pour chaque parcours
- [x] CHK010 Les cas limites sont identifiés (premier lancement hors ligne, délai, stockage plein, copie corrompue)
- [x] CHK011 Le périmètre est borné (données Riot ; images et matchups hors périmètre)
- [x] CHK012 Les hypothèses et limites connues sont écrites

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation
- [x] CHK014 Les parcours couvrent les flux principaux
- [x] CHK015 La fonctionnalité répond aux critères de réussite
- [ ] CHK016 Chaque exigence est couverte par un test automatisé (FR-007, FR-008 et FR-011 ne le sont pas)

## Notes

- CHK001 et CHK016 restent décochés volontairement ; voir `plan.md` (Complexity Tracking) pour la dette de test.
