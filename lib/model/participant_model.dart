class ParticipantModel {
  final String id;
  final String firstName;
  final String lastName;
  final int bibNumber;
  final int age;
  final String gender;
  final DateTime? createdAt;

  ParticipantModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bibNumber,
    required this.age,
    required this.gender,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      bibNumber: json['bibNumber'],
      age: json['age'],
      gender: json['gender'],
      createdAt: json['created_at'],
    );
  }
}
