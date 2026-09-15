import 'role_recommendation.dart';

/// Recommandations rédigées par champion plutôt que par rôle : mêmes runes
/// et objets qu'un joueur expérimenté choisirait couramment pour ce
/// champion précis, sur la base de builds établis de longue date.
///
/// Beaucoup de champions d'un même profil partagent légitimement le même
/// plan de runes (les gabarits `_conquerorResolve`, `_electrocuteAssassin`,
/// etc. ci-dessous) : ce n'est pas une simplification, c'est le reflet de
/// choix de meta réellement communs à toute une famille de champions.
///
/// Un champion absent de [_byChampionId] (sorti trop récemment pour que ses
/// builds soient établis, ou pour lequel aucune donnée fiable n'a été
/// rédigée) retombe automatiquement sur [RoleRecommendations.forTags] via
/// [forChampion].
class ChampionRecommendations {
  // --- Gabarits de runes, chacun réutilisé par plusieurs champions ---

  static const _conquerorResolve = RunePlan(
    primaryTreeKey: 'Precision',
    keystoneKey: 'Conqueror',
    primaryRuneKeys: ['Triumph', 'LegendBloodline', 'LastStand'],
    secondaryTreeKey: 'Resolve',
    secondaryRuneKeys: ['Conditioning', 'Overgrowth'],
  );

  static const _conquerorDomination = RunePlan(
    primaryTreeKey: 'Precision',
    keystoneKey: 'Conqueror',
    primaryRuneKeys: ['Triumph', 'LegendAlacrity', 'CoupDeGrace'],
    secondaryTreeKey: 'Domination',
    secondaryRuneKeys: ['SuddenImpact', 'RelentlessHunter'],
  );

  static const _electrocuteAssassin = RunePlan(
    primaryTreeKey: 'Domination',
    keystoneKey: 'Electrocute',
    primaryRuneKeys: ['CheapShot', 'GrislyMementos', 'RelentlessHunter'],
    secondaryTreeKey: 'Precision',
    secondaryRuneKeys: ['CoupDeGrace', 'LastStand'],
  );

  static const _hailOfBladesAssassin = RunePlan(
    primaryTreeKey: 'Domination',
    keystoneKey: 'HailOfBlades',
    primaryRuneKeys: ['CheapShot', 'GrislyMementos', 'RelentlessHunter'],
    secondaryTreeKey: 'Precision',
    secondaryRuneKeys: ['CoupDeGrace', 'LastStand'],
  );

  static const _darkHarvestMage = RunePlan(
    primaryTreeKey: 'Domination',
    keystoneKey: 'DarkHarvest',
    primaryRuneKeys: ['CheapShot', 'GrislyMementos', 'RelentlessHunter'],
    secondaryTreeKey: 'Sorcery',
    secondaryRuneKeys: ['ManaflowBand', 'Scorch'],
  );

  static const _arcaneCometMage = RunePlan(
    primaryTreeKey: 'Sorcery',
    keystoneKey: 'ArcaneComet',
    primaryRuneKeys: ['ManaflowBand', 'Transcendence', 'Scorch'],
    secondaryTreeKey: 'Domination',
    secondaryRuneKeys: ['SuddenImpact', 'GrislyMementos'],
  );

  static const _summonAeryEnchanter = RunePlan(
    primaryTreeKey: 'Sorcery',
    keystoneKey: 'SummonAery',
    primaryRuneKeys: ['NimbusCloak', 'Transcendence', 'Waterwalking'],
    secondaryTreeKey: 'Resolve',
    secondaryRuneKeys: ['FontOfLife', 'Revitalize'],
  );

  static const _summonAeryPoke = RunePlan(
    primaryTreeKey: 'Sorcery',
    keystoneKey: 'SummonAery',
    primaryRuneKeys: ['NullifyingOrb', 'Transcendence', 'Scorch'],
    secondaryTreeKey: 'Resolve',
    secondaryRuneKeys: ['Demolish', 'Conditioning'],
  );

  static const _phaseRushMage = RunePlan(
    primaryTreeKey: 'Sorcery',
    keystoneKey: 'PhaseRush',
    primaryRuneKeys: ['NimbusCloak', 'Transcendence', 'GatheringStorm'],
    secondaryTreeKey: 'Resolve',
    secondaryRuneKeys: ['SecondWind', 'Overgrowth'],
  );

  static const _lethalTempoADC = RunePlan(
    primaryTreeKey: 'Precision',
    keystoneKey: 'LethalTempo',
    primaryRuneKeys: ['PresenceOfMind', 'LegendAlacrity', 'CoupDeGrace'],
    secondaryTreeKey: 'Domination',
    secondaryRuneKeys: ['TasteOfBlood', 'RelentlessHunter'],
  );

  static const _fleetFootworkADC = RunePlan(
    primaryTreeKey: 'Precision',
    keystoneKey: 'FleetFootwork',
    primaryRuneKeys: ['Triumph', 'LegendAlacrity', 'CoupDeGrace'],
    secondaryTreeKey: 'Domination',
    secondaryRuneKeys: ['TasteOfBlood', 'RelentlessHunter'],
  );

  static const _pressTheAttackDuelist = RunePlan(
    primaryTreeKey: 'Precision',
    keystoneKey: 'PressTheAttack',
    primaryRuneKeys: ['Triumph', 'LegendAlacrity', 'CoupDeGrace'],
    secondaryTreeKey: 'Domination',
    secondaryRuneKeys: ['SuddenImpact', 'RelentlessHunter'],
  );

  static const _graspBruiser = RunePlan(
    primaryTreeKey: 'Resolve',
    keystoneKey: 'GraspOfTheUndying',
    primaryRuneKeys: ['Demolish', 'Conditioning', 'Overgrowth'],
    secondaryTreeKey: 'Precision',
    secondaryRuneKeys: ['CutDown', 'Triumph'],
  );

  static const _aftershockEngageTank = RunePlan(
    primaryTreeKey: 'Resolve',
    keystoneKey: 'Aftershock',
    primaryRuneKeys: ['Demolish', 'Conditioning', 'Overgrowth'],
    secondaryTreeKey: 'Precision',
    secondaryRuneKeys: ['CutDown', 'Triumph'],
  );

  static const _guardianEngageSupport = RunePlan(
    primaryTreeKey: 'Resolve',
    keystoneKey: 'Guardian',
    primaryRuneKeys: ['FontOfLife', 'Conditioning', 'Revitalize'],
    secondaryTreeKey: 'Domination',
    secondaryRuneKeys: ['CheapShot', 'RelentlessHunter'],
  );

  // --- Objets couramment utilisés, regroupés pour lisibilité ---
  // Marksman
  static const _krakenCore = ['6672', '3031', '3046', '3072'];
  // AP burst / mage
  static const _apBurstCore = ['3157', '4645', '3135', '3089'];
  static const _apPokeCore = ['3157', '3089', '3135', '4645'];
  // Bruiser AD
  static const _bruiserCore = ['3078', '3053', '6333', '3071'];
  // Lethality AD
  static const _lethalityCore = ['6691', '3142', '3814', '3071'];
  // Tank engage
  static const _tankCore = ['3068', '3110', '4401', '3075'];

  static const Map<String, RoleRecommendation> _byChampionId = {
    'Aatrox': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Ahri': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '4645']),
    'Akali': RoleRecommendation(runes: _electrocuteAssassin, itemIds: ['3157', '4645', '3135', '3089']),
    'Akshan': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Alistar': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Ambessa': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Amumu': RoleRecommendation(runes: _aftershockEngageTank, itemIds: _tankCore),
    'Anivia': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '3102']),
    'Annie': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Aphelios': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Ashe': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['3085', '3031', '3046', '6676']),
    'AurelionSol': RoleRecommendation(runes: _phaseRushMage, itemIds: ['3157', '3089', '3135', '4629']),
    'Aurora': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Azir': RoleRecommendation(runes: _summonAeryPoke, itemIds: ['3157', '3089', '3135', '4629']),
    'Bard': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Belveth': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Blitzcrank': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Brand': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Braum': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Briar': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Caitlyn': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['6676', '3031', '3094', '3072']),
    'Camille': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: _bruiserCore),
    'Cassiopeia': RoleRecommendation(runes: _phaseRushMage, itemIds: ['3157', '3089', '3135', '6653']),
    'Chogath': RoleRecommendation(runes: _graspBruiser, itemIds: ['3068', '3083', '4401', '3110']),
    'Corki': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Darius': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Diana': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _apBurstCore),
    'Draven': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['3031', '3046', '3072', '6676']),
    'DrMundo': RoleRecommendation(runes: _graspBruiser, itemIds: ['3083', '3068', '3065', '4401']),
    'Ekko': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Elise': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Evelynn': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _apBurstCore),
    'Ezreal': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['3508', '3031', '3046', '6676']),
    'Fiddlesticks': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Fiora': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: _bruiserCore),
    'Fizz': RoleRecommendation(runes: _electrocuteAssassin, itemIds: ['3157', '4645', '3135', '3100']),
    'Galio': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3102']),
    'Gangplank': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Garen': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Gnar': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '3053', '4401']),
    'Gragas': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '4629']),
    'Graves': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['6676', '3031', '3046', '3072']),
    'Gwen': RoleRecommendation(runes: _phaseRushMage, itemIds: ['4629', '3157', '3089', '4645']),
    'Hecarim': RoleRecommendation(runes: _conquerorResolve, itemIds: ['3078', '3053', '4401', '3071']),
    'Heimerdinger': RoleRecommendation(runes: _summonAeryPoke, itemIds: ['3157', '3089', '3135', '4629']),
    'Hwei': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Illaoi': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '3053', '4401']),
    'Irelia': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: _bruiserCore),
    'Ivern': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Janna': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'JarvanIV': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3078', '3068', '4401', '3053']),
    'Jax': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: _bruiserCore),
    'Jayce': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['6676', '3031', '3046', '3814']),
    'Jhin': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['6676', '3094', '3031', '3072']),
    'Jinx': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Kaisa': RoleRecommendation(runes: _fleetFootworkADC, itemIds: _krakenCore),
    'Kalista': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['3508', '3031', '3046', '6676']),
    'Karma': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Karthus': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '6653']),
    'Kassadin': RoleRecommendation(runes: _phaseRushMage, itemIds: _apPokeCore),
    'Katarina': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _apBurstCore),
    'Kayle': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['3115', '3124', '3031', '3072']),
    'Kayn': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Kennen': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '3115']),
    'Khazix': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _lethalityCore),
    'Kindred': RoleRecommendation(runes: _hailOfBladesAssassin, itemIds: _krakenCore),
    'Kled': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'KogMaw': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['3124', '3115', '3085', '3031']),
    'KSante': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '4401', '3053']),
    'Leblanc': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _apBurstCore),
    'LeeSin': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Leona': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Lillia': RoleRecommendation(runes: _phaseRushMage, itemIds: ['3157', '3089', '3135', '4629']),
    'Lissandra': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Lucian': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['6676', '3031', '3046', '3072']),
    'Lulu': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Lux': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Malphite': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3078', '3068', '4401', '3110']),
    'Malzahar': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '3102']),
    'Maokai': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3190']),
    'MasterYi': RoleRecommendation(runes: _conquerorDomination, itemIds: ['3124', '3031', '3046', '3091']),
    'Mel': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apPokeCore),
    'Milio': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'MissFortune': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'MonkeyKing': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Mordekaiser': RoleRecommendation(runes: _conquerorResolve, itemIds: ['6653', '3157', '4636', '3089']),
    'Morgana': RoleRecommendation(runes: _darkHarvestMage, itemIds: ['3157', '3102', '3165', '3089']),
    'Naafiri': RoleRecommendation(runes: _hailOfBladesAssassin, itemIds: ['6691', '3142', '3814', '3071']),
    'Nami': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Nasus': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '3053', '4401']),
    'Nautilus': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Neeko': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Nidalee': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Nilah': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['3085', '3031', '3046', '3072']),
    'Nocturne': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Nunu': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '4629']),
    'Olaf': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Orianna': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Ornn': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3075']),
    'Pantheon': RoleRecommendation(runes: _hailOfBladesAssassin, itemIds: ['6691', '3078', '3814', '3071']),
    'Poppy': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '3053', '4401']),
    'Pyke': RoleRecommendation(runes: _electrocuteAssassin, itemIds: ['6691', '3142', '3814', '3190']),
    'Qiyana': RoleRecommendation(runes: _hailOfBladesAssassin, itemIds: _lethalityCore),
    'Quinn': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['6676', '3031', '3046', '3814']),
    'Rakan': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['6617', '3107', '3190']),
    'Rammus': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3075']),
    'RekSai': RoleRecommendation(runes: _conquerorResolve, itemIds: ['3078', '3053', '3071', '4401']),
    'Rell': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Renata': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Renekton': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Rengar': RoleRecommendation(runes: _hailOfBladesAssassin, itemIds: _lethalityCore),
    'Riven': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Rumble': RoleRecommendation(runes: _phaseRushMage, itemIds: ['4629', '3157', '3089', '4645']),
    'Ryze': RoleRecommendation(runes: _phaseRushMage, itemIds: ['3157', '3089', '3135', '4629']),
    'Samira': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['3085', '3031', '3046', '3072']),
    'Sejuani': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3075']),
    'Senna': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3072']),
    'Seraphine': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Sett': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Shaco': RoleRecommendation(runes: _hailOfBladesAssassin, itemIds: _lethalityCore),
    'Shen': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3075']),
    'Shyvana': RoleRecommendation(runes: _conquerorResolve, itemIds: ['3078', '3053', '4401', '3071']),
    'Singed': RoleRecommendation(runes: _graspBruiser, itemIds: ['3068', '4401', '3110', '3083']),
    'Sion': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '4401', '3053']),
    'Sivir': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['3085', '3031', '3046', '6676']),
    'Skarner': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3078', '3068', '4401', '3053']),
    'Smolder': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Sona': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Soraka': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Swain': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Sylas': RoleRecommendation(runes: _electrocuteAssassin, itemIds: ['3157', '4645', '3135', '3100']),
    'Syndra': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'TahmKench': RoleRecommendation(runes: _graspBruiser, itemIds: ['3068', '3083', '4401', '3190']),
    'Taliyah': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '4629']),
    'Talon': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _lethalityCore),
    'Taric': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Teemo': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3115', '3135', '4645']),
    'Thresh': RoleRecommendation(runes: _guardianEngageSupport, itemIds: ['3190', '3107', '3050']),
    'Tristana': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Trundle': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Tryndamere': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: _bruiserCore),
    'TwistedFate': RoleRecommendation(runes: _arcaneCometMage, itemIds: ['3157', '3089', '3135', '3115']),
    'Twitch': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['6672', '3085', '3031', '3072']),
    'Udyr': RoleRecommendation(runes: _conquerorResolve, itemIds: ['3078', '3053', '4401', '3071']),
    'Urgot': RoleRecommendation(runes: _graspBruiser, itemIds: ['3078', '3068', '3053', '4401']),
    'Varus': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['6676', '3031', '3046', '3072']),
    'Vayne': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['6691', '3142', '3814', '3072']),
    'Veigar': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Velkoz': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Vex': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
    'Vi': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Viego': RoleRecommendation(runes: _conquerorDomination, itemIds: _bruiserCore),
    'Viktor': RoleRecommendation(runes: _phaseRushMage, itemIds: ['4629', '3157', '3089', '3135']),
    'Vladimir': RoleRecommendation(runes: _phaseRushMage, itemIds: ['4636', '3157', '3089', '3135']),
    'Volibear': RoleRecommendation(runes: _conquerorResolve, itemIds: ['3078', '3053', '4401', '3071']),
    'Warwick': RoleRecommendation(runes: _conquerorResolve, itemIds: ['3078', '3053', '4401', '3071']),
    'Xayah': RoleRecommendation(runes: _fleetFootworkADC, itemIds: ['3085', '3031', '3046', '3072']),
    'Xerath': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'XinZhao': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Yasuo': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['6676', '3031', '3046', '3072']),
    'Yone': RoleRecommendation(runes: _pressTheAttackDuelist, itemIds: ['6676', '3031', '3046', '3072']),
    'Yorick': RoleRecommendation(runes: _conquerorResolve, itemIds: _bruiserCore),
    'Yunara': RoleRecommendation(runes: _lethalTempoADC, itemIds: _krakenCore),
    'Yuumi': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['6617', '3107', '3190']),
    'Zac': RoleRecommendation(runes: _aftershockEngageTank, itemIds: ['3068', '3110', '4401', '3075']),
    'Zed': RoleRecommendation(runes: _electrocuteAssassin, itemIds: _lethalityCore),
    'Zeri': RoleRecommendation(runes: _lethalTempoADC, itemIds: ['6672', '3124', '3031', '3085']),
    'Ziggs': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Zilean': RoleRecommendation(runes: _summonAeryEnchanter, itemIds: ['3107', '6617', '3190']),
    'Zoe': RoleRecommendation(runes: _arcaneCometMage, itemIds: _apBurstCore),
    'Zyra': RoleRecommendation(runes: _darkHarvestMage, itemIds: _apBurstCore),
  };

  /// Recommandation d'un champion précis ; repli sur le profil de rôle
  /// générique si ce champion n'a pas (encore) de build dédié.
  static RoleRecommendation forChampion(String championId, List<String> tags) {
    return _byChampionId[championId] ?? RoleRecommendations.forTags(tags);
  }
}
