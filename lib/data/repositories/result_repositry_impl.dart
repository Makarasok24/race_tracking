import 'package:race_tracking/data/data_sources/firebase_result_data_source.dart';
import 'package:race_tracking/data/models/result_model.dart';
import 'package:race_tracking/domain/repositories/result_repositry.dart';

class ResultRepositoryImpl implements ResultRepository {
  final FirebaseResultDataSource dataSource;

  ResultRepositoryImpl({required this.dataSource});

  @override
  Future<void> addResult(String bib, ResultModel result) {
    return dataSource.addResult(bib, result);
  }

  @override
  Future<List<ResultModel>> getAllResults() {
    return dataSource.getAllResults();
  }

  @override
  Future<ResultModel?> getResultByBib(String bib) {
    return dataSource.getResultByBib(bib);
  }

  @override
  Future<void> clearAllResults() {
    return dataSource.clearAllResults();
  }
}
