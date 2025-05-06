import 'package:race_tracking/core/services/firebase_service.dart';
import 'package:race_tracking/data/models/race_timing_model.dart';

class FirebaseRaceTimingDataSource {
  final FirebaseService _firebase = FirebaseService();
  final String raceTimingPath = 'raceTiming';

  Future<void> addRaceTiming(RaceTimingModel raceTiming) {
    return _firebase.create(
      raceTimingPath,
      raceTiming.participantBib,
      raceTiming.toJson(),
    );
  }

  Future<RaceTimingModel?> getRaceTimingByBib(String bib) async {
    final data = await _firebase.getAll(raceTimingPath);
    if (data.isEmpty) return null;

    if (data.containsKey(bib)) {
      return RaceTimingModel.fromJson(Map<String, dynamic>.from(data[bib]));
    }

    return null;
  }

  Future<void> updateSegment(
    String bib,
    String segmentId,
    Map<String, dynamic> data,
  ) {
    return getRaceTimingByBib(bib).then((raceTiming) {
      if (raceTiming == null) throw Exception("Race timing not found");

      final Map<String, dynamic> fullData = raceTiming.toJson();

      if (fullData.containsKey(segmentId)) {
        fullData[segmentId] = {...fullData[segmentId], ...data};
      } else {
        fullData[segmentId] = data;
      }

      return _firebase.update(raceTimingPath, bib, fullData);
    });
  }

  Future<void> updateRaceTiming(String bib, Map<String, dynamic> data) {
    return _firebase.update(raceTimingPath, bib, data);
  }

  Future<List<RaceTimingModel>> getParticipantsBySegment(
    String segmentId,
  ) async {
    final data = await _firebase.queryByChild(
      raceTimingPath,
      'currentSegment',
      segmentId,
    );

    if (data.isEmpty) return [];

    return data.entries
        .map(
          (e) => RaceTimingModel.fromJson(Map<String, dynamic>.from(e.value)),
        )
        .toList();
  }

  Future<List<RaceTimingModel>> getActiveParticipants() async {
    final data = await _firebase.queryByChild(
      raceTimingPath,
      'isCompleted',
      false,
    );

    if (data.isEmpty) return [];

    return data.entries
        .map(
          (e) => RaceTimingModel.fromJson(Map<String, dynamic>.from(e.value)),
        )
        .toList();
  }

  Stream<RaceTimingModel?> watchRaceTimingByBib(String bib) {
    return _firebase.streamDocument('$raceTimingPath/$bib').map((data) {
      if (data == null || data.isEmpty) return null;
      return RaceTimingModel.fromJson(data);
    });
  }
}
