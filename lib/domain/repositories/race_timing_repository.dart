import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/data/models/race_timing_model.dart';

abstract class RaceTimingRepository {
  Future<void> startParticipantRace(String bib);
  Future<void> completeParticipant(String bib, String segmentId);
  Future<RaceSegmentModel?> getRaceTimingByBib(String bib);
  Future<List<RaceSegmentModel>> getActiveParticipants();
  Future<List<RaceSegmentModel>> getParticipantsBySegment(String segmentId);
  Future<RaceSegmentModel?> watchRaceTimingByBib(String bib);
  Future<void> addParticipantToSegment(String bib, String segmentId);
  // Add these new methods
  Future<void> clearAllRaceTimings();
  Future<void> createInitialSwimEntry(String bib);
  Future<List<String>> getAllParticipantBibs();
  Future<RaceTimingModel?> getRaceTimingRaw(String bib);

}