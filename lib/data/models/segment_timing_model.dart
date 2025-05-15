class SegmentTimingModel {
  final int? start;
  final int? end;
  final int? duration;
  final bool isCompleted;
  final double? distance;
  final String segmentId; 

  SegmentTimingModel({
    this.start,
    this.end,
    this.duration,
    this.isCompleted = false,
    this.distance,
    required this.segmentId,
  });

  factory SegmentTimingModel.fromJson(Map<dynamic, dynamic> json) {
    return SegmentTimingModel(
      start: json['start'],
      end: json['end'],
      duration: json['duration'],
      isCompleted: json['isCompleted'] ?? false,
      distance: json['distance']?.toDouble(),
      segmentId: json['segmentId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'duration': duration,
      'isCompleted': isCompleted,
      'distance': distance,
      'segmentId': segmentId,
    };
  }

  // Calculate speed in km/h
  double? calculateSpeed() {
    if (duration != null && distance != null && duration! > 0) {
      // Convert to hours and calculate speed
      double durationInHours = duration! / 3600;
      return distance! / durationInHours;
    }
    return null;
  }

  // Calculate pace (minutes per km)
  double? calculatePace() {
    if (duration != null && distance != null && distance! > 0) {
      // Convert to minutes per km
      return (duration! / 60) / distance!;
    }
    return null;
  }
}
