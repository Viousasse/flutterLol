import '../../models/map_landmark.dart';

const baseLaneLandmarks = [
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
    y: 0.095,
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
    y: 0.905,
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
];
