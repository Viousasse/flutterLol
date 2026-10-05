# Specification Quality Checklist: Carte du dernier patch sur l'accueil

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

**Note**: spécification rédigée après coup ; une case cochée signifie que le critère de qualité est satisfait, pas que le travail est fait.

## Content Quality

- [x] CHK001 Aucun détail d'implémentation dans `spec.md` (les exigences disent « le système DOIT… »)
- [x] CHK002 Centrée sur la valeur pour le joueur
- [x] CHK003 Lisible par une personne non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]`
- [x] CHK006 Exigences testables et non ambiguës (règle +10, adresse exacte, message exact)
- [x] CHK007 Critères de réussite mesurables
- [x] CHK008 Critères de réussite indépendants de la technologie
- [x] CHK009 Scénarios d'acceptation définis pour chaque parcours
- [x] CHK010 Cas limites identifiés (version illisible, chargement tardif, échec d'ouverture, lecteur d'écran)
- [x] CHK011 Périmètre borné (lien seulement, pas le contenu des notes)
- [x] CHK012 Dépendances et hypothèses listées (dernière version Data Dragon, motif d'adresse non vérifié en réseau)

## Feature Readiness

- [x] CHK013 Chaque exigence a un critère d'acceptation ou une vérification citée dans `quickstart.md`
- [x] CHK014 Les parcours couvrent le flux principal et le repli
- [x] CHK015 L'écart avec la demande (lien au lieu du contenu) est écrit dans « Limites connues »
- [ ] CHK016 Toutes les exigences ont un test automatisé (seul FR-002 en a un)

## Notes

- CHK016 reste décoché : voir Complexity Tracking dans `plan.md`.
- Dépendance `url_launcher` hors constitution : consignée dans `plan.md`.
