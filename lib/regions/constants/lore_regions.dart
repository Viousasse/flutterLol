import 'package:flutter/material.dart';

import '../models/lore_region.dart';

/// Fond de carte : l'image du monde de la carte interactive officielle,
/// récupérée depuis map.leagueoflegends.com/assets/images/tiles/terrain_z1.jpg
/// (niveau de zoom 1, 2048 × 2048) et embarquée dans l'app.
const runeterraMapAsset = 'assets/images/runeterra_map.jpg';

/// Les grandes régions de Runeterra, posées sur cette image.
///
/// Les positions sont relevées à la main sur la carte officielle : Riot publie
/// l'image mais aucune coordonnée. Une région sans territoire (Bandle, les
/// champions sans attache) n'a pas de position et s'affiche sous la carte.
const loreRegions = [
  LoreRegion(
    id: RegionId.runeterra,
    name: 'Sans attache',
    tagline: 'Partout et nulle part',
    description:
        "Des champions qu'aucune nation ne revendique : esprits, errants et "
        "vieilles choses qui traversent le monde sans s'y fixer.",
    color: Color(0xFF9AA0A6),
  ),
  LoreRegion(
    id: RegionId.freljord,
    name: 'Freljord',
    tagline: 'Le nord gelé',
    description:
        "Trois tribus se disputent une terre de glace où survivre est déjà "
        "une victoire. La magie ancienne y dort sous le givre.",
    color: Color(0xFF7FC7E8),
    x: 0.30,
    y: 0.36,
  ),
  LoreRegion(
    id: RegionId.noxus,
    name: 'Noxus',
    tagline: "L'empire conquérant",
    description:
        "Un empire brutal mais méritocratique : peu importe d'où l'on vient, "
        "seule compte la force que l'on démontre.",
    color: Color(0xFFC0392B),
    x: 0.52,
    y: 0.44,
  ),
  LoreRegion(
    id: RegionId.demacia,
    name: 'Demacia',
    tagline: 'Le royaume de la loi',
    description:
        "Un royaume d'ordre et d'honneur, bâti sur la pierre qui étouffe la "
        "magie — et sur la peur de ceux qui la portent.",
    color: Color(0xFF6E9BD6),
    x: 0.26,
    y: 0.50,
  ),
  LoreRegion(
    id: RegionId.ionia,
    name: 'Ionie',
    tagline: "Les îles de l'équilibre",
    description:
        "Des îles baignées de magie naturelle, longtemps en paix, que "
        "l'invasion noxienne a durablement fracturées.",
    color: Color(0xFFE98AB0),
    x: 0.74,
    y: 0.40,
  ),
  LoreRegion(
    id: RegionId.piltover,
    name: 'Piltover',
    tagline: 'La cité du progrès',
    description:
        "La ville du progrès et du commerce, où la hextech transforme la "
        "magie en machine — et la machine en fortune.",
    color: Color(0xFFD8A85B),
    x: 0.59,
    y: 0.545,
  ),
  LoreRegion(
    id: RegionId.zaun,
    name: 'Zaun',
    tagline: 'La ville basse',
    description:
        "Sous Piltover, une ville d'alchimie et de fumées où l'on invente "
        "sans permission et où l'on respire du poison.",
    color: Color(0xFF6FBF73),
    x: 0.37,
    y: 0.60,
  ),
  LoreRegion(
    id: RegionId.targon,
    name: 'Targon',
    tagline: 'La montagne céleste',
    description:
        "Une montagne impossible que seuls les élus gravissent, pour y être "
        "investis par les Aspects venus des étoiles.",
    color: Color(0xFF9B7FD4),
    x: 0.33,
    y: 0.70,
  ),
  LoreRegion(
    id: RegionId.shurima,
    name: 'Shurima',
    tagline: "L'empire enseveli",
    description:
        "Un empire solaire englouti par le désert, revenu des sables avec "
        "ses dieux-empereurs et ses vieilles rancunes.",
    color: Color(0xFFE0B052),
    x: 0.55,
    y: 0.75,
  ),
  LoreRegion(
    id: RegionId.bilgewater,
    name: 'Bilgewater',
    tagline: 'Le port des pirates',
    description:
        "Un port sans loi vivant de la chasse aux monstres marins, où les "
        "dettes se règlent au couteau.",
    color: Color(0xFFD97D4A),
    x: 0.81,
    y: 0.54,
  ),
  LoreRegion(
    id: RegionId.shadowIsles,
    name: 'Îles Obscures',
    tagline: 'La brume noire',
    description:
        "Un archipel maudit noyé sous la Brume noire, où la mort ne libère "
        "personne et où tout ce qui entre est retenu.",
    color: Color(0xFF4FBF9F),
    x: 0.88,
    y: 0.74,
  ),
  LoreRegion(
    id: RegionId.ixtal,
    name: 'Ixtal',
    tagline: 'La jungle cachée',
    description:
        "Une nation retirée au cœur de la jungle, qui maîtrise les magies "
        "élémentaires et refuse de les partager.",
    color: Color(0xFF3FA88A),
    x: 0.68,
    y: 0.64,
  ),
  LoreRegion(
    id: RegionId.bandleCity,
    name: 'Bandle',
    tagline: 'Le monde des yordles',
    description:
        "La patrie spirituelle des yordles, superposée au monde matériel : "
        "on n'y entre pas, on y est invité.",
    color: Color(0xFFC9A227),
  ),
  LoreRegion(
    id: RegionId.theVoid,
    name: 'Néant',
    tagline: 'Ce qui est sous le monde',
    description:
        "Un vide affamé sous Runeterra, qui n'envoie pas des armées mais "
        "des appétits, et défait ce qu'il touche.",
    color: Color(0xFF8A5FBF),
    x: 0.63,
    y: 0.86,
  ),
  LoreRegion(
    id: RegionId.unknown,
    name: 'Non répertoriés',
    tagline: 'Pas encore classés',
    description:
        "Des champions arrivés après la rédaction de la table des régions. "
        "Ils sont listés ici plutôt que rattachés au hasard.",
    color: Color(0xFF6B6461),
  ),
];

final regionsById = {for (final region in loreRegions) region.id: region};
