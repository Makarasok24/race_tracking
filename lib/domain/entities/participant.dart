// lib/domain/entities/participant.dart
class Participant {
  final String bib;
  final String name;
  final String age;
  final String gender;
  final bool isCompleted;
  final int duration;
  final double distance;
  final String globalStartTime;

  Participant({
    required this.bib,
    required this.name,
    required this.age,
    required this.gender,
    required this.isCompleted,
    required this.duration,
    required this.distance,
    required this.globalStartTime,
  });

  // Convert Firebase JSON response to Participant object
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      bib: json['bib'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      duration: json['duration'] ?? 0,
      distance: json['distance'] ?? 0.0,
      globalStartTime: json['globalStartTime'] ?? '',
    );
  }
  // Convert Participant object to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'isCompleted': isCompleted,
      'duration': duration,
      'distance': distance,
      'globalStartTime': globalStartTime,
    };
  }
}
