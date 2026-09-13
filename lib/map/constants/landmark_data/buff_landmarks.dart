import '../../models/map_landmark.dart';

const buffLandmarks = [
  MapLandmark(
    name: 'Buff bleu',
    description:
        "Gardien bleuté du côté bleu. Octroie régénération de mana et "
        "accélération de compétence.",
    type: LandmarkType.buff,
    side: LandmarkSide.blue,
    x: 0.250,
    y: 0.460,
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
    x: 0.750,
    y: 0.540,
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
];
