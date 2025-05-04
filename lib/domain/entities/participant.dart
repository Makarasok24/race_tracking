// lib/domain/entities/participant.dart
class Participant {
  final String bib;
  final String name;
  final bool isCompleted;
  final int duration;
  final double distance;
  final String globalStartTime;

  Participant({
    required this.bib,
    required this.name,
    required this.isCompleted,
    required this.duration,
    required this.distance,
    required this.globalStartTime,
  });

  // Convert Firebase JSON response to Participant object
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      bib: json['bib'],
      name: json['name'],
      isCompleted: json['isCompleted'],
      duration: json['duration'],
      distance: json['distance'],
      globalStartTime: json['globalStartTime'],
    );
  }

  // Convert Participant object to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'bib': bib,
      'name': name,
      'isCompleted': isCompleted,
      'duration': duration,
      'distance': distance,
      'globalStartTime': globalStartTime,
    };
  }
}
