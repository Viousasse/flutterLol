# Specification Quality Checklist: Composition d'équipe

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Les exigences ne citent ni classe, ni fichier, ni technologie
- [x] CHK002 Centrée sur la valeur pour le joueur (savoir ce qui manque à son équipe)
- [x] CHK003 Compréhensible par un lecteur non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences FR-001 à FR-015 sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables (cinq choix, moins de trois champions)
- [x] CHK008 Les critères de réussite sont indépendants de la technologie
- [x] CHK009 Chaque parcours a des scénarios d'acceptation Given/When/Then
- [x] CHK010 Les cas limites sont identifiés (fiche en échec, équipe vide, deux types de dégâts bas)
- [x] CHK011 Le périmètre est borné (raccourcis de draft hors périmètre)
- [x] CHK012 Les hypothèses et limites sont listées (estimation du contrôle, pas de sauvegarde)

## Feature Readiness

- [x] CHK013 Chaque exigence de calcul (FR-005 à FR-011) a un test cité dans tasks.md
- [ ] CHK014 Les exigences d'interaction de l'écran (FR-001 à FR-004, FR-014) sont couvertes par un test d'écran : aucun test de `TeamPage` n'existe
- [x] CHK015 Les limites connues (estimation du contrôle) sont écrites dans la spécification

## Notes

- CHK014 reste décoché : lacune de tests constatée, pas de défaut de spécification.
