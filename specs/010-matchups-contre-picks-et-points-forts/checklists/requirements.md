# Specification Quality Checklist: Matchups, contre-picks et points forts

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Les exigences ne citent ni classe, ni fichier, ni technologie (les chemins sont dans plan.md)
- [x] CHK002 Centrée sur la valeur pour le joueur (quoi jouer, contre qui)
- [x] CHK003 Compréhensible par un lecteur non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences FR-001 à FR-019 sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables (100 % des champions, 8 parties, 15 propositions)
- [x] CHK008 Les critères de réussite sont indépendants de la technologie
- [x] CHK009 Chaque parcours a des scénarios d'acceptation Given/When/Then
- [x] CHK010 Les cas limites sont identifiés (échec de chargement, données vides, champion inconnu, peu de parties)
- [x] CHK011 Le périmètre est borné (outil de génération renvoyé à la spécification 019)
- [x] CHK012 Les hypothèses et limites connues sont listées (vouvoiement, couleurs en dur, rang et région fixes)

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation ou un test cité dans tasks.md
- [x] CHK014 Les parcours couvrent les flux principaux (contre-picks, repli, points forts, provenance, liens de la fiche)
- [ ] CHK015 Les liens de la fiche champion (FR-017) sont couverts par un test automatisé : seul l'écran cible est testé avec un champion initial, pas les boutons de la fiche
- [ ] CHK016 `LaneFilterBar` et `CounterTile` ont chacun un fichier de test dédié : ils ne sont couverts qu'à travers les tests de pages

## Notes

- CHK015 et CHK016 restent décochés : lacunes de tests constatées, pas de défaut de spécification.
