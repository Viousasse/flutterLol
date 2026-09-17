import 'dart:math';

import '../../champions/models/champion.dart';
import '../../items/models/item.dart';
import '../../matchups/models/matchup.dart';
import '../../matchups/services/matchup_service.dart';
import '../../regions/constants/champion_regions.dart';
import '../../regions/constants/lore_regions.dart';
import '../../regions/models/lore_region.dart';
import '../models/quiz_question.dart';

/// Les données dont les questions sont tirées. Tout vient de ce que l'app
/// charge déjà : aucune requête n'est faite pour le quiz.
class QuizData {
  final List<Champion> champions;
  final List<Item> items;
  final MatchupDataset matchups;

  const QuizData({
    required this.champions,
    required this.items,
    required this.matchups,
  });
}

/// Fabrique des questions de quiz à partir des données du jeu.
///
/// Chaque famille est un générateur indépendant qui rend `null` quand les
/// données ne permettent pas de poser une question honnête — trop peu de
/// champions dans une région, pas assez de parties pour un matchup. Le tirage
/// enchaîne alors sur un autre générateur plutôt que d'inventer.
class QuizGenerator {
  final QuizData data;
  final Random _random;

  QuizGenerator(this.data, {int? seed}) : _random = Random(seed);

  /// Nombre de propositions par question.
  static const optionCount = 4;

  /// Une question tirée au hasard, éventuellement restreinte à une famille.
  ///
  /// Rend `null` si aucun générateur n'aboutit — un jeu de données vide, par
  /// exemple.
  QuizQuestion? next({QuizCategory? category, QuizQuestion? avoid}) {
    final builders = _buildersFor(category)..shuffle(_random);

    for (final builder in builders) {
      for (var attempt = 0; attempt < 8; attempt++) {
        final question = builder();
        if (question == null) continue;
        if (question.prompt == avoid?.prompt) continue;

        return question;
      }
    }

    return null;
  }

  List<QuizQuestion? Function()> _buildersFor(QuizCategory? category) {
    final byCategory = {
      QuizCategory.champions: <QuizQuestion? Function()>[
        _championFromIcon,
        _championFromTitle,
        _titleOfChampion,
        _roleOfChampion,
        _championFromLore,
      ],
      QuizCategory.regions: <QuizQuestion? Function()>[
        _regionOfChampion,
        _championFromRegion,
      ],
      QuizCategory.items: <QuizQuestion? Function()>[
        _itemFromIcon,
        _priceOfItem,
        _mostExpensiveItem,
        _itemFromComponents,
      ],
      QuizCategory.matchups: <QuizQuestion? Function()>[_bestMatchup],
    };

    if (category != null) return [...byCategory[category]!];

    return byCategory.values.expand((builders) => builders).toList();
  }

  // --- Champions ---

  QuizQuestion? _championFromIcon() {
    final picked = _pickChampions(optionCount);
    if (picked == null) return null;

    return _question(
      category: QuizCategory.champions,
      prompt: 'Quel champion est-ce ?',
      imageUrl: picked.first.imageUrl,
      options: picked.map((c) => QuizOptionData(c.name)).toList(),
    );
  }

  QuizQuestion? _championFromTitle() {
    final picked = _pickChampions(
      optionCount,
      where: (c) => c.title.isNotEmpty,
    );
    if (picked == null) return null;

    return _question(
      category: QuizCategory.champions,
      prompt: 'Qui est « ${picked.first.title} » ?',
      options: picked.map((c) => QuizOptionData(c.name)).toList(),
    );
  }

  QuizQuestion? _titleOfChampion() {
    final picked = _pickChampions(
      optionCount,
      where: (c) => c.title.isNotEmpty,
    );
    if (picked == null) return null;
    if (picked.map((c) => c.title).toSet().length != optionCount) return null;

    return _question(
      category: QuizCategory.champions,
      prompt: 'Quel est le titre de ${picked.first.name} ?',
      imageUrl: picked.first.imageUrl,
      options: picked.map((c) => QuizOptionData(c.title)).toList(),
    );
  }

  QuizQuestion? _roleOfChampion() {
    final champion = _pickOne(data.champions, where: (c) => c.tags.isNotEmpty);
    if (champion == null) return null;

    final role = champion.tags.first;
    final otherRoles =
        _allRoles.where((r) => !champion.tags.contains(r)).toList()
          ..shuffle(_random);
    if (otherRoles.length < optionCount - 1) return null;

    return _question(
      category: QuizCategory.champions,
      prompt: 'Quel est le rôle principal de ${champion.name} ?',
      imageUrl: champion.imageUrl,
      options: [
        QuizOptionData(role),
        ...otherRoles.take(optionCount - 1).map(QuizOptionData.new),
      ],
    );
  }

  /// L'extrait de biographie sert d'énoncé, le nom du champion masqué : sans
  /// ça la réponse serait écrite dans la question.
  QuizQuestion? _championFromLore() {
    final picked = _pickChampions(
      optionCount,
      where: (c) => c.blurb.length > 80,
    );
    if (picked == null) return null;

    final champion = picked.first;
    final excerpt = _redactName(_firstSentences(champion.blurb), champion.name);
    if (excerpt.length < 60) return null;

    return _question(
      category: QuizCategory.champions,
      prompt: 'De quel champion parle ce texte ?\n\n« $excerpt »',
      options: picked.map((c) => QuizOptionData(c.name)).toList(),
    );
  }

  // --- Régions ---

  QuizQuestion? _regionOfChampion() {
    final champion = _pickOne(
      data.champions,
      where: (c) => championRegions.containsKey(c.id),
    );
    if (champion == null) return null;

    final regionId = championRegions[champion.id]!;
    final region = regionsById[regionId];
    if (region == null) return null;

    final others =
        loreRegions
            .where((r) => r.id != regionId && r.id != RegionId.unknown)
            .toList()
          ..shuffle(_random);
    if (others.length < optionCount - 1) return null;

    return _question(
      category: QuizCategory.regions,
      prompt: 'De quelle région vient ${champion.name} ?',
      imageUrl: champion.imageUrl,
      options: [
        QuizOptionData(region.name),
        ...others.take(optionCount - 1).map((r) => QuizOptionData(r.name)),
      ],
      explanation: 'Région officielle : ${region.name}.',
    );
  }

  QuizQuestion? _championFromRegion() {
    final placed =
        loreRegions
            .where(
              (r) => r.id != RegionId.unknown && r.id != RegionId.runeterra,
            )
            .toList()
          ..shuffle(_random);

    for (final region in placed) {
      final fromRegion = data.champions
          .where((c) => championRegions[c.id] == region.id)
          .toList();
      final elsewhere = data.champions
          .where(
            (c) =>
                championRegions.containsKey(c.id) &&
                championRegions[c.id] != region.id,
          )
          .toList();
      if (fromRegion.isEmpty || elsewhere.length < optionCount - 1) continue;

      fromRegion.shuffle(_random);
      elsewhere.shuffle(_random);

      return _question(
        category: QuizCategory.regions,
        prompt: 'Lequel de ces champions vient de ${region.name} ?',
        options: [
          QuizOptionData(
            fromRegion.first.name,
            imageUrl: fromRegion.first.imageUrl,
          ),
          ...elsewhere
              .take(optionCount - 1)
              .map((c) => QuizOptionData(c.name, imageUrl: c.imageUrl)),
        ],
      );
    }

    return null;
  }

  // --- Objets ---

  QuizQuestion? _itemFromIcon() {
    final picked = _pickItems(optionCount);
    if (picked == null) return null;

    return _question(
      category: QuizCategory.items,
      prompt: 'Quel objet est-ce ?',
      imageUrl: picked.first.imageUrl,
      options: picked.map((i) => QuizOptionData(i.name)).toList(),
    );
  }

  QuizQuestion? _priceOfItem() {
    final item = _pickOne(data.items, where: (i) => i.gold > 0);
    if (item == null) return null;

    final prices = <int>{item.gold};
    for (
      var attempt = 0;
      attempt < 40 && prices.length < optionCount;
      attempt++
    ) {
      final other = _pickOne(data.items, where: (i) => i.gold > 0);
      if (other != null) prices.add(other.gold);
    }
    if (prices.length < optionCount) return null;

    return _question(
      category: QuizCategory.items,
      prompt: 'Combien coûte ${item.name} ?',
      imageUrl: item.imageUrl,
      options: [
        QuizOptionData('${item.gold} po'),
        ...prices
            .where((p) => p != item.gold)
            .map((p) => QuizOptionData('$p po')),
      ],
    );
  }

  QuizQuestion? _mostExpensiveItem() {
    final picked = _pickItems(optionCount, where: (i) => i.gold > 0);
    if (picked == null) return null;

    final sorted = [...picked]..sort((a, b) => b.gold.compareTo(a.gold));
    // Sans écart net, deux réponses seraient défendables.
    if (sorted[0].gold - sorted[1].gold < 150) return null;

    return _question(
      category: QuizCategory.items,
      prompt: 'Lequel de ces objets est le plus cher ?',
      options: [
        QuizOptionData(sorted.first.name, imageUrl: sorted.first.imageUrl),
        ...sorted
            .skip(1)
            .map((i) => QuizOptionData(i.name, imageUrl: i.imageUrl)),
      ],
      explanation: '${sorted.first.name} coûte ${sorted.first.gold} po.',
    );
  }

  QuizQuestion? _itemFromComponents() {
    final item = _pickOne(data.items, where: (i) => i.componentIds.length >= 2);
    if (item == null) return null;

    final components = item.componentIds
        .map((id) => data.items.where((i) => i.id == id).firstOrNull)
        .whereType<Item>()
        .toList();
    if (components.length < 2) return null;

    final others = data.items.where((i) => i.id != item.id).toList()
      ..shuffle(_random);
    if (others.length < optionCount - 1) return null;

    final names = components.take(2).map((c) => c.name).join(' + ');

    return _question(
      category: QuizCategory.items,
      prompt: 'Quel objet se fabrique avec $names ?',
      options: [
        QuizOptionData(item.name, imageUrl: item.imageUrl),
        ...others
            .take(optionCount - 1)
            .map((i) => QuizOptionData(i.name, imageUrl: i.imageUrl)),
      ],
    );
  }

  // --- Matchups ---

  /// Demande contre qui un champion s'en sort le mieux, d'après les parties
  /// réellement comptées. On exige un écart net avec le deuxième, sinon la
  /// question tiendrait du tirage au sort.
  QuizQuestion? _bestMatchup() {
    if (data.matchups.isEmpty) return null;

    final championIds =
        data.matchups.matchups.map((m) => m.championId).toSet().toList()
          ..shuffle(_random);

    for (final championId in championIds) {
      final ranked = MatchupService.easiestFor(championId, data.matchups);
      if (ranked.length < optionCount) continue;
      if (ranked[0].winRate - ranked[1].winRate < 0.12) continue;

      final champion = data.champions
          .where((c) => c.id == championId)
          .firstOrNull;
      if (champion == null) continue;

      final opponents = ranked.take(optionCount).toList();
      final best = opponents.first;

      return _question(
        category: QuizCategory.matchups,
        prompt: 'Contre lequel ${champion.name} gagne-t-il le plus souvent ?',
        imageUrl: champion.imageUrl,
        options: opponents
            .map((m) => QuizOptionData(_nameOf(m.opponentId)))
            .toList(),
        explanation:
            '${(best.winRate * 100).round()} % de victoires sur '
            '${best.games} parties classées Master+.',
      );
    }

    return null;
  }

  String _nameOf(String championId) {
    return data.champions.where((c) => c.id == championId).firstOrNull?.name ??
        championId;
  }

  // --- Fabrication commune ---

  /// Mélange les propositions en gardant la trace de la bonne, qui est toujours
  /// la première fournie par les générateurs.
  QuizQuestion _question({
    required QuizCategory category,
    required String prompt,
    required List<QuizOptionData> options,
    String? imageUrl,
    String? explanation,
  }) {
    final answer = options.first;
    final shuffled = [...options]..shuffle(_random);

    return QuizQuestion(
      category: category,
      prompt: prompt,
      imageUrl: imageUrl,
      options: shuffled,
      answerIndex: shuffled.indexOf(answer),
      explanation: explanation,
    );
  }

  /// [count] champions distincts, le premier étant la réponse.
  List<Champion>? _pickChampions(int count, {bool Function(Champion)? where}) {
    final pool = data.champions.where(where ?? (_) => true).toList();
    if (pool.length < count) return null;

    pool.shuffle(_random);
    final picked = pool.take(count).toList();
    if (picked.map((c) => c.name).toSet().length != count) return null;

    return picked;
  }

  List<Item>? _pickItems(int count, {bool Function(Item)? where}) {
    final pool = data.items.where(where ?? (_) => true).toList();
    if (pool.length < count) return null;

    pool.shuffle(_random);
    final picked = pool.take(count).toList();
    if (picked.map((i) => i.name).toSet().length != count) return null;

    return picked;
  }

  T? _pickOne<T>(List<T> pool, {required bool Function(T) where}) {
    final matching = pool.where(where).toList();
    if (matching.isEmpty) return null;

    return matching[_random.nextInt(matching.length)];
  }

  static const _allRoles = [
    'Fighter',
    'Tank',
    'Mage',
    'Assassin',
    'Marksman',
    'Support',
  ];

  static String _firstSentences(String text) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final excerpt = sentences.take(2).join(' ').trim();

    return excerpt.length > 260 ? '${excerpt.substring(0, 257)}…' : excerpt;
  }

  /// Remplace le nom du champion par des points de suspension.
  ///
  /// Le nom complet est toujours masqué, quelle que soit sa longueur — Zoe et
  /// Zed autant qu'Aurelion Sol — et les mots qui le composent le sont aussi
  /// au-delà de trois lettres, pour « Sol » dans « Aurelion Sol ».
  ///
  /// Le masquage porte sur des mots entiers : sans ça, effacer « Vi »
  /// mutilerait « vieux » ou « vivre ».
  static String _redactName(String text, String name) {
    final words = <String>{
      name,
      ...name.split(RegExp(r"[\s'’&-]")).where((word) => word.length > 3),
    }.toList()..sort((a, b) => b.length.compareTo(a.length));

    var redacted = text;
    for (final word in words) {
      redacted = redacted.replaceAll(
        RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false),
        '…',
      );
    }

    return redacted.replaceAll(RegExp(r'…( ?…)+'), '…').trim();
  }
}
