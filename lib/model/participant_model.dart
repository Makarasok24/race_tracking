class ParticipantModel {
  final String firstName;
  final String lastName;
  final int bibNumber;
  final int age;
  final String gender;
  final DateTime? createdAt;

  ParticipantModel({
    required this.firstName,
    required this.lastName,
    required this.bibNumber,
    required this.age,
    required this.gender,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'bibNumber': bibNumber,
      'age': age,
      'gender': gender,
      'created_at': createdAt,
    };
  }

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      bibNumber: json['bibNumber'],
      age: json['age'],
      gender: json['gender'],
      createdAt: json['created_at'],
    );
  }
}
