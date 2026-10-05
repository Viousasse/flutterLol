# Specification Quality Checklist: Accessibilité des écrans récents

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Les exigences ne dictent pas d'implémentation (les termes « zone tactile », « titre » sont des notions d'accessibilité)
- [x] CHK002 Centrée sur la valeur pour les personnes utilisant un lecteur d'écran ou ayant du mal à viser
- [x] CHK003 Compréhensible par un lecteur non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables (44 px, 32 px, 4,5:1)
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie
- [x] CHK009 Tous les scénarios d'acceptation sont définis
- [x] CHK010 Les cas limites sont identifiés
- [x] CHK011 Le périmètre est borné (écrans audités ; suivis listés)
- [x] CHK012 Les dépendances et hypothèses sont listées

## Feature Readiness

- [x] CHK013 Chaque exigence a un test ou une ligne d'audit
- [ ] CHK014 Tous les titres de FR-004 sont couverts par un test (non : BANNISSEMENTS et SUGGESTIONS ne le sont pas)
- [ ] CHK015 Toutes les puces de l'application respectent 44 px (non : limite connue, voir `spec.md`)
- [ ] CHK016 Une vérification avec un vrai lecteur d'écran est consignée (non : tests sur l'arbre sémantique de Flutter seulement)

## Notes

- CHK014 à CHK016 restent décochés : lacunes connues et documentées.
