class ParticipantModel {
  final String firstName;
  final String lastName;
  final int bibNumber;
  final DateTime? createdAt;

  ParticipantModel({
    required this.firstName,
    required this.lastName,
    required this.bibNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'bibNumber': bibNumber,
      'created_at': createdAt,
    };
  }

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      bibNumber: json['bibNumber'],
      createdAt: json['created_at'],
    );
  }
}
