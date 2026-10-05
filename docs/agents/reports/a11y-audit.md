# Audit d'accessibilité (T11)

Référentiel : RGAA (contraste texte >= 4,5:1, zone tactile >= 44 px, nom
accessible, état annoncé). Périmètre : `lib/draft/**`, `lib/shared/widgets/**`,
`lib/main_navigation/**`, `lib/theme/**`.

| Écran | Élément | Problème | Correctif | Fait ? |
|-------|---------|----------|-----------|--------|
| Partagé | `AppFilterChip` | Aucun rôle ni état annoncé (ni « bouton », ni « sélectionné ») | `Semantics(button, selected, label, onTap)` | oui |
| Partagé | `AppFilterChip` dans `LaneFilterBar` et le sélecteur de rôle | Hauteur 32 px < 44 px | Zone tactile de 44 px (`AppFilterChip.minTapHeight`) quand l'appelant impose >= 44 px ; pastille visible toujours à 32 px. `LaneFilterBar` et la rangée de la feuille de champions donnent 44 px | oui |
| Partagé | `AppFilterChip` dans les autres écrans (région, objets, carte, quiz, régions) | Hauteurs imposées de 30 à 34 px par les appelants (hors périmètre) | Rien tant que l'appelant ne donne pas 44 px : passer `SizedBox(height: AppFilterChip.minTapHeight)` | non (suivi) |
| Partagé | `ChampionPickerSheet` | Champ de recherche : libellé = indice seul ; lignes déjà des `ListTile` (nom + titre lus, tapables) ; images exclues (`RemoteImage` sans `semanticLabel`) | Aucun changement nécessaire | ok |
| Partagé | `PasteCodeDialog` | Champ nommé (`labelText`), erreur via `errorText` (annoncée), boutons >= 48 px | Aucun | ok |
| Partagé | `DataSourceNote` | Lu en une phrase, déjà exclu du détail | Aucun | ok |
| Partagé | `CounterTile` | Bouton nommé avec chiffres et avertissement `peu de données` | Aucun | ok |
| Partagé | `RemoteImage` | Décoratif par défaut (exclu de l'arbre) | Aucun | ok |
| Navigation | `AppNavBar` | Bouton + `selected` + libellé déjà annoncés ; hauteur ~56 px | Aucun | ok |
| Thème | `ThemeModeSheet` | Titre « Affichage » non annoncé comme titre | `Semantics(header: true)` ; les lignes sont des `ListTile` avec `selected` | oui |
| Draft | Bilan : `VERDICT`, `POURQUOI`, `BANNISSEMENTS`, `CE QUI VA BIEN`, `À AMÉLIORER` | Titres de section lus comme du texte simple | `Semantics(header: true)` (`_SectionTitle`) | oui |
| Draft | Panneau `SUGGESTIONS` | Idem | `Semantics(header: true)` | oui |
| Draft | `DraftSlot`, `BanRow`, `SuggestionCard` | Libellé complet, action annoncée, images exclues | Aucun (déjà conforme) | ok |
| Draft | Titre de colonne modifiable (`_ColumnTitle`, mode à deux) | Libellé et action annoncés, mais zone tactile ~22 px de haut | Non changé : agrandir modifierait la mise en page visible ; à décider par l'architecte | non (suivi) |
| Draft | `IconButton` historique, rejouer, partager, supprimer, score | Tous ont un `tooltip` (donc un nom accessible) et >= 48 px | Aucun | ok |
| Draft | Message d'état (`liveRegion`) et `SnackBar` d'import | Statut de la draft annoncé ; les `SnackBar` sont annoncés par Flutter | Aucun | ok |
| Thème | `textMuted`, `textSecondary` sur fond, carte et puce choisie, deux palettes | Doit tenir 4,5:1 | Déjà conforme (la palette avait été réglée) ; couvert par `test/theme/contrast_test.dart` | ok |

Aucune modification de `lib/theme/app_colors.dart`.
