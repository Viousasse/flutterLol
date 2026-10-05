# Contrat : `AppFilterChip` et conteneurs de puces

## AppFilterChip (`lib/shared/widgets/app_filter_chip/app_filter_chip.dart`)

```dart
class AppFilterChip extends StatelessWidget {
  static const double minTapHeight = 44;   // zone tactile recommandée (RGAA)
  static const double visibleHeight = 32;  // hauteur de la pastille quand la zone est agrandie
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const AppFilterChip({super.key, required label, required selected, required onTap});
}
```

### Comportement

- **Sémantique** : bouton, `selected` (vrai ou faux, état toujours exposé), libellé = `label`, action de toucher ; pas d'état activé/désactivé.
- **Zone tactile** : si l'appelant impose une hauteur stricte d'au moins `minTapHeight`, la zone prend cette hauteur et la pastille mesure `visibleHeight`, centrée ; sinon la puce garde sa taille d'origine (hauteur de son contenu ou de la contrainte imposée).
- **Aspect** : pastille arrondie (rayon 10), sélectionnée = fond `accentSoft`, bordure et texte `accent` ; sinon bordure `border`, texte `textSecondary`.

### Règle d'usage pour agrandir la zone tactile d'un appelant

```dart
SizedBox(
  height: AppFilterChip.minTapHeight,
  child: AppFilterChip(label: label, selected: selected, onTap: onTap),
)
```

## Conteneurs qui appliquent la règle

| Conteneur | Fichier | Effet |
|-----------|---------|-------|
| `LaneFilterBar` | `lib/shared/widgets/lane_filter_bar/lane_filter_bar.dart` | chaque puce dans une hauteur de `minTapHeight`, `runSpacing: 0` |
| Rangée de rôles de `ChampionPickerSheet` | `lib/shared/widgets/champion_picker_sheet/champion_picker_sheet.dart` | rangée de 44 px, sans marge verticale |

## Appelants qui ne l'appliquent pas encore

Région, objets, carte, quiz, régions : hauteurs de 30 à 34 px conservées (voir `spec.md`).

## Titres sémantiques

Les titres suivants sont enveloppés par `Semantics(header: true)` : VERDICT, POURQUOI, BANNISSEMENTS, CE QUI VA BIEN, À AMÉLIORER (`lib/draft/widgets/draft_report_view/draft_report_view.dart`), SUGGESTIONS (`lib/draft/draft_page.dart`), « Affichage » (`lib/theme/widgets/theme_mode_sheet/theme_mode_sheet.dart`).
