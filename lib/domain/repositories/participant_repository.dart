import '../entities/participant.dart';

abstract class ParticipantRepository {
  Future<void> addParticipant(Participant participant);
  Future<List<Participant>> getAllParticipants();
  // Future<Participant?> getParticipantByBib(String bib);
  // Future<void> updateParticipant(Participant participant);
  // Future<void> deleteParticipant(String bib);
}