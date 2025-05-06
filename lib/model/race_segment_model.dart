import 'package:race_tracking/model/participant_model.dart';

enum segment { swimming, cycling, running }

class RaceSegmentModel {
  final String id;
  final String title;
  final String imagePath;
  final String status;
  final segment segmentType;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;
  final List<ParticipantModel>? participants;

  RaceSegmentModel({
    required this.id,
    required this.title,
    required this.status,
    required this.imagePath,
    required this.segmentType,
    this.startTime,
    this.endTime,
    this.duration,
    required this.participants,
  });
}
