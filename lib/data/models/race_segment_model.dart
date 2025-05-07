import 'package:race_tracking/data/models/participant_model.dart';

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
  final int? globalStartTime; // Added this field
  final bool isCompleted; // Added this field
  final List<ParticipantModel> participants;

  RaceSegmentModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.status,
    required this.segmentType,
    this.startTime,
    this.endTime,
    this.duration,
    this.globalStartTime, // Added parameter
    this.isCompleted = false, // Added parameter with default
    this.participants = const [],
  });

  // Helper method to format duration as MM:SS
  String formatDuration() {
    if (duration == null) return "--:--";

    int totalSeconds = duration!.inSeconds;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Helper to get a human-readable segment name
  String get segmentName {
    switch (segmentType) {
      case segment.swimming:
        return 'Swimming';
      case segment.cycling:
        return 'Cycling';
      case segment.running:
        return 'Running';
      default:
        return title;
    }
  }
}
