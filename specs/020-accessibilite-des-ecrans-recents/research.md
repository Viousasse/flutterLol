# Research: Accessibilité des écrans récents

## 1. Référentiel RGAA

- **Decision**: contraste du texte au moins 4,5:1, zone tactile au moins 44 px, nom accessible pour tout contrôle, état annoncé.
- **Rationale**: énoncé de la fiche de la tâche et en-tête du rapport d'audit. Le calcul de contraste est celui de la luminance WCAG (`test/theme/contrast_test.dart`).
- **Alternatives considered**: pas de trace.

## 2. Zone tactile agrandie sans changer l'aspect

- **Decision**: `AppFilterChip` passe en zone tactile de la hauteur imposée (44 px) et dessine une pastille de 32 px centrée, uniquement si la contrainte de hauteur est stricte et d'au moins 44 px (`minTapHeight`, `visibleHeight`).
- **Rationale**: commentaire du code : « l'aspect reste celui des puces de 32 px posées jusque-là » et « Sinon la puce garde sa taille d'origine, pour ne pas casser les mises en page qui imposent une hauteur plus basse ». Beaucoup d'écrans imposent 30 à 34 px.
- **Alternatives considered**: agrandir toutes les puces à 44 px : rejeté par le même commentaire (casserait des mises en page). Rien d'autre n'est tracé.

## 3. Le toucher et la sémantique sur la même zone

- **Decision**: `Semantics(button, selected, label, onTap, excludeSemantics)` autour d'un `GestureDetector` en `HitTestBehavior.opaque`.
- **Rationale**: `opaque` rend toute la zone de 44 px sensible, y compris autour de la pastille (test « Un toucher à 6 px au-dessus du texte (hors pastille) est pris en compte »). `excludeSemantics` évite que le texte soit lu deux fois.

## 4. Ne pas fixer `hasEnabledState`

- **Decision**: le test attend `hasEnabledState: false` : la puce n'a pas d'état activé/désactivé.
- **Rationale**: la puce est toujours active.

## 5. `runSpacing: 0` et plus de marge verticale dans la rangée de rôles

- **Decision**: `LaneFilterBar` passe `runSpacing` de 7 à 0 ; la rangée de rôles de la feuille retire son `vertical: 6`.
- **Rationale**: commentaires : « la zone tactile en fournit déjà » l'écart ; « Pas de marge verticale : les puces prennent les 44 px de la rangée ». Changement visible assumé (lignes un peu plus espacées).

## 6. En-têtes sémantiques pour les titres

- **Decision**: `Semantics(header: true)` autour du titre ; `_SectionTitle` privé dans le fichier du bilan pour les quatre titres identiques.
- **Rationale**: commentaire : « les lecteurs d'écran permettent de sauter de titre en titre dans un bilan long ». `_SectionTitle` évite de répéter le même habillage ; il reste privé (un seul widget public par fichier).

## 7. Palette inchangée, test de non-régression

- **Decision**: `test/theme/contrast_test.dart` mesure `textMuted`, `textSecondary` sur fond, carte et puce sélectionnée (fond translucide fondu sur le fond), et l'accent sur la puce sélectionnée, pour `AppPalette.dark` et `AppPalette.light`.
- **Rationale**: rapport d'audit : « Déjà conforme (la palette avait été réglée) » (commit `a1c29ba`). La fiche de tâche prévoyait d'ajuster `lib/theme/app_colors.dart` si une paire échouait ; aucune ne l'a fait.

## 8. Les écrans déjà conformes ne sont pas touchés

- **Decision**: `DraftSlot`, `BanRow`, `SuggestionCard`, `PasteCodeDialog`, `DataSourceNote`, `CounterTile`, `AppNavBar` : aucun changement.
- **Rationale**: rapport d'audit, lignes « ok » : libellés complets, actions annoncées, images exclues, boutons-icônes avec info-bulle et au moins 48 px.

## 9. Ce qui n'a pas été fait, et pourquoi

- **Autres appelants de `AppFilterChip`** : hors périmètre de la tâche (hauteurs imposées de 30 à 34 px par leurs écrans) ; suivi proposé dans le rapport.
- **`_ColumnTitle` (22 px)** : « agrandir modifierait la mise en page visible ; à décider par l'architecte ».
