# Spécifications des fonctionnalités

Chaque dossier suit la structure de spec-kit (`.specify/templates/`) :
`spec.md` (parcours, exigences, critères), `plan.md` (contexte technique et
vérification de la constitution), `research.md` (décisions), `data-model.md`,
`contracts/`, `quickstart.md` (validation à la main et commandes de test),
`tasks.md` et `checklists/requirements.md`.

Les spécifications sont rédigées à partir du code livré, de l'historique git et
des tests. Quand le code s'écarte de la constitution
(`.specify/memory/constitution.md`) ou d'une demande, l'écart est écrit dans le
`spec.md` ou dans la section « Complexity Tracking » du `plan.md`, et la case
correspondante de la checklist reste décochée.

| N° | Fonctionnalité | Tâches faites |
|----|----------------|---------------|
| 001 | [Images nettes et accessibilité de base](001-images-nettes-et-accessibilite-de-base/spec.md) | 15 |
| 002 | [Données hors ligne](002-donnees-hors-ligne/spec.md) | 25 |
| 003 | [Quiz : chrono, historique des séries et duels](003-quiz-chrono-et-duels/spec.md) | 22 |
| 004 | [Objets favoris](004-objets-favoris/spec.md) | 14 |
| 005 | [Recherche et comparaison des champions](005-recherche-et-comparaison-des-champions/spec.md) | 43 |
| 006 | [Carte du dernier patch sur l'accueil](006-carte-du-dernier-patch/spec.md) | 10 |
| 007 | [Galerie des apparences d'un champion](007-galerie-des-apparences/spec.md) | 11 |
| 008 | [Constructeur de builds, partage et import par code](008-constructeur-de-builds/spec.md) | 36 |
| 009 | [Grilles adaptées aux écrans larges](009-grilles-adaptees-aux-ecrans-larges/spec.md) | 8 |
| 010 | [Matchups, contre-picks et points forts](010-matchups-contre-picks-et-points-forts/spec.md) | 36 |
| 011 | [Composition d'équipe](011-composition-d-equipe/spec.md) | 23 |
| 012 | [Sorts d'invocateur conseillés et onglet Outils](012-sorts-d-invocateur-et-onglet-outils/spec.md) | 18 |
| 013 | [Thème clair / sombre et palette du client LoL](013-theme-clair-sombre-et-palette-lol/spec.md) | 23 |
| 014 | [Barre de navigation](014-barre-de-navigation/spec.md) | 14 |
| 015 | [Entraîneur de draft](015-entraineur-de-draft/spec.md) | 40 |
| 016 | [Draft à deux](016-draft-a-deux/spec.md) | 25 |
| 017 | [Historique, partage et import des drafts](017-historique-partage-et-import-des-drafts/spec.md) | 33 |
| 018 | [Filtre de rôle dans le choix d'un champion](018-filtre-de-role/spec.md) | 17 |
| 019 | [Outil de mise à jour des matchups](019-outil-de-mise-a-jour-des-matchups/spec.md) | 21 |
| 020 | [Accessibilité des écrans récents](020-accessibilite-des-ecrans-recents/spec.md) | 15 sur 18 |

Dans la 020, les trois tâches restantes sont des suites connues : agrandir la
zone tactile des puces des autres écrans, celle du titre de colonne modifiable
du mode à deux, et tester les titres « BANNISSEMENTS » et « SUGGESTIONS ».

## Écarts récurrents relevés
- **Vouvoiement** des textes de plusieurs écrans, alors que le principe VII de la
  constitution demande le tutoiement.
- **Couleurs codées en dur** dans quelques widgets (principe IV).
- **Écrans sans test d'écran** pour une partie des fonctionnalités les plus
  anciennes (principe VI).
- **Un widget public par fichier** non respecté à quelques endroits (principe I).
