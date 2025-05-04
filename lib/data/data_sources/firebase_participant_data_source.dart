import '../../core/services/firebase_service.dart';
import '../models/participant_model.dart';

class FirebaseParticipantDataSource {
  final FirebaseService _firebase = FirebaseService();
  final String participantPath = 'participants';

  Future<void> addParticipant(ParticipantModel participant) {
    return _firebase.create(
      participantPath,
      participant.bib,
      participant.toJson(),
    );
  }

  Future<List<ParticipantModel>> getAllParticipants() async {
    final data = await _firebase.getAll(participantPath);

    if (data.isEmpty) {
      return [];
    }

    return data.entries.map((e) {
      return ParticipantModel.fromJson(
        e.key,
        Map<String, dynamic>.from(e.value),
      );
    }).toList();
  }
}
