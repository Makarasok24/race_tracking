// data/models/participant_model.dart
import '../../domain/entities/participant.dart';

class ParticipantModel extends Participant {
  ParticipantModel({
    required String bib,
    required String name,
    required String age,
    required String gender,
    bool isCompleted = false,
    int duration = 0,
    double distance = 0.0,
    String globalStartTime = '',
  }) : super(
         bib: bib,
         name: name,
         age: age,
         gender: gender,
         isCompleted: isCompleted,
         duration: duration,
         distance: distance,
         globalStartTime: globalStartTime,
       );

  factory ParticipantModel.fromEntity(Participant participant) {
    return ParticipantModel(
      bib: participant.bib,
      name: participant.name,
      age: participant.age,
      gender: participant.gender,
      isCompleted: participant.isCompleted,
      duration: participant.duration,
      distance: participant.distance,
      globalStartTime: participant.globalStartTime,
    );
  }

  factory ParticipantModel.fromJson(String bib, Map<String, dynamic> json) {
    return ParticipantModel(
      bib: bib,
      name: json['name'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      duration: json['duration'] ?? 0,
      distance: json['distance'] ?? 0.0,
      globalStartTime: json['globalStartTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'duration': duration,
      'distance': distance,
      'globalStartTime': globalStartTime,
    };
  }

  Participant toEntity() {
    return Participant(
      bib: bib,
      name: name,
      age: age,
      gender: gender,
      isCompleted: isCompleted,
      duration: duration,
      distance: distance,
      globalStartTime: globalStartTime,
    );
  }
}
