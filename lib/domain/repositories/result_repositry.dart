import 'package:race_tracking/data/models/result_model.dart';

abstract class ResultRepository {
  Future<void> addResult(String bib, ResultModel result);
  Future<List<ResultModel>> getAllResults();
  Future<ResultModel?> getResultByBib(String bib);
  Future<void> clearAllResults();
}
