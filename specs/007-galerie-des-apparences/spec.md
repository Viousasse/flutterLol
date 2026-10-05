# Feature Specification: Galerie des apparences d'un champion

**Feature Branch**: `007-galerie-des-apparences` (travail livré sur `main`, sans branche dédiée)

**Created**: 2026-10-05

**Status**: Implemented

**Input**: User description: « tu pense que je pourrai ajouter quoi comme autre option ? » puis, parmi les idées proposées (apparences et constructeur de build) : « fais les deux » (commit `400a75c`). La moitié « constructeur de build » est décrite dans `specs/008-constructeur-de-builds`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Parcourir les apparences d'un champion (Priority: P1)

Sur la fiche d'un champion, après les capacités, une section « Apparences (n) » montre en défilement horizontal une vignette verticale par apparence avec son nom (deux lignes au plus).

**Why this priority**: c'est la partie visible de la demande et la base du plein écran.

**Independent Test**: ouvrir la fiche d'Ahri : la section liste ses apparences, sans les variantes de couleur.

**Acceptance Scenarios**:

1. **Given** un champion qui a plusieurs apparences, **When** sa fiche se charge, **Then** la section « Apparences (n) » apparaît avec n égal au nombre d'apparences hors variantes de couleur.
2. **Given** un champion qui n'a que son apparence d'origine, **When** sa fiche se charge, **Then** la section n'apparaît pas.
3. **Given** l'apparence d'origine, **When** elle est listée, **Then** elle est nommée « Apparence classique ».
4. **Given** un lecteur d'écran, **When** il atteint une vignette, **Then** elle est annoncée comme bouton « Voir <nom> en grand ».

---

### User Story 2 - Voir une apparence en plein écran et naviguer entre elles (Priority: P2)

Un appui sur une vignette ouvre l'illustration en plein écran sur fond noir. Le joueur glisse ou utilise les flèches pour passer d'une apparence à l'autre, pince pour zoomer (jusqu'à ×4), voit la position « 3 / 12 » et le nom de l'apparence.

**Why this priority**: valorise les illustrations, mais la galerie reste utile sans.

**Independent Test**: ouvrir la deuxième apparence, utiliser les flèches jusqu'aux extrémités.

**Acceptance Scenarios**:

1. **Given** une vignette appuyée, **When** la page s'ouvre, **Then** l'apparence choisie s'affiche en grand avec son nom et « rang / total ».
2. **Given** la première apparence, **When** la page est affichée, **Then** la flèche « Apparence précédente » est absente ; **Given** la dernière, **Then** la flèche « Apparence suivante » est absente.
3. **Given** une apparence affichée, **When** le joueur glisse ou appuie sur une flèche, **Then** la page voisine apparaît en 250 ms et le titre et le nom se mettent à jour.
4. **Given** une illustration, **When** le joueur pince, **Then** elle zoome jusqu'à ×4.

---

### Edge Cases

- Les variantes de couleur (chromas) n'ont pas d'illustration propre : elles sont écartées (elles portent une apparence « parente » dans les données).
- Liste d'apparences absente ou non conforme dans les données : section absente, pas d'erreur (`listFromJson` renvoie une liste vide).
- Illustration introuvable (lien mort) : le visuel de remplacement discret de `RemoteImage` s'affiche.
- Vignettes : illustration verticale légère « loading » ; plein écran : illustration « splash » horizontale (une icône de 120 px n'est pas étirée).
- Thème clair : le visualiseur reste sur fond noir (voir limites).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT lister sur la fiche d'un champion ses apparences, sans les variantes de couleur, quand il en a plus d'une, avec leur nombre dans le titre de section.
- **FR-002**: Le système DOIT nommer l'apparence d'origine « Apparence classique ».
- **FR-003**: Le système DOIT afficher chaque apparence en vignette verticale avec son nom sur au plus deux lignes, dans une rangée à défilement horizontal.
- **FR-004**: Le système DOIT ouvrir, à l'appui sur une vignette, l'illustration en grand format sur la page de l'apparence choisie.
- **FR-005**: Le système DOIT permettre de passer d'une apparence à l'autre en glissant et par deux flèches, masquer la flèche « précédente » sur la première et « suivante » sur la dernière.
- **FR-006**: Le système DOIT permettre de zoomer sur l'illustration jusqu'à un facteur 4.
- **FR-007**: Le système DOIT afficher la position (« n / total ») et le nom de l'apparence courante.
- **FR-008**: Le système DOIT utiliser pour les vignettes une illustration légère et pour le plein écran une grande illustration.
- **FR-009**: Le système DOIT exposer aux lecteurs d'écran des libellés pour les vignettes et les flèches.
- **FR-010**: Le système DOIT tolérer l'absence de liste d'apparences dans les données d'un champion.

### Key Entities *(include if feature involves data)*

- **Apparence**: un champion, un numéro (0 pour l'origine), un nom, deux adresses d'illustration (grande et verticale).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Pour toutes les données d'entrée testées (apparences, variantes de couleur, liste absente), le nombre d'apparences listées est celui des apparences non dérivées.
- **SC-002**: Depuis la fiche, le joueur atteint le plein écran d'une apparence en un appui et la voisine en un geste.
- **SC-003**: Aucune variante de couleur n'apparaît dans la galerie.
- **SC-004**: Les adresses d'illustration construites sont exactement celles du CDN de Data Dragon pour le numéro et le champion donnés.

## Assumptions

- La fiche détaillée de Data Dragon fournit la liste `skins` avec numéro et nom ; les illustrations sont servies par le CDN public de Data Dragon sous `cdn/img/champion/{splash|loading}/<Champion>_<n>.jpg`.
- Les noms des apparences sont ceux de Data Dragon dans la langue de la fiche ; seul « default » est traduit.
- La galerie n'a pas de recherche ni de filtre ; l'ordre est celui des données.

### Limites connues

- Le visualiseur en plein écran utilise `Colors.black` et `Colors.white` / `white70` directement (fond et textes), indépendants du thème clair ou sombre : choix d'une vue immersive, mais écart avec le principe IV de la constitution (voir `plan.md`).
- Le nom de l'apparence et les flèches sont posés sur l'illustration sans fond de renfort : leur lisibilité dépend de l'image.
- Aucun test de widget ne couvre la galerie ni le visualiseur ; seules la lecture des données et la construction des adresses sont testées.
- Le bouton retour de la barre est celui du système ; aucune action de partage ou de téléchargement n'existe.
