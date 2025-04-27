import 'package:race_tracking/model/race_segment_model.dart';
import 'package:race_tracking/model/participant_model.dart';

var segmentDatas = [
  RaceSegmentModel(
    title: "Swimming",
    imagePath: "assets/images/swimming.png",
    segmentType: segment.swimming,
    participants: [
      ParticipantModel(
        firstName: "John",
        lastName: "Doe",
        bibNumber: 101,
        createdAt: DateTime.now(),
      ),
      ParticipantModel(
        firstName: "Emma",
        lastName: "Stone",
        bibNumber: 102,
        createdAt: DateTime.now(),
      ),
    ],
  ),
  RaceSegmentModel(
    title: "Cycling",
    imagePath: "assets/images/cycling.png",
    segmentType: segment.cycling,
    participants: [
      ParticipantModel(
        firstName: "Mike",
        lastName: "Tyson",
        bibNumber: 201,
        createdAt: DateTime.now(),
      ),
      ParticipantModel(
        firstName: "Sarah",
        lastName: "Connor",
        bibNumber: 202,
        createdAt: DateTime.now(),
      ),
    ],
  ),
  RaceSegmentModel(
    title: "Running",
    imagePath: "assets/images/running.png",
    segmentType: segment.running,
    participants: [
      ParticipantModel(
        firstName: "Usain",
        lastName: "Bolt",
        bibNumber: 301,
        createdAt: DateTime.now(),
      ),
      ParticipantModel(
        firstName: "Mo",
        lastName: "Farah",
        bibNumber: 302,
        createdAt: DateTime.now(),
      ),
    ],
  ),
];
