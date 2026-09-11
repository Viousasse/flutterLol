/// Le profil de champion auquel un objet se destine.
///
/// Un objet n'en porte qu'un seul : contrairement aux tags de Riot, qui se
/// chevauchent, ce classement partitionne la boutique.
enum ItemProfile { attackDamage, abilityPower, tank, support, other }

const profileLabels = {
  ItemProfile.attackDamage: 'AD',
  ItemProfile.abilityPower: 'AP',
  ItemProfile.tank: 'Tank',
  ItemProfile.support: 'Support',
  ItemProfile.other: 'Autres',
};

/// Déduit le profil d'un objet de ses statistiques, puis de ses tags quand le
/// bloc `stats` est vide — c'est le cas des composants dont l'effet est passif.
ItemProfile resolveItemProfile(
  List<String> tags,
  Map<String, dynamic> stats,
) {
  if (_isEnchanter(tags)) return ItemProfile.support;

  final attackDamage = _stat(stats, 'FlatPhysicalDamageMod');
  final abilityPower = _stat(stats, 'FlatMagicDamageMod');

  if (attackDamage > 0 || abilityPower > 0) {
    return attackDamage >= abilityPower
        ? ItemProfile.attackDamage
        : ItemProfile.abilityPower;
  }

  if (_hasOffensiveStat(stats)) return ItemProfile.attackDamage;
  if (_hasDefensiveStat(stats)) return ItemProfile.tank;
  if (_stat(stats, 'FlatMPPoolMod') > 0) return ItemProfile.abilityPower;

  return _resolveFromTags(tags);
}

/// Les objets d'enchanteur régénèrent le mana sans réserve de mana ni dégâts
/// d'attaque, et les objets de quête de support portent le tag `GoldPer`.
bool _isEnchanter(List<String> tags) {
  if (tags.contains('GoldPer')) return true;
  if (!tags.contains('ManaRegen')) return false;
  if (tags.contains('Mana')) return false;

  return !tags.contains('Damage') && !tags.contains('CriticalStrike');
}

bool _hasOffensiveStat(Map<String, dynamic> stats) {
  if (_stat(stats, 'FlatCritChanceMod') > 0) return true;
  if (_stat(stats, 'PercentAttackSpeedMod') > 0) return true;

  return _stat(stats, 'PercentLifeStealMod') > 0;
}

bool _hasDefensiveStat(Map<String, dynamic> stats) {
  if (_stat(stats, 'FlatHPPoolMod') > 0) return true;
  if (_stat(stats, 'FlatArmorMod') > 0) return true;

  return _stat(stats, 'FlatSpellBlockMod') > 0;
}

ItemProfile _resolveFromTags(List<String> tags) {
  if (tags.contains('SpellDamage')) return ItemProfile.abilityPower;
  if (tags.contains('MagicPenetration')) return ItemProfile.abilityPower;
  if (tags.contains('Damage')) return ItemProfile.attackDamage;
  if (tags.contains('ArmorPenetration')) return ItemProfile.attackDamage;
  if (tags.contains('OnHit')) return ItemProfile.attackDamage;
  if (tags.contains('Health')) return ItemProfile.tank;
  if (tags.contains('HealthRegen')) return ItemProfile.tank;
  if (tags.contains('Armor')) return ItemProfile.tank;
  if (tags.contains('SpellBlock')) return ItemProfile.tank;

  return ItemProfile.other;
}

double _stat(Map<String, dynamic> stats, String key) {
  final value = stats[key];
  if (value is num) return value.toDouble();

  return 0;
}
