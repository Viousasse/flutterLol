# Specification Quality Checklist: Recherche et comparaison des champions

**Purpose**: valider la qualité de la spécification avant planification
**Created**: 2026-10-05
**Feature**: [spec.md](../spec.md)

**Note**: spécification rédigée après coup ; les cases cochées signifient que le critère de qualité est satisfait, pas que le travail est fait.

## Content Quality

- [x] CHK001 Aucun détail d'implémentation (langage, bibliothèque, classe) dans `spec.md` : les exigences parlent de « le système DOIT… »
- [x] CHK002 Centrée sur la valeur pour le joueur (comparer, retrouver, filtrer)
- [x] CHK003 Lisible par une personne non technique
- [x] CHK004 Toutes les sections obligatoires sont remplies, sans texte modèle

## Requirement Completeness

- [x] CHK005 Aucun marqueur `[NEEDS CLARIFICATION]`
- [x] CHK006 Chaque exigence est testable et non ambiguë (seuils chiffrés : 1 à 18, 6 objets, 8 résultats, 8 parties, 100 parties, 2,5, 100 %)
- [x] CHK007 Les critères de réussite sont mesurables
- [x] CHK008 Les critères de réussite sont indépendants de la technologie
- [x] CHK009 Tous les scénarios d'acceptation sont définis pour chaque parcours
- [x] CHK010 Les cas limites sont identifiés (même champion, chargement concurrent, niveau hors bornes, plafonds, fichier de matchups absent, requête vide)
- [x] CHK011 Le périmètre est borné (un niveau commun, bonus chiffrés seulement, pas de persistance de l'état)
- [x] CHK012 Les dépendances et hypothèses sont listées (Data Dragon, fichier de matchups embarqué, builds enregistrées)

## Feature Readiness

- [x] CHK013 Chaque exigence fonctionnelle a un critère d'acceptation ou un test cité dans `quickstart.md`
- [x] CHK014 Les parcours couvrent les flux principaux (comparer, duel, build, recherche, filtre, fiche)
- [x] CHK015 La fonctionnalité atteint les résultats mesurables de la section Success Criteria
- [ ] CHK016 Toutes les exigences ont un test automatisé (FR-011, FR-012, FR-013, FR-019, FR-020 et le seuil de 100 parties ne sont vérifiés qu'à la main)

## Notes

- CHK016 reste décoché : voir Complexity Tracking dans `plan.md`.
- Écarts avec la constitution consignés dans `plan.md` : vouvoiement, recherche de la feuille de champion sans normalisation d'accents.
