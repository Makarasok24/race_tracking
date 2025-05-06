class Participants {
  final String id;
  final String name;
  final int bibNumber;
  final int age;
  final String gender;
  final DateTime? createdAt;

  Participants({
    required this.id,
    required this.name,
    required this.bibNumber,
    required this.age,
    required this.gender,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bibNumber': bibNumber,
      'age': age,
      'gender': gender,
      'created_at': createdAt,
    };
  }

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      id: json['id'],
      name: json['name'],
      bibNumber: json['bibNumber'],
      age: json['age'],
      gender: json['gender'],
      createdAt: json['created_at'],
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Participants && other.id == id;
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode;
}
