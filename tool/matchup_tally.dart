/// Logique pure de l'outil de génération des matchups : bilans, vieillissement,
/// comparaison de patchs, fusion. Isolée du script pour pouvoir être testée sans
/// réseau ni clé Riot.
library;

/// Parties et victoires d'une paire de champions dans une voie.
class Tally {
  int games = 0;
  int wins = 0;

  Tally();

  Tally.of(this.games, this.wins);
}

/// Un patch « majeur.mineur » (ex. `16.19`) comparé numériquement : `16.9` est
/// antérieur à `16.10`, ce qu'un tri alphabétique ne dirait pas.
/// Renvoie `null` si le texte n'a pas cette forme.
(int, int)? parsePatch(String patch) {
  final match = RegExp(r'^\s*(\d+)\.(\d+)').firstMatch(patch);
  if (match == null) return null;

  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

/// Négatif si [a] précède [b], nul si égaux, positif sinon. Un patch illisible
/// est considéré comme le plus ancien.
int comparePatches(String a, String b) {
  final left = parsePatch(a);
  final right = parsePatch(b);
  if (left == null && right == null) return 0;
  if (left == null) return -1;
  if (right == null) return 1;
  if (left.$1 != right.$1) return left.$1.compareTo(right.$1);

  return left.$2.compareTo(right.$2);
}

/// Vrai si [patch] est strictement antérieur à [minPatch]. Un patch illisible
/// n'est jamais écarté : mieux vaut garder une partie que la perdre à tort.
bool isBeforePatch(String patch, String minPatch) {
  if (parsePatch(patch) == null) return false;

  return comparePatches(patch, minPatch) < 0;
}

/// Applique [factor] (entre 0 et 1) à un compte, arrondi à l'entier.
int decayCount(int count, double factor) => (count * factor).round();

/// Fait vieillir les bilans : `games` et `wins` sont multipliés par [factor] et
/// arrondis, `wins` ne dépasse jamais `games`, et une paire tombée à zéro partie
/// disparaît. Ne modifie pas [tally].
Map<String, Tally> decayTally(Map<String, Tally> tally, double factor) {
  final result = <String, Tally>{};
  for (final entry in tally.entries) {
    final games = decayCount(entry.value.games, factor);
    if (games <= 0) continue;
    final wins = decayCount(entry.value.wins, factor);
    result[entry.key] = Tally.of(games, wins > games ? games : wins);
  }

  return result;
}

/// Même vieillissement pour le décompte des parties par patch ; les patchs
/// tombés à zéro sont retirés.
Map<String, int> decayPatches(Map<String, int> patches, double factor) {
  final result = <String, int>{};
  for (final entry in patches.entries) {
    final count = decayCount(entry.value, factor);
    if (count > 0) result[entry.key] = count;
  }

  return result;
}

/// Additionne [source] dans [target].
void mergeTally(Map<String, Tally> target, Map<String, Tally> source) {
  for (final entry in source.entries) {
    final slot = target.putIfAbsent(entry.key, Tally.new);
    slot.games += entry.value.games;
    slot.wins += entry.value.wins;
  }
}

/// Additionne [source] dans [target], patch par patch.
void mergePatches(Map<String, int> target, Map<String, int> source) {
  for (final entry in source.entries) {
    target[entry.key] = (target[entry.key] ?? 0) + entry.value;
  }
}

/// Étiquette de patch d'un fichier : « 16.18 » et « 16.20 » donnent
/// « 16.18–16.20 » ; deux patchs identiques restent un seul patch. Accepte
/// aussi une plage déjà étiquetée (« 16.16–16.19 ») : on garde alors ses
/// extrémités les plus anciennes et les plus récentes.
String patchRange(String a, String b) {
  if (a == b) return a;

  final all = [..._endpoints(a), ..._endpoints(b)];
  final readable = all.where((p) => parsePatch(p) != null).toList();
  if (readable.isEmpty) return a;

  readable.sort(comparePatches);
  if (comparePatches(readable.first, readable.last) == 0) {
    return readable.first;
  }

  return '${readable.first}–${readable.last}';
}

List<String> _endpoints(String label) =>
    label.split(RegExp(r'[–-]')).map((part) => part.trim()).toList();
