import 'package:flutter/material.dart';

enum RegionId {
  runeterra,
  demacia,
  noxus,
  ionia,
  freljord,
  piltover,
  zaun,
  shurima,
  targon,
  bilgewater,
  shadowIsles,
  ixtal,
  bandleCity,
  theVoid,
  unknown,
}

/// Une région de Runeterra, posée sur la carte stylisée du lore.
///
/// [x] vaut 0 au bord gauche et 1 au bord droit, [y] vaut 0 en haut et 1 en
/// bas, comme pour les points de la Faille. Data Dragon ne publie ni carte du
/// monde ni région : positions, couleurs et textes sont écrits à la main.
///
/// Les deux valent `null` pour une région qui n'occupe aucun territoire, comme
/// les champions sans attache : elle existe, mais ne se pose pas sur la carte.
class LoreRegion {
  final RegionId id;
  final String name;
  final String tagline;
  final String description;
  final Color color;
  final double? x;
  final double? y;

  const LoreRegion({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.color,
    this.x,
    this.y,
  });
}
