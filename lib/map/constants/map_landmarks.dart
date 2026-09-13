export '../models/map_landmark.dart';

import '../models/map_landmark.dart';
import 'landmark_data/base_lane_landmarks.dart';
import 'landmark_data/buff_landmarks.dart';
import 'landmark_data/camp_landmarks.dart';

const List<MapLandmark> summonersRiftLandmarks = [
  ...baseLaneLandmarks,
  ...buffLandmarks,
  ...campLandmarks,
];
