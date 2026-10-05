# Specification Quality Checklist: Outil de mise à jour des matchups

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-09-16
**Feature**: [spec.md](../spec.md)

## Content Quality

- [ ] CHK001 Aucun détail d'implémentation dans `spec.md` (non : l'outil est lui-même une interface technique ; le spec cite les options `--decay`, `--min-patch`, `--resume` et la variable `RIOT_API_KEY`, qui sont l'interface publique de la fonctionnalité)
- [x] CHK002 Centrée sur la valeur pour le mainteneur et, par suite, pour le joueur
- [x] CHK003 Compréhensible sans lire le code
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite ne dépendent pas de la technologie (sauf SC-003, qui cite le préfixe de clé)
- [x] CHK009 Tous les scénarios d'acceptation sont définis
- [x] CHK010 Les cas limites sont identifiés
- [x] CHK011 Le périmètre est borné (aucun service, génération manuelle)
- [x] CHK012 Les dépendances et hypothèses sont listées

## Feature Readiness

- [x] CHK013 Aucune clé Riot réelle ne figure dans la spécification (exemple `RGAPI-...` seulement)
- [ ] CHK014 Chaque exigence a un test automatique (non : FR-001, FR-003, FR-004, FR-008, FR-009 reposent sur l'exécution manuelle de l'outil)
- [x] CHK015 La logique pure est couverte par des tests (`test/tool/matchup_tally_test.dart`)

## Notes

- CHK001 et CHK014 restent décochés : l'outil n'a pas d'interface autre que sa ligne de commande, et son orchestration n'est pas testée automatiquement.
