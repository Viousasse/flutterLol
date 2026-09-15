import '../models/lore_region.dart';

/// Région d'origine de chaque champion, d'après les pages région de l'univers
/// officiel.
///
/// Data Dragon ne publie aucune région : cette table est écrite à la main.
/// Quelques rattachements se discutent — un champion né quelque part et lié à
/// une autre région (Lucian, Ivern, Urgot, Kayn) est classé là où l'univers
/// officiel le range, pas là où il est né.
///
/// Un champion absent de cette table n'est pas une erreur bloquante : il est
/// regroupé dans « Sans région » sur la carte, ce qui rend le trou visible au
/// lieu de le cacher.
const championRegions = <String, RegionId>{
  // Demacia
  'Garen': RegionId.demacia,
  'Lux': RegionId.demacia,
  'JarvanIV': RegionId.demacia,
  'XinZhao': RegionId.demacia,
  'Quinn': RegionId.demacia,
  'Galio': RegionId.demacia,
  'Poppy': RegionId.demacia,
  'Shyvana': RegionId.demacia,
  'Fiora': RegionId.demacia,
  'Vayne': RegionId.demacia,
  'Sona': RegionId.demacia,
  'Sylas': RegionId.demacia,
  'Kayle': RegionId.demacia,
  'Morgana': RegionId.demacia,
  'Lucian': RegionId.demacia,

  // Noxus
  'Darius': RegionId.noxus,
  'Draven': RegionId.noxus,
  'Katarina': RegionId.noxus,
  'Cassiopeia': RegionId.noxus,
  'Swain': RegionId.noxus,
  'Leblanc': RegionId.noxus,
  'Talon': RegionId.noxus,
  'Riven': RegionId.noxus,
  'Sion': RegionId.noxus,
  'Vladimir': RegionId.noxus,
  'Kled': RegionId.noxus,
  'Rell': RegionId.noxus,
  'Samira': RegionId.noxus,
  'Mordekaiser': RegionId.noxus,
  'Briar': RegionId.noxus,
  'Ambessa': RegionId.noxus,
  'Mel': RegionId.noxus,
  'Annie': RegionId.noxus,
  'Alistar': RegionId.noxus,

  // Ionie
  'Ahri': RegionId.ionia,
  'Yasuo': RegionId.ionia,
  'Yone': RegionId.ionia,
  'Zed': RegionId.ionia,
  'Shen': RegionId.ionia,
  'Akali': RegionId.ionia,
  'Kennen': RegionId.ionia,
  'MasterYi': RegionId.ionia,
  'Irelia': RegionId.ionia,
  'Karma': RegionId.ionia,
  'Kayn': RegionId.ionia,
  'LeeSin': RegionId.ionia,
  'Jhin': RegionId.ionia,
  'Sett': RegionId.ionia,
  'Lillia': RegionId.ionia,
  'Rakan': RegionId.ionia,
  'Xayah': RegionId.ionia,
  'Varus': RegionId.ionia,
  'Syndra': RegionId.ionia,
  'MonkeyKing': RegionId.ionia,
  'Hwei': RegionId.ionia,
  'Yunara': RegionId.ionia,

  // Freljord
  'Ashe': RegionId.freljord,
  'Tryndamere': RegionId.freljord,
  'Sejuani': RegionId.freljord,
  'Braum': RegionId.freljord,
  'Anivia': RegionId.freljord,
  'Nunu': RegionId.freljord,
  'Olaf': RegionId.freljord,
  'Volibear': RegionId.freljord,
  'Ornn': RegionId.freljord,
  'Udyr': RegionId.freljord,
  'Lissandra': RegionId.freljord,
  'Gnar': RegionId.freljord,
  'Trundle': RegionId.freljord,
  'Aurora': RegionId.freljord,
  'Gragas': RegionId.freljord,
  'Brand': RegionId.freljord,
  'Ivern': RegionId.freljord,

  // Piltover
  'Caitlyn': RegionId.piltover,
  'Vi': RegionId.piltover,
  'Jayce': RegionId.piltover,
  'Heimerdinger': RegionId.piltover,
  'Ezreal': RegionId.piltover,
  'Camille': RegionId.piltover,
  'Orianna': RegionId.piltover,
  'Seraphine': RegionId.piltover,

  // Zaun
  'Jinx': RegionId.zaun,
  'Ekko': RegionId.zaun,
  'Warwick': RegionId.zaun,
  'Singed': RegionId.zaun,
  'Viktor': RegionId.zaun,
  'Zac': RegionId.zaun,
  'Twitch': RegionId.zaun,
  'Urgot': RegionId.zaun,
  'DrMundo': RegionId.zaun,
  'Blitzcrank': RegionId.zaun,
  'Janna': RegionId.zaun,
  'Ziggs': RegionId.zaun,
  'Renata': RegionId.zaun,
  'Zeri': RegionId.zaun,

  // Targon
  'AurelionSol': RegionId.targon,
  'Diana': RegionId.targon,
  'Leona': RegionId.targon,
  'Pantheon': RegionId.targon,
  'Taric': RegionId.targon,
  'Zoe': RegionId.targon,
  'Soraka': RegionId.targon,
  'Aphelios': RegionId.targon,

  // Shurima
  'Azir': RegionId.shurima,
  'Nasus': RegionId.shurima,
  'Renekton': RegionId.shurima,
  'Sivir': RegionId.shurima,
  'Xerath': RegionId.shurima,
  'Amumu': RegionId.shurima,
  'Rammus': RegionId.shurima,
  'Skarner': RegionId.shurima,
  'Taliyah': RegionId.shurima,
  'KSante': RegionId.shurima,
  'Naafiri': RegionId.shurima,
  'Akshan': RegionId.shurima,
  'Zilean': RegionId.shurima,

  // Bilgewater
  'Gangplank': RegionId.bilgewater,
  'MissFortune': RegionId.bilgewater,
  'Graves': RegionId.bilgewater,
  'TwistedFate': RegionId.bilgewater,
  'Pyke': RegionId.bilgewater,
  'Nautilus': RegionId.bilgewater,
  'Illaoi': RegionId.bilgewater,
  'Fizz': RegionId.bilgewater,
  'TahmKench': RegionId.bilgewater,
  'Nami': RegionId.bilgewater,
  'Nilah': RegionId.bilgewater,

  // Îles Obscures
  'Thresh': RegionId.shadowIsles,
  'Hecarim': RegionId.shadowIsles,
  'Karthus': RegionId.shadowIsles,
  'Yorick': RegionId.shadowIsles,
  'Maokai': RegionId.shadowIsles,
  'Kalista': RegionId.shadowIsles,
  'Elise': RegionId.shadowIsles,
  'Vex': RegionId.shadowIsles,
  'Viego': RegionId.shadowIsles,
  'Senna': RegionId.shadowIsles,
  'Gwen': RegionId.shadowIsles,

  // Ixtal
  'Qiyana': RegionId.ixtal,
  'Nidalee': RegionId.ixtal,
  'Neeko': RegionId.ixtal,
  'Rengar': RegionId.ixtal,
  'Zyra': RegionId.ixtal,
  'Milio': RegionId.ixtal,
  'Malphite': RegionId.ixtal,

  // Bandle
  'Lulu': RegionId.bandleCity,
  'Teemo': RegionId.bandleCity,
  'Tristana': RegionId.bandleCity,
  'Veigar': RegionId.bandleCity,
  'Rumble': RegionId.bandleCity,
  'Corki': RegionId.bandleCity,
  'Yuumi': RegionId.bandleCity,

  // Sans attache : l'univers officiel ne leur donne aucune nation
  'Aatrox': RegionId.runeterra,
  'Bard': RegionId.runeterra,
  'Evelynn': RegionId.runeterra,
  'Fiddlesticks': RegionId.runeterra,
  'Jax': RegionId.runeterra,
  'Kindred': RegionId.runeterra,
  'Nocturne': RegionId.runeterra,
  'Ryze': RegionId.runeterra,
  'Shaco': RegionId.runeterra,

  // Néant
  'Kassadin': RegionId.theVoid,
  'Chogath': RegionId.theVoid,
  'KogMaw': RegionId.theVoid,
  'Velkoz': RegionId.theVoid,
  'Khazix': RegionId.theVoid,
  'RekSai': RegionId.theVoid,
  'Malzahar': RegionId.theVoid,
  'Kaisa': RegionId.theVoid,
  'Belveth': RegionId.theVoid,
};
