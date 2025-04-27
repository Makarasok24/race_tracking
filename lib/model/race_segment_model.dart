import 'package:race_tracking/model/participant_model.dart';

enum segment { swimming, cycling, running }

class RaceSegmentModel {
  final String title;
  final String imagePath;
  final segment segmentType;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;
  final List<ParticipantModel>? participants;

  RaceSegmentModel({
    required this.title,
    required this.imagePath,
    required this.segmentType,
    this.startTime,
    this.endTime,
    this.duration,
    required this.participants,
  });
}
