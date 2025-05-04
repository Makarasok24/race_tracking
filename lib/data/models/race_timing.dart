import 'package:race_tracking/data/models/segment_timing.dart';

class RaceTiming {
  final SegmentTiming? swim;
  final SegmentTiming? bike;
  final SegmentTiming? run;
  final int? totalTime;
  final int? globalStartTime;

  RaceTiming({this.swim, this.bike, this.run, this.totalTime, this.globalStartTime});

  factory RaceTiming.fromJson(Map<dynamic, dynamic> json) {
    return RaceTiming(
      swim: json['swim'] != null ? SegmentTiming.fromJson(json['swim']) : null,
      bike: json['bike'] != null ? SegmentTiming.fromJson(json['bike']) : null,
      run: json['run'] != null ? SegmentTiming.fromJson(json['run']) : null,
      totalTime: json['totalTime'],
      globalStartTime: json['globalStartTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swim': swim?.toJson(),
      'bike': bike?.toJson(),
      'run': run?.toJson(),
      'totalTime': totalTime,
      'globalStartTime': globalStartTime,
    };
  }
}
