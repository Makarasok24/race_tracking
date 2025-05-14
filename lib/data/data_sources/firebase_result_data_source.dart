import 'package:race_tracking/core/services/firebase_service.dart';
import 'package:race_tracking/data/models/result_model.dart';

class FirebaseResultDataSource {
  final FirebaseService _firebase = FirebaseService();
  final String resultPath = 'results';

  FirebaseResultDataSource();

  Future<void> addResult(String bib, ResultModel result) {
    // Use update instead of set
    return _firebase.update(resultPath, bib, result.toJson());
  }

  Future<List<ResultModel>> getAllResults() async {
    final data = await _firebase.getAll(resultPath);

    if (data.isEmpty) return [];

    final results = <ResultModel>[];

    data.forEach((bib, value) {
      if (value is Map) {
        final resultMap = Map<String, dynamic>.from(value as Map);
        resultMap['bib'] = bib; // Add bib to the result
        results.add(ResultModel.fromJson(resultMap));
      }
    });

    // Sort by rank
    results.sort((a, b) => a.rank.compareTo(b.rank));

    return results;
  }

  Future<ResultModel?> getResultByBib(String bib) async {
    // Changed from get to getById to match the Firebase service
    final data = await _firebase.getById(resultPath, bib);

    if (data.isEmpty) return null;

    final resultMap = Map<String, dynamic>.from(data);
    resultMap['bib'] = bib; // Add bib to the result

    return ResultModel.fromJson(resultMap);
  }

  Future<void> clearAllResults() async {
    try {
      // Get all results first
      final data = await _firebase.getAll(resultPath);

      if (data.isEmpty) return;

      // Delete each result
      for (var key in data.keys) {
        await _firebase.delete(resultPath, key);
      }

      print("🗑️ All results cleared");
    } catch (e) {
      print("❌ Error clearing results: $e");
      throw Exception("Failed to clear results: $e");
    }
  }
}
