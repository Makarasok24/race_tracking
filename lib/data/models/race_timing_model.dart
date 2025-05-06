import 'package:race_tracking/data/models/segment_timing_model.dart';
import 'package:race_tracking/data/models/transaction_timing_model.dart';

class RaceTimingModel {
  final String participantBib; // Link to participant
  final String raceId; // Link to race configuration
  final SegmentTimingModel? swim;
  final SegmentTimingModel? bike;
  final SegmentTimingModel? run;
  final TransitionTimingModel? t1; // Swim to bike transition
  final TransitionTimingModel? t2; // Bike to run transition
  final int? totalTime;
  final int? globalStartTime;
  final bool isCompleted;
  final String currentSegment; // "swim", "t1", "bike", "t2", "run", "finished"

  RaceTimingModel({
    required this.participantBib,
    required this.raceId,
    this.swim,
    this.bike,
    this.run,
    this.t1,
    this.t2,
    this.totalTime,
    this.globalStartTime,
    this.isCompleted = false,
    this.currentSegment = "swim",
  });

  factory RaceTimingModel.fromJson(Map<dynamic, dynamic> json) {
    return RaceTimingModel(
      participantBib: json['participantBib'] ?? '',
      raceId: json['raceId'] ?? '',
      swim:
          json['swim'] != null
              ? SegmentTimingModel.fromJson(json['swim'])
              : null,
      bike:
          json['bike'] != null
              ? SegmentTimingModel.fromJson(json['bike'])
              : null,
      run:
          json['run'] != null ? SegmentTimingModel.fromJson(json['run']) : null,
      t1:
          json['t1'] != null
              ? TransitionTimingModel.fromJson(json['t1'])
              : null,
      t2:
          json['t2'] != null
              ? TransitionTimingModel.fromJson(json['t2'])
              : null,
      totalTime: json['totalTime'],
      globalStartTime: json['globalStartTime'],
      isCompleted: json['isCompleted'] ?? false,
      currentSegment: json['currentSegment'] ?? 'swim',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantBib': participantBib,
      'raceId': raceId,
      'swim': swim?.toJson(),
      'bike': bike?.toJson(),
      'run': run?.toJson(),
      't1': t1?.toJson(),
      't2': t2?.toJson(),
      'totalTime': totalTime,
      'globalStartTime': globalStartTime,
      'isCompleted': isCompleted,
      'currentSegment': currentSegment,
    };
  }

  // Helper method to calculate overall race time
  int calculateTotalTime() {
    int total = 0;
    if (swim?.duration != null) total += swim!.duration!;
    if (bike?.duration != null) total += bike!.duration!;
    if (run?.duration != null) total += run!.duration!;
    if (t1?.duration != null) total += t1!.duration!;
    if (t2?.duration != null) total += t2!.duration!;
    return total;
  }

  // Get current active segment timing model
  dynamic getCurrentSegmentTiming() {
    switch (currentSegment) {
      case 'swim':
        return swim;
      case 'bike':
        return bike;
      case 'run':
        return run;
      case 't1':
        return t1;
      case 't2':
        return t2;
      default:
        return null;
    }
  }
}
