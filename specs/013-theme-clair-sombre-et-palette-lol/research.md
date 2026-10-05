# Research : Thème clair / sombre et palette du client LoL

## 1. Palette globale statique plutôt que `Theme.of(context)`

- **Decision**: `AppColors` lit une palette statique (`_palette`) changée par `AppColors.use(Brightness)`.
- **Rationale**: tous les widgets existants lisaient déjà `AppColors.xxx` comme constantes ; le premier commit (`15d9e51`) a seulement transformé ces lecteurs en `get` et retiré les `const` qui les entouraient (≈ 39 fichiers), sans réécrire les écrans.
- **Alternatives considered**: aucune alternative n'est documentée dans le code ou les commits.

## 2. Reconstruction forcée de tout l'arbre

- **Decision**: au changement de mode, `_MyAppState._applyBrightness` appelle `setState` puis parcourt tous les éléments avec `markNeedsBuild`.
- **Rationale**: commentaire de `lib/main.dart` : les couleurs sont lues à la construction de chaque widget et un widget `const` n'est pas reconstruit quand son parent l'est ; marquer l'arbre garde l'écran, la navigation et les saisies en place.
- **Alternatives considered**: non documentées.

## 3. Mode relu avant le premier rendu

- **Decision**: `ThemeService.ensureLoaded()` est attendu dans `main()` avec les favoris, avant `runApp`.
- **Rationale**: commentaire de `lib/main.dart` : sans cela, l'application s'ouvrirait un instant dans le mauvais mode.

## 4. Trois réglages dont « Automatique » par défaut

- **Decision**: le mode par défaut est `ThemeMode.system` ; `resolve(chosen, device)` renvoie la luminosité de l'appareil quand rien n'est choisi, et `MyApp` écoute `didChangePlatformBrightness`.
- **Rationale**: suivre l'appareil, y compris le mode sombre automatique du soir (commentaire de `didChangePlatformBrightness`). Testé par `theme_service_test.dart`.

## 5. Échec du stockage toléré

- **Decision**: `_load` et `setMode` capturent toute erreur de `SharedPreferences`.
- **Rationale**: commentaires du code : on suit l'appareil plutôt que de planter (et `_loading` est remis à `null` pour pouvoir retenter) ; le choix reste appliqué pour la session même s'il n'est pas gardé.

## 6. Contraste : seuil 4,5:1 et or assombri en mode clair

- **Decision**: opacités du texte secondaire (0,62 sombre, 0,74 clair) et discret (0,55 sombre, 0,64 clair) calibrées pour tenir 4,5:1 ; accent clair `#7A5C1E` plus foncé que l'accent sombre `#C8AA6E`.
- **Rationale**: commentaires de `app_colors.dart` (« l'or clair du mode sombre ne tiendrait pas le contraste 4,5:1 sur un fond clair ») ; vérifié par `contrast_test.dart` et `app_palette_test.dart`. Le contraste d'origine du texte discret (0,35) était d'environ 3:1 (commentaire).
- **Alternatives considered**: non documentées.

## 7. Couleurs du client LoL

- **Decision**: sombre `#010A13` / `#0A1428` / or `#C8AA6E` / parchemin `#F0E6D2` ; clair parchemin `#F3EEE2` / `#FBF8F1` / encre `#0A1428`.
- **Rationale**: demande de l'utilisateur (« mets les couleurs à l'image de LoL ») ; message du commit `bfc1352` : « Bleu nuit et or en mode sombre, parchemin en mode clair ». Les valeurs exactes du client ne sont citées nulle part : on ne sait pas si elles sont issues d'une charte officielle.

## 8. Teinte rosée en mode clair

- **Decision**: `surfaceTint: Colors.transparent` dans le `ColorScheme` et `surfaceTintColor: Colors.transparent` pour l'`AppBar` (`app_theme.dart`).
- **Rationale**: commentaire : sans cela Material mélange l'accent aux barres et feuilles qui défilent, d'où une teinte rosée sur fond clair (à l'époque de l'accent corail). Correctif livré dans `d260ea6`.

## 9. Fond de la feuille « Affichage » peint dans `build`

- **Decision**: `showModalBottomSheet(backgroundColor: Colors.transparent)` et un `Material(color: AppColors.surface)` dans `build`.
- **Rationale**: commentaire de `theme_mode_sheet.dart` : la feuille reste ouverte pendant le changement de mode ; une couleur donnée à l'ouverture resterait celle de l'ancien mode. Correctif du commit `bfc1352`.

## 10. Carte « Champion du jour » : palette sombre forcée

- **Decision**: `final _onPhoto = AppPalette.dark;` dans `champion_hero_card.dart`, dégradé 0,55 / 0,05 / 0,92 d'opacité.
- **Rationale**: commentaire : le texte est posé sur une photo ; en mode clair l'encre sombre disparaît dans l'image. Correctif du commit `b6c98aa`.
