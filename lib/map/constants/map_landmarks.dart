import 'package:flutter/material.dart';

enum LandmarkType { base, lane, objective, buff, camp }

enum LandmarkSide { blue, red, neutral }

const landmarkTypeLabels = {
  LandmarkType.base: 'Bases',
  LandmarkType.lane: 'Voies',
  LandmarkType.objective: 'Objectifs',
  LandmarkType.buff: 'Buffs',
  LandmarkType.camp: 'Camps',
};

const landmarkSideLabels = {
  LandmarkSide.blue: 'Côté bleu',
  LandmarkSide.red: 'Côté rouge',
  LandmarkSide.neutral: 'Neutre',
};

const landmarkSideColors = {
  LandmarkSide.blue: Color(0xFF6E9BD6),
  LandmarkSide.red: Color(0xFFC75B4A),
  LandmarkSide.neutral: Color(0xFFD8B15E),
};

/// Un lieu notable de la carte, positionné en coordonnées relatives à l'image.
///
/// [x] vaut 0 au bord gauche et 1 au bord droit, [y] vaut 0 en haut et 1 en
/// bas. Les positions sont posées à la main : Data Dragon fournit l'image de
/// la carte mais aucune coordonnée d'objectif. Les deux moitiés de la Faille
/// sont symétriques par rotation, donc un point rouge se déduit de son
/// équivalent bleu par (1 - x, 1 - y).
class MapLandmark {
  final String name;
  final String description;
  final LandmarkType type;
  final LandmarkSide side;
  final double x;
  final double y;

  const MapLandmark({
    required this.name,
    required this.description,
    required this.type,
    required this.side,
    required this.x,
    required this.y,
  });

  Color get color => landmarkSideColors[side]!;
}

const summonersRiftLandmarks = [
  MapLandmark(
    name: 'Nexus bleu',
    description: "Base de l'équipe bleue. Sa destruction met fin à la partie.",
    type: LandmarkType.base,
    side: LandmarkSide.blue,
    x: 0.090,
    y: 0.910,
  ),
  MapLandmark(
    name: 'Nexus rouge',
    description: "Base de l'équipe rouge. Sa destruction met fin à la partie.",
    type: LandmarkType.base,
    side: LandmarkSide.red,
    x: 0.910,
    y: 0.090,
  ),
  MapLandmark(
    name: 'Top',
    description:
        "Voie du haut, isolée et souvent jouée en duel. Elle borde la fosse "
        "du Baron, ce qui la rend dangereuse en fin de partie.",
    type: LandmarkType.lane,
    side: LandmarkSide.neutral,
    x: 0.300,
    y: 0.120,
  ),
  MapLandmark(
    name: 'Mid',
    description:
        "La voie la plus courte. Elle donne accès aux deux moitiés de la "
        "jungle et à la rivière, d'où les rotations rapides.",
    type: LandmarkType.lane,
    side: LandmarkSide.neutral,
    x: 0.500,
    y: 0.500,
  ),
  MapLandmark(
    name: 'Bot',
    description:
        "Voie du bas, jouée à deux par le tireur et le support. Elle borde la "
        "fosse du Dragon.",
    type: LandmarkType.lane,
    side: LandmarkSide.neutral,
    x: 0.700,
    y: 0.880,
  ),
  MapLandmark(
    name: 'Fosse du Baron',
    description:
        "Le Héraut de la Faille y apparaît en début de partie, puis Baron "
        "Nashor prend sa place. Le Baron renforce toute l'équipe et les "
        "sbires alliés.",
    type: LandmarkType.objective,
    side: LandmarkSide.neutral,
    x: 0.340,
    y: 0.300,
  ),
  MapLandmark(
    name: 'Fosse du Dragon',
    description:
        "Les dragons élémentaires y apparaissent à tour de rôle. Quatre "
        "dragons tués octroient l'Âme du dragon.",
    type: LandmarkType.objective,
    side: LandmarkSide.neutral,
    x: 0.660,
    y: 0.700,
  ),
  MapLandmark(
    name: 'Buff bleu',
    description:
        "Gardien bleuté du côté bleu. Octroie régénération de mana et "
        "accélération de compétence.",
    type: LandmarkType.buff,
    side: LandmarkSide.blue,
    x: 0.255,
    y: 0.470,
  ),
  MapLandmark(
    name: 'Buff rouge',
    description:
        "Broyeur rouge du côté bleu. Les attaques brûlent et ralentissent la "
        "cible.",
    type: LandmarkType.buff,
    side: LandmarkSide.blue,
    x: 0.525,
    y: 0.735,
  ),
  MapLandmark(
    name: 'Buff bleu',
    description:
        "Gardien bleuté du côté rouge. Octroie régénération de mana et "
        "accélération de compétence.",
    type: LandmarkType.buff,
    side: LandmarkSide.red,
    x: 0.745,
    y: 0.530,
  ),
  MapLandmark(
    name: 'Buff rouge',
    description:
        "Broyeur rouge du côté rouge. Les attaques brûlent et ralentissent la "
        "cible.",
    type: LandmarkType.buff,
    side: LandmarkSide.red,
    x: 0.475,
    y: 0.265,
  ),
  MapLandmark(
    name: 'Gromp',
    description: "Crapaud géant du côté bleu, adossé au buff bleu.",
    type: LandmarkType.camp,
    side: LandmarkSide.blue,
    x: 0.145,
    y: 0.435,
  ),
  MapLandmark(
    name: 'Loups',
    description: "Camp de loups du côté bleu, entre le buff bleu et le mid.",
    type: LandmarkType.camp,
    side: LandmarkSide.blue,
    x: 0.255,
    y: 0.570,
  ),
  MapLandmark(
    name: 'Raptors',
    description: "Camp d'oiseaux du côté bleu, près du mid.",
    type: LandmarkType.camp,
    side: LandmarkSide.blue,
    x: 0.470,
    y: 0.640,
  ),
  MapLandmark(
    name: 'Krugs',
    description: "Golems de pierre du côté bleu, à l'entrée de la voie du bas.",
    type: LandmarkType.camp,
    side: LandmarkSide.blue,
    x: 0.580,
    y: 0.820,
  ),
  MapLandmark(
    name: 'Gromp',
    description: "Crapaud géant du côté rouge, adossé au buff bleu.",
    type: LandmarkType.camp,
    side: LandmarkSide.red,
    x: 0.855,
    y: 0.565,
  ),
  MapLandmark(
    name: 'Loups',
    description: "Camp de loups du côté rouge, entre le buff bleu et le mid.",
    type: LandmarkType.camp,
    side: LandmarkSide.red,
    x: 0.745,
    y: 0.430,
  ),
  MapLandmark(
    name: 'Raptors',
    description: "Camp d'oiseaux du côté rouge, près du mid.",
    type: LandmarkType.camp,
    side: LandmarkSide.red,
    x: 0.530,
    y: 0.360,
  ),
  MapLandmark(
    name: 'Krugs',
    description:
        "Golems de pierre du côté rouge, à l'entrée de la voie du haut.",
    type: LandmarkType.camp,
    side: LandmarkSide.red,
    x: 0.420,
    y: 0.180,
  ),
];
