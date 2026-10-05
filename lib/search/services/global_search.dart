import '../../champions/models/champion.dart';
import '../../items/models/item.dart';
import '../../shared/text/search_text.dart';

class SearchResults {
  final List<Champion> champions;
  final List<Item> items;

  const SearchResults({required this.champions, required this.items});

  const SearchResults.empty() : this(champions: const [], items: const []);

  bool get isEmpty => champions.isEmpty && items.isEmpty;
}

/// Recherche unique dans les champions et les objets.
class GlobalSearch {
  /// Au-delà, la liste devient une page à défiler plutôt qu'un résultat : mieux
  /// vaut inviter à préciser la recherche.
  static const maxPerSection = 8;

  static SearchResults run(
    String query, {
    required List<Champion> champions,
    required List<Item> items,
  }) {
    final normalizedQuery = normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return const SearchResults.empty();

    return SearchResults(
      champions: _rank(champions, normalizedQuery, (c) => c.name),
      items: _rank(items, normalizedQuery, (i) => i.name),
    );
  }

  /// Les noms qui commencent par la recherche passent avant ceux qui la
  /// contiennent seulement : « ah » doit proposer Ahri avant Shaco.
  static List<T> _rank<T>(
    List<T> candidates,
    String normalizedQuery,
    String Function(T) nameOf,
  ) {
    final prefix = <T>[];
    final inside = <T>[];

    for (final candidate in candidates) {
      final name = normalizeSearchText(nameOf(candidate));

      if (name.startsWith(normalizedQuery)) {
        prefix.add(candidate);
      } else if (name.contains(normalizedQuery)) {
        inside.add(candidate);
      }
    }

    return [...prefix, ...inside].take(maxPerSection).toList();
  }
}
