# Contrat : écrans et boîte de collage

## `PasteCodeDialog` (`lib/shared/widgets/paste_code_dialog/paste_code_dialog.dart`)

```dart
static Future<T?> PasteCodeDialog.show<T>(
  BuildContext context, {
  required String title,
  required String hint,
  required T? Function(String text) parse,
  required String invalidMessage,
});
```

- Renvoie ce que `parse` a lu, ou `null` si l'utilisateur annule.
- Si `parse` renvoie `null`, la boîte reste ouverte et affiche `invalidMessage` ; l'erreur disparaît à la frappe suivante.
- Boutons « Coller » (lit le presse-papiers texte, ignore l'indisponibilité) et « Annuler ».
- Générique : sert à l'import de builds et à celui des drafts.
- Tests : `test/shared/widgets/paste_code_dialog_test.dart`.

## `BuildsPage` (`lib/builds/builds_page.dart`)

```dart
const BuildsPage({super.key,
  Future<List<Item>> Function() loadItems = ItemService.fetchAll,
  Future<List<Champion>> Function() loadChampions = ChampionService.fetchAll});
```

Les deux sources sont injectables pour les tests. Points d'entrée : `ToolsSection` (« Mes builds ») et `BuildsButton` (onglet Objets). Action de la barre : « Importer une build ».

## `BuildEditorPage` (`lib/builds/build_editor_page.dart`)

```dart
const BuildEditorPage({super.key, Build? build,
  String? initialChampionId, List<String> initialItemIds = const []});
```

`build` non nul : modification (même identifiant à l'enregistrement). Sinon création, éventuellement préremplie (`initialChampionId`, `initialItemIds`, tronquée à six) ; appelée depuis la fiche d'un champion (`lib/champion_detail/champion_detail_page.dart`). Charge objets et champions via `ItemService`/`ChampionService` (non injectables) et le profil de voies via `RoleFilters.loadProfile()` pour le filtre de rôle (`RoleFilters.forProfile`, absent si les données sont indisponibles).
