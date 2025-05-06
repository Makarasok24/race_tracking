class TransitionTimingModel {
  final int? start;
  final int? end;
  final int? duration;
  final bool isCompleted;
  final String transitionId; // "t1" or "t2"

  TransitionTimingModel({
    this.start,
    this.end,
    this.duration,
    this.isCompleted = false,
    required this.transitionId,
  });

  factory TransitionTimingModel.fromJson(Map<dynamic, dynamic> json) {
    return TransitionTimingModel(
      start: json['start'],
      end: json['end'],
      duration: json['duration'],
      isCompleted: json['isCompleted'] ?? false,
      transitionId: json['transitionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'duration': duration,
      'isCompleted': isCompleted,
      'transitionId': transitionId,
    };
  }
}
