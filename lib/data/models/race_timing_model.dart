import 'package:race_tracking/data/models/segment_timing_model.dart';

class RaceTimingModel {
  final SegmentTimingModel? swim;
  final SegmentTimingModel? bike;
  final SegmentTimingModel? run;
  final int? totalTime;
  final int? globalStartTime;

  RaceTimingModel({
    this.swim,
    this.bike,
    this.run,
    this.totalTime,
    this.globalStartTime,
  });

  factory RaceTimingModel.fromJson(Map<dynamic, dynamic> json) {
    return RaceTimingModel(
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
