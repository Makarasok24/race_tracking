// class RaceModel {
//   final String id;
//   final String name;
//   final String date;
//   final String description;
//   final Map<String, double>
//   segmentDistances; // e.g. {"swim": 1.5, "bike": 40, "run": 10}
//   final bool isActive;
//   final bool isCompleted;
//   final int? globalStartTime; // timestamp when race started

//   RaceModel({
//     required this.id,
//     required this.name,
//     required this.date,
//     this.description = '',
//     required this.segmentDistances,
//     this.isActive = false,
//     this.isCompleted = false,
//     this.globalStartTime,
//   });

//   factory RaceModel.fromJson(Map<String, dynamic> json) {
//     return RaceModel(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       date: json['date'] ?? '',
//       description: json['description'] ?? '',
//       segmentDistances: Map<String, double>.from(
//         json['segmentDistances'] ?? {},
//       ),
//       isActive: json['isActive'] ?? false,
//       isCompleted: json['isCompleted'] ?? false,
//       globalStartTime: json['globalStartTime'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'date': date,
//       'description': description,
//       'segmentDistances': segmentDistances,
//       'isActive': isActive,
//       'isCompleted': isCompleted,
//       'globalStartTime': globalStartTime,
//     };
//   }
// }
