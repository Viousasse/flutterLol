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
