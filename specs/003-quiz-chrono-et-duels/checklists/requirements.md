# Specification Quality Checklist: Quiz : chrono, historique des séries et duels

**Purpose**: valider la complétude et la qualité de la spécification avant le plan
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [ ] CHK001 Aucun détail d'implémentation dans `spec.md` (la section « Hypothèses et limites connues » cite des noms de fichiers et de widgets pour la traçabilité)
- [x] CHK002 Centrée sur la valeur pour l'utilisateur (jouer contre la montre, suivre ses séries, nouvelles questions)
- [x] CHK003 Rédigée pour des lecteurs non techniques
- [x] CHK004 Toutes les sections obligatoires sont renseignées

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Les scénarios d'acceptation sont définis pour chaque parcours
- [x] CHK010 Les cas limites sont identifiés (matchups absents, réseau, aucune question, onglet masqué)
- [x] CHK011 Le périmètre est borné (quiz du jour exclu)
- [x] CHK012 Les hypothèses et limites connues sont écrites (chrono non mémorisé, vouvoiement, pas de test de la page)

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation
- [x] CHK014 Les parcours couvrent les flux principaux
- [x] CHK015 La fonctionnalité répond aux critères de réussite
- [ ] CHK016 Chaque exigence est couverte par un test automatisé (le chrono, FR-001, FR-002, FR-004 à FR-007, FR-010 et FR-017 ne le sont pas)

## Notes

- CHK001 et CHK016 restent décochés volontairement ; la dette de test est dans `plan.md` (Complexity Tracking).
