import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/firebase_config.dart';

class FirebaseService {
  final String baseUrl = FirebaseConfig.baseUrl;

  // Create
  Future<void> create(String path, String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$path/$id.json'),
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create data: ${response.body}');
    }
  }

  // update
  Future<void> update(String path, String id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$path/$id.json'),
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update data: ${response.body}');
    }
  }

  // delete
  Future<void> delete(String path, String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$path/$id.json'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete data: ${response.body}');
    }
  }

  // get by id
  Future<Map<String, dynamic>> getById(String path, String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$path/$id.json'));

    if (response.statusCode == 200) {
      if (response.body == "null") return {};
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get data: ${response.body}');
    }
  }

  // get all
  Future<Map<String, dynamic>> getAll(String path) async {
    final response = await http.get(Uri.parse('$baseUrl/$path.json'));

    if (response.statusCode == 200) {
      if (response.body == "null") return {};
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get all data: ${response.body}');
    }
  }

  Stream<Map<String, dynamic>?> streamDocument(
    String path, {
    Duration refreshInterval = const Duration(seconds: 2),
  }) {
    final controller = StreamController<Map<String, dynamic>?>();

    Future<void> fetchData() async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/$path.json'));

        if (response.statusCode == 200) {
          if (response.body == "null") {
            controller.add({});
          } else {
            controller.add(json.decode(response.body));
          }
        } else {
          controller.addError('Failed to get data: ${response.body}');
        }
      } catch (e) {
        controller.addError('Error streaming data: $e');
      }
    }

    fetchData();

    final timer = Timer.periodic(refreshInterval, (_) => fetchData());
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    return controller.stream;
  }

  Future<Map<String, dynamic>> queryByChild(
    String path,
    String field,
    dynamic value,
  ) async {

    final encodedField = Uri.encodeComponent('"$field"');
    final encodedValue =
        value is String ? Uri.encodeComponent('"$value"') : value.toString();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/$path.json?orderBy=$encodedField&equalTo=$encodedValue',
      ),
    );

    if (response.statusCode == 200) {
      if (response.body == "null") return {};
      return json.decode(response.body);
    } else {
      throw Exception('Failed to query data: ${response.body}');
    }
  }
}
