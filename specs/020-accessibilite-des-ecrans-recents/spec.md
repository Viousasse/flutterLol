# Feature Specification: Accessibilité des écrans récents

**Feature Branch**: `020-accessibilite-des-ecrans-recents` (travail livré sur `main`)

**Created**: 2026-10-05 (commit `e6e506c` ; un premier passage sur le contraste et l'accessibilité date de `a1c29ba`, même jour)

**Status**: Implemented

**Input**: User description : « on peut ameliorer quoi encore », puis, parmi les pistes proposées (dont l'accessibilité), « fais tout les changements ». Le périmètre a été fixé ensuite comme un passage d'accessibilité sur les écrans ajoutés récemment (draft, bilan, historique, détail, filtres de rôle, navigation, boîtes d'import), avec le référentiel RGAA : contraste du texte d'au moins 4,5:1, zone tactile d'au moins 44 px, nom accessible pour tout contrôle, état annoncé. Le rapport d'audit est `docs/agents/reports/a11y-audit.md`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Les puces de filtre annoncent leur rôle et leur état (Priority: P1)

Avec un lecteur d'écran, chaque puce de filtre (voies, rôles de la feuille de choix d'un champion, et autres filtres de l'application) est annoncée comme un bouton, avec son libellé et son état « sélectionné » ou non.

**Why this priority**: avant ce passage, rien n'annonçait l'état sélectionné : une personne qui n'y voit pas ne pouvait pas savoir quel filtre était actif. Ces puces sont partout.

**Independent Test**: activer un lecteur d'écran (ou `tester.ensureSemantics()`) sur une puce : elle est un bouton, porte son libellé et un état sélectionné vrai ou faux, et réagit au toucher.

**Acceptance Scenarios**:

1. **Given** une puce sélectionnée, **When** le lecteur d'écran la lit, **Then** il annonce un bouton, son libellé et « sélectionné ».
2. **Given** une puce non sélectionnée, **When** il la lit, **Then** l'état « non sélectionné » est exposé.
3. **Given** une puce, **When** je la touche, **Then** l'action de filtre se déclenche comme avant.

---

### User Story 2 - Des zones tactiles de 44 px pour les filtres de voie et de rôle (Priority: P1)

Les puces de la barre de voies (contre-picks, points forts) et de la rangée de rôles de la feuille de choix d'un champion ont une zone tactile de 44 px de haut, alors que la pastille visible garde 32 px.

**Why this priority**: les puces de 32 px étaient sous le seuil RGAA et difficiles à viser au pouce ; c'est le geste le plus fréquent de ces écrans.

**Independent Test**: dans la barre de voies, mesurer la hauteur de la zone qui reçoit le toucher (44 px) et celle de la pastille (32 px).

**Acceptance Scenarios**:

1. **Given** une puce posée dans une hauteur imposée d'au moins 44 px, **When** je mesure, **Then** la zone tactile fait 44 px et la pastille visible 32 px.
2. **Given** la barre de voies, **When** je touche juste au-dessus ou en dessous de la pastille, **Then** la puce réagit.
3. **Given** une puce posée dans une hauteur imposée plus basse (30 à 34 px), **When** elle s'affiche, **Then** elle garde sa taille d'origine et la mise en page n'est pas cassée.

---

### User Story 3 - Les titres de sections sont des titres pour les lecteurs d'écran (Priority: P2)

Dans le bilan d'une draft (VERDICT, POURQUOI, BANNISSEMENTS, CE QUI VA BIEN, À AMÉLIORER), dans le panneau SUGGESTIONS et dans la feuille « Affichage », les titres sont annoncés comme des titres, pour pouvoir sauter de titre en titre.

**Why this priority**: améliore la navigation dans des écrans longs, sans changer l'aspect.

**Independent Test**: ouvrir un bilan avec `ensureSemantics()` : chaque titre porte l'indicateur « titre ».

**Acceptance Scenarios**:

1. **Given** un bilan de draft avec bannissements, **When** je lis l'arbre sémantique, **Then** les cinq titres (VERDICT, POURQUOI, BANNISSEMENTS, CE QUI VA BIEN, À AMÉLIORER) sont des titres.
2. **Given** le panneau de suggestions, **When** il s'affiche, **Then** « SUGGESTIONS » est un titre.
3. **Given** la feuille de choix du thème, **When** elle s'ouvre, **Then** « Affichage » est un titre.

---

### User Story 4 - Un contraste de texte garanti (Priority: P2)

Le texte secondaire et le texte discret restent lisibles (au moins 4,5:1) sur le fond, les cartes et une puce sélectionnée, dans les deux modes (sombre et clair) ; l'accent reste lisible sur une puce sélectionnée.

**Why this priority**: la palette était déjà conforme ; l'enjeu est de ne pas régresser lors des futurs changements de couleurs.

**Independent Test**: lancer `flutter test test/theme/contrast_test.dart`.

**Acceptance Scenarios**:

1. **Given** la palette sombre ou claire, **When** on mesure le texte discret et le texte secondaire sur le fond, la carte et une puce sélectionnée, **Then** tous les rapports sont supérieurs ou égaux à 4,5.
2. **Given** l'accent sur une puce sélectionnée, **When** on mesure, **Then** le rapport est supérieur ou égal à 4,5.

---

### User Story 5 - Les autres contrôles restent conformes (Priority: P3)

L'audit a vérifié que les cases de draft, les bannissements, les cartes de suggestion, les boutons-icônes, le dialogue d'import, la note de provenance, les tuiles de contre-picks, la barre de navigation et les images décoratives étaient déjà accessibles (nom, action annoncée, images exclues) ; ils n'ont pas été modifiés.

**Why this priority**: constat, sans changement de comportement ; il documente ce qui a été regardé.

**Independent Test**: lire le tableau de `docs/agents/reports/a11y-audit.md` (lignes « ok »).

**Acceptance Scenarios**:

1. **Given** les boutons-icônes de l'historique et du détail, **When** je les inspecte, **Then** chacun a une info-bulle (donc un nom accessible) et une zone d'au moins 48 px.
2. **Given** le statut de la draft, **When** il change, **Then** il est annoncé (zone `liveRegion`).

---

### Edge Cases

- Une puce posée dans une hauteur imposée de moins de 44 px garde sa taille d'origine : l'agrandissement de la zone tactile n'est activé que si l'appelant offre au moins 44 px de hauteur imposée.
- Une hauteur non imposée (puce dans un `Wrap` sans contrainte de hauteur) donne la taille d'origine.
- Une puce dans un `Wrap` ne doit pas occuper toute la largeur offerte (commentaire du code ; non couvert par un test dédié).
- Dans la barre de voies, l'écart vertical entre les lignes passe à 0 puisque la zone tactile le fournit ; les lignes de puces sont donc un peu plus espacées visuellement (44 px de zone pour 32 px visibles).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Le système DOIT annoncer chaque puce de filtre comme un bouton portant son libellé et son état sélectionné ou non, et DOIT relayer l'action de toucher aux technologies d'assistance.
- **FR-002**: Le système DOIT offrir une zone tactile d'au moins 44 px de haut pour les puces de la barre de voies et de la rangée de rôles de la feuille de choix d'un champion, tout en gardant la pastille visible à 32 px.
- **FR-003**: Le système NE DOIT PAS modifier la taille des puces posées dans une hauteur imposée de moins de 44 px.
- **FR-004**: Le système DOIT annoncer comme titres : VERDICT, POURQUOI, BANNISSEMENTS, CE QUI VA BIEN, À AMÉLIORER (bilan), SUGGESTIONS et « Affichage ».
- **FR-005**: Le texte secondaire et le texte discret DOIVENT avoir un rapport de contraste d'au moins 4,5:1 sur le fond, les cartes et une puce sélectionnée, dans les modes sombre et clair, et l'accent DOIT l'avoir sur une puce sélectionnée ; un test automatique DOIT le vérifier.
- **FR-006**: Les contrôles par icône seule des écrans concernés DOIVENT avoir une info-bulle servant de nom accessible.
- **FR-007**: Les images purement décoratives DOIVENT être exclues de l'arbre sémantique.
- **FR-008**: Le statut d'avancement d'une draft DOIT être annoncé aux technologies d'assistance quand il change.
- **FR-009**: L'audit DOIT être consigné dans un rapport listant chaque élément, son problème, son correctif et s'il est fait.
- **FR-010**: Ce passage NE DOIT PAS changer la palette de couleurs.

### Key Entities

- **Puce de filtre** : contrôle de sélection (libellé, sélectionné ou non).
- **Zone tactile** : zone qui reçoit le toucher, distincte de la pastille visible.
- **Rapport d'audit** : tableau écran / élément / problème / correctif / fait.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100 % des puces de filtre exposent un rôle de bouton et un état sélectionné.
- **SC-002**: Les puces de la barre de voies et de la rangée de rôles ont une zone tactile mesurée de 44 px de haut et une pastille de 32 px.
- **SC-003**: Tous les rapports de contraste testés (deux palettes, trois fonds, deux niveaux de texte, plus l'accent) valent au moins 4,5.
- **SC-004**: Aucun changement de couleur : les fichiers de palette ne sont pas modifiés.
- **SC-005**: Le rapport d'audit ne contient plus d'élément « non » sans suivi explicite.

## Assumptions et limites connues

- **Limite** : les autres appelants de `AppFilterChip` (région, objets, carte, quiz, régions) imposent des hauteurs de 30 à 34 px et gardent cette taille ; ils sont annoncés correctement mais restent sous 44 px de zone tactile. Pour les agrandir, il suffit de leur passer `SizedBox(height: AppFilterChip.minTapHeight)` ; ce suivi n'est pas fait.
- **Limite** : le titre de colonne modifiable du mode à deux (`_ColumnTitle` dans `lib/draft/draft_page.dart`) est correctement nommé et son action annoncée, mais sa zone tactile est d'environ 22 px de haut. Elle n'a pas été changée : l'agrandir modifierait la mise en page visible, décision laissée à l'architecte.
- Changements **visibles** : lignes de puces un peu plus espacées dans la barre de voies et la rangée de rôles (zone tactile de 44 px pour une pastille de 32 px, `runSpacing` passé de 7 à 0).
- Les titres BANNISSEMENTS et SUGGESTIONS sont marqués comme titres dans le code mais ne sont pas couverts par `test/draft/draft_a11y_test.dart` (qui vérifie VERDICT, POURQUOI, CE QUI VA BIEN, À AMÉLIORER et « Affichage »).
- Le test de contraste ne couvre que les paires listées ci-dessus ; les autres couleurs de sens (victoire, défaite) ne sont pas mesurées.
- Aucun test avec un vrai lecteur d'écran (TalkBack, VoiceOver) n'a été fait : les tests utilisent l'arbre sémantique de Flutter.
- Le référentiel est le RGAA ; la conformité complète de l'application n'est pas revendiquée, seulement celle des écrans audités.
