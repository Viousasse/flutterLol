# Contrat : recherche, normalisation, filtre et tri

## `normalizeSearchText` — `lib/shared/text/search_text.dart`

```dart
String normalizeSearchText(String text);
```

Minuscules, accents français repliés (`àâä→a`, `éèêë→e`, `îï→i`, `ôö→o`, `ùûü→u`, `ç→c`, `œ→oe`), puis suppression des espaces, apostrophes (`'` et `’`), points et tirets. `"Cho'Gath"` et `"chogath"` donnent la même forme ; `""` reste `""`. Utilisée par `ChampionFilter`, `GlobalSearch` et `ItemPickerSheet`, ainsi que par la liste des objets (`lib/items/items_page.dart`).

## `GlobalSearch` — `lib/search/services/global_search.dart`

```dart
class SearchResults {
  final List<Champion> champions;
  final List<Item> items;
  const SearchResults({required this.champions, required this.items});
  const SearchResults.empty();
  bool get isEmpty;
}

class GlobalSearch {
  static const maxPerSection = 8;
  static SearchResults run(String query, {required List<Champion> champions, required List<Item> items});
}
```

Comportement : requête vide après normalisation → `SearchResults.empty()` ; les noms qui commencent par la requête passent avant ceux qui la contiennent ; au plus 8 par section ; l'ordre d'origine est conservé à l'intérieur de chaque groupe.

## `SearchPage` — `lib/search/search_page.dart`

`const SearchPage({super.key})`. Ouverte par `HomeGreeting(onSearch: …)` dans `lib/home/home_page.dart`. Un résultat champion ouvre `ChampionDetailPage(championId: …)` ; un résultat objet ouvre `ItemDetailSheet.show(context, item)`.

## `ChampionFilter` — `lib/champions/services/champion_filter.dart`

```dart
class ChampionFilter {
  static List<Champion> apply(
    List<Champion> champions, {
    String query = '',
    String? role,                       // doit figurer dans champion.tags
    RegionId? region,                   // via championRegions[champion.id]
    ChampionSort sort = ChampionSort.name,
    Map<String, double> winRates = const {},
  });
}
```

Renvoie une nouvelle liste (l'entrée n'est pas modifiée). Tri : `name` alphabétique ; `difficultyAsc`/`difficultyDesc` avec départage alphabétique ; `winRate` décroissant, les champions absents de `winRates` à la fin (alphabétique entre eux).

## `ChampionSort` — `lib/champions/models/champion_sort.dart`

```dart
enum ChampionSort { name, difficultyAsc, difficultyDesc, winRate }
```

## `ExpandableText` — `lib/shared/widgets/expandable_text/expandable_text.dart`

```dart
const ExpandableText({super.key, required String text, required TextStyle style, int collapsedLines = 5});
```

Replie le texte sur `collapsedLines` lignes avec un lien pour le déplier ; aucun lien si le texte tient dans les lignes autorisées.
