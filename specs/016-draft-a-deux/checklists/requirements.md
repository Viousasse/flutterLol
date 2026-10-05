# Specification Quality Checklist: Draft à deux

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans `spec.md` (langage, classes, fichiers)
- [x] CHK002 Centrée sur la valeur pour l'utilisateur (jouer entre amis, suivre la soirée)
- [x] CHK003 Rédigée pour des lecteurs non techniques
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]`
- [x] CHK006 Les exigences sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables
- [ ] CHK008 Les critères de réussite sont indépendants de la technologie (SC-001 cite le fichier de test qui le vérifie)
- [x] CHK009 Tous les scénarios d'acceptation sont définis
- [x] CHK010 Les cas limites sont identifiés
- [x] CHK011 Le périmètre est borné (règles de draft = 015, historique et rejeu = 017)
- [x] CHK012 Les dépendances et hypothèses sont listées

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation ou un test (voir la table de `quickstart.md`)
- [ ] CHK014 Toutes les exigences sont couvertes par un test automatisé (l'aide au choix en duel et le renommage en rejeu ne sont pas testés)
- [x] CHK015 Les scénarios utilisateur couvrent le parcours principal et les secondaires
- [x] CHK016 Les écarts et limites sont notés (« Hypothèses et limites connues » : pas de masquage, vouvoiement, longueur non revérifiée)
- [ ] CHK017 Conformité complète à la constitution (vouvoiement ; service qui importe un fichier de widget : voir `plan.md`)

## Notes

- Les cases vides CHK008, CHK014 et CHK017 correspondent à des écarts réels, pas à des oublis.
