# Specification Quality Checklist: Sorts d'invocateur conseillés et onglet Outils

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] CHK001 Les exigences ne citent ni classe, ni fichier, ni technologie (les chemins sont dans plan.md)
- [x] CHK002 Centrée sur la valeur pour le joueur (sorts conseillés, accès rapide aux outils)
- [x] CHK003 Compréhensible par un lecteur non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]` ne subsiste
- [x] CHK006 Les exigences FR-001 à FR-012 sont testables et sans ambiguïté
- [x] CHK007 Les critères de réussite sont mesurables (deux sorts, six destinations, deux touches)
- [x] CHK008 Les critères de réussite sont indépendants de la technologie
- [x] CHK009 Chaque parcours a des scénarios d'acceptation Given/When/Then
- [x] CHK010 Les cas limites sont identifiés (échec silencieux, voie inconnue, sort retiré, modes événementiels)
- [x] CHK011 Le périmètre est borné (contenu des outils renvoyé aux spécifications 010 et 011)
- [x] CHK012 Les hypothèses et limites sont listées (plans rédigés à la main, vouvoiement, tests manquants)

## Feature Readiness

- [x] CHK013 Les règles de choix de sorts (FR-002 à FR-005) ont un test cité dans tasks.md
- [ ] CHK014 L'ouverture d'un outil par une tuile (FR-010) et l'absence de section Outils sur l'accueil (FR-011) sont couvertes par un test automatisé : aucun test de `ToolsSection` ni de `HomePage`
- [ ] CHK015 La construction paresseuse des onglets (FR-008) est couverte par un test automatisé : aucun test de `MainNavigation`

## Notes

- CHK014 et CHK015 restent décochés : lacunes de tests constatées, pas de défaut de spécification.
