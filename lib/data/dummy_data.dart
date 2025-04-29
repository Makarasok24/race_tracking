import 'package:race_tracking/model/race_segment_model.dart';
import 'package:race_tracking/model/participant_model.dart';

var segmentDatas = [
  RaceSegmentModel(
    id: "1",
    title: "Swimming",
    imagePath: "assets/images/swimming.png",
    segmentType: segment.swimming,
    participants: [
      ParticipantModel(
        id: "1",
        firstName: "John",
        lastName: "Doe",
        bibNumber: 101,
        createdAt: DateTime.now(),
      ),
      ParticipantModel(
        id: "2",
        firstName: "Emma",
        lastName: "Stone",
        bibNumber: 102,
        createdAt: DateTime.now(),
      ),
    ],
  ),
  RaceSegmentModel(
    id: "2",
    title: "Cycling",
    imagePath: "assets/images/cycling.png",
    segmentType: segment.cycling,
    participants: [
      ParticipantModel(
        id: "3",
        firstName: "Mike",
        lastName: "Tyson",
        bibNumber: 201,
        createdAt: DateTime.now(),
      ),
      ParticipantModel(
        id: "4",
        firstName: "Sarah",
        lastName: "Connor",
        bibNumber: 202,
        createdAt: DateTime.now(),
      ),
    ],
  ),
  RaceSegmentModel(
    id: "3",
    title: "Running",
    imagePath: "assets/images/running.png",
    segmentType: segment.running,
    participants: [
      ParticipantModel(
        id: "5",
        firstName: "Usain",
        lastName: "Bolt",
        bibNumber: 301,
        createdAt: DateTime.now(),
      ),
      ParticipantModel(
        id: "6",
        firstName: "Mo",
        lastName: "Farah",
        bibNumber: 302,
        createdAt: DateTime.now(),
      ),
    ],
  ),
];
