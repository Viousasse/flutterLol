/// Un plan de runes générique : un arbre principal (avec sa rune majeure et
/// quelques runes mineures) et un arbre secondaire (deux runes mineures).
///
/// Data Dragon n'expose plus la moindre suggestion de runes ou d'objets par
/// champion (Riot a retiré ce bloc de son API il y a plusieurs années) : ces
/// plans sont donc rédigés à la main, par rôle plutôt que par champion, à
/// partir des choix les plus répandus pour ce type de profil.
class RunePlan {
  final String primaryTreeKey;
  final String keystoneKey;
  final List<String> primaryRuneKeys;
  final String secondaryTreeKey;
  final List<String> secondaryRuneKeys;

  const RunePlan({
    required this.primaryTreeKey,
    required this.keystoneKey,
    required this.primaryRuneKeys,
    required this.secondaryTreeKey,
    required this.secondaryRuneKeys,
  });
}

class RoleRecommendation {
  final RunePlan runes;
  final List<String> itemIds;

  const RoleRecommendation({required this.runes, required this.itemIds});
}

/// Recommandations génériques indexées par tag de rôle Data Dragon (le même
/// vocabulaire que `Champion.tags` : Fighter, Tank, Mage, Assassin, Support,
/// Marksman). Un champion multi-tags (ex. Vi = Fighter, Assassin) reçoit la
/// recommandation de son premier tag, celui que Riot considère dominant.
class RoleRecommendations {
  static const _fighter = RoleRecommendation(
    runes: RunePlan(
      primaryTreeKey: 'Precision',
      keystoneKey: 'Conqueror',
      primaryRuneKeys: ['Triumph', 'LegendBloodline', 'LastStand'],
      secondaryTreeKey: 'Resolve',
      secondaryRuneKeys: ['Conditioning', 'Overgrowth'],
    ),
    itemIds: ['3078', '3053', '6333', '3071'],
  );

  static const _tank = RoleRecommendation(
    runes: RunePlan(
      primaryTreeKey: 'Resolve',
      keystoneKey: 'GraspOfTheUndying',
      primaryRuneKeys: ['Demolish', 'Conditioning', 'Overgrowth'],
      secondaryTreeKey: 'Precision',
      secondaryRuneKeys: ['CutDown', 'Triumph'],
    ),
    itemIds: ['3068', '3075', '4401', '3110'],
  );

  static const _mage = RoleRecommendation(
    runes: RunePlan(
      primaryTreeKey: 'Sorcery',
      keystoneKey: 'ArcaneComet',
      primaryRuneKeys: ['ManaflowBand', 'Transcendence', 'Scorch'],
      secondaryTreeKey: 'Domination',
      secondaryRuneKeys: ['SuddenImpact', 'GrislyMementos'],
    ),
    itemIds: ['3089', '3157', '3135', '3100'],
  );

  static const _assassin = RoleRecommendation(
    runes: RunePlan(
      primaryTreeKey: 'Domination',
      keystoneKey: 'Electrocute',
      primaryRuneKeys: ['CheapShot', 'GrislyMementos', 'RelentlessHunter'],
      secondaryTreeKey: 'Precision',
      secondaryRuneKeys: ['CoupDeGrace', 'LastStand'],
    ),
    itemIds: ['6691', '3142', '3814', '3071'],
  );

  static const _support = RoleRecommendation(
    runes: RunePlan(
      primaryTreeKey: 'Sorcery',
      keystoneKey: 'SummonAery',
      primaryRuneKeys: ['NimbusCloak', 'Transcendence', 'Waterwalking'],
      secondaryTreeKey: 'Resolve',
      secondaryRuneKeys: ['FontOfLife', 'Revitalize'],
    ),
    itemIds: ['3190', '3107', '6617'],
  );

  static const _marksman = RoleRecommendation(
    runes: RunePlan(
      primaryTreeKey: 'Precision',
      keystoneKey: 'LethalTempo',
      primaryRuneKeys: ['PresenceOfMind', 'LegendAlacrity', 'CoupDeGrace'],
      secondaryTreeKey: 'Domination',
      secondaryRuneKeys: ['TasteOfBlood', 'RelentlessHunter'],
    ),
    itemIds: ['6672', '3031', '3046', '3072'],
  );

  static const byTag = {
    'Fighter': _fighter,
    'Tank': _tank,
    'Mage': _mage,
    'Assassin': _assassin,
    'Support': _support,
    'Marksman': _marksman,
  };

  /// Retient le premier tag reconnu ; à défaut (tag inconnu ou champion sans
  /// tag), retombe sur le profil Fighter, le plus polyvalent.
  static RoleRecommendation forTags(List<String> tags) {
    for (final tag in tags) {
      final match = byTag[tag];
      if (match != null) return match;
    }
    return _fighter;
  }
}
