// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;

// class FirebaseStudentRepository extends StudentRepository {
//   static const String baseUrl =
//       "https://week-8-practice-3484f-default-rtdb.asia-southeast1.firebasedatabase.app";
//   static const String students = "students";
//   static const String allStudentsUrl = '$baseUrl/$students.json';
//   Uri uri = Uri.parse(allStudentsUrl);

//   @override
//   Future<Student> addStudent({
//     required String firstName,
//     required String lastName,
//     required int age,
//     required String email,
//   }) async {
//     final newStudentData = {
//       'firstName': firstName,
//       'lastName': lastName,
//       'age': age,
//       'email': email,
//     };

//     final http.Response response = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(newStudentData),
//     );

//     if (response.statusCode != HttpStatus.ok) {
//       throw Exception("Failed to add student");
//     }

//     // Correct way to get Firebase-generated ID
//     final responseData = json.decode(response.body);
//     final newId =
//         responseData['name'] as String; // Firebase returns ID in 'name' field

//     return Student(
//       id: newId,
//       firstName: firstName,
//       lastName: lastName,
//       age: age,
//       email: email,
//     );
//   }

//   @override
//   Future<List<Student>> getStudents() async {
//     final http.Response response = await http.get(uri);

//     if (response.statusCode != HttpStatus.ok &&
//         response.statusCode != HttpStatus.created) {
//       throw Exception("Failed to load students");
//     }

//     try {
//       final studentData = json.decode(response.body) as Map<String, dynamic>?;
//       print('Student data: $studentData');

//       if (studentData == null || studentData.isEmpty) return [];

//       return studentData.entries.map((entry) {
//         final studentJson = entry.value as Map<String, dynamic>? ?? {};
//         return DtoStudent.fromJson(entry.key, studentJson);
//       }).toList();
//     } catch (e) {
//       print('Error parsing students: $e');
//       throw Exception('Failed to parse student data');
//     }
//   }

//   @override
//   Future<http.Response> deleteStudent({required String id}) async {
//     Uri uri = Uri.parse('$baseUrl/$students/$id.json');
//     final http.Response response = await http.delete(uri);

//     if (response.statusCode != HttpStatus.ok) {
//       throw Exception("Filed to delete student");
//     }
//     return response;
//   }

//   @override
//   Future<Student> updateStudent({
//     required String id,
//     required String firstName,
//     required String lastName,
//     required int age,
//     required String email,
//   }) async {
//     Uri uri = Uri.parse('$baseUrl/$students/$id.json');
//     final updateStudentData = {
//       'firstName': firstName,
//       'lastName': lastName,
//       'age': age,
//       'email': email,
//     };

//     final http.Response response = await http.put(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(updateStudentData),
//     );

//     if (response.statusCode != HttpStatus.ok) {
//       throw Exception("Filed to update student");
//     }

//     return Student(
//       id: id,
//       firstName: firstName,
//       lastName: lastName,
//       age: age,
//       email: email,
//     );
//   }
// }
