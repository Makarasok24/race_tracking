class SegmentTiming {
  final int? start;
  final int? end;
  final int? duration;
  final bool isCompleted;
  final double? distance;

  SegmentTiming({
    this.start,
    this.end,
    this.duration,
    this.isCompleted = false,
    this.distance,
  });

  factory SegmentTiming.fromJson(Map<String, dynamic> json) {
    return SegmentTiming(
      start: json['start'] as int?,
      end: json['end'] as int?,
      duration: json['duration'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      distance: json['distance'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'duration': duration,
      'isCompleted': isCompleted,
      'distance': distance,
    };
  }

  //calculate speed
  double get speed {
    if (distance != null && duration != null && duration! > 0) {
      return distance! / (duration! / 3600);
    } else {
      return 0.0;
    }
  }
}
