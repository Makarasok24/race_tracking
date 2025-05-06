import 'package:race_tracking/data/models/race_segment_model.dart';

abstract class RaceTimingRepository {
  Future<void> startParticipantRace(String bib);
  Future<void> completeParticipant(String bib, String segmentId);
  Future<RaceSegmentModel?> getRaceTimingByBib(String bib);
  Future<List<RaceSegmentModel>> getActiveParticipants();
  Future<List<RaceSegmentModel>> getParticipantsBySegment(String segmentId);
  Future<RaceSegmentModel?> watchRaceTimingByBib(String bib);
}