# Contrat : apparences d'un champion

## `ChampionSkin` — `lib/champions/models/champion_skin.dart`

```dart
class ChampionSkin {
  static const defaultName = 'Apparence classique';
  final String championId;
  final int number;            // 0 pour l'origine
  final String name;
  const ChampionSkin({required this.championId, required this.number, required this.name});

  String get splashUrl;        // grande illustration horizontale
  String get loadingUrl;       // illustration verticale légère

  /// Ignore les entrées avec `parentSkin` ; liste vide si [rawSkins] n'est pas une liste.
  static List<ChampionSkin> listFromJson(String championId, dynamic rawSkins);
}
```

Consommé par `ChampionDetail.fromJson` (champ `skins`).

## `SkinGallery` — `lib/champion_detail/widgets/skin_gallery/skin_gallery.dart`

```dart
const SkinGallery({super.key, required List<ChampionSkin> skins});
```

Rangée horizontale de vignettes (120 × 190) ; un appui pousse `SkinViewerPage(skins: skins, initialIndex: index)`.

## `SkinViewerPage` — `lib/champion_detail/skin_viewer_page.dart`

```dart
const SkinViewerPage({super.key, required List<ChampionSkin> skins, required int initialIndex});
```

Plein écran noir ; `PageView` + `InteractiveViewer(maxScale: 4)` ; infobulles « Apparence précédente » / « Apparence suivante ».

## Entrée de données attendue (extrait de la fiche Data Dragon)

```json
"skins": [
  { "id": "103000", "num": 0, "name": "default", "chromas": false },
  { "id": "103008", "num": 8, "name": "Ahri popstar (améthyste)", "parentSkin": 4 }
]
```
