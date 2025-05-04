import 'package:race_tracking/data/data_sources/firebase_participant_data_source.dart';
import 'package:race_tracking/data/models/participant_model.dart';
import 'package:race_tracking/domain/entities/participant.dart';
import 'package:race_tracking/domain/repositories/participant_repository.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  final FirebaseParticipantDataSource dataSource;

  ParticipantRepositoryImpl({required this.dataSource});

  @override
  Future<void> addParticipant(Participant participant) {
    final model = ParticipantModel.fromEntity(participant);
    return dataSource.addParticipant(model);
  }

  @override
  Future<List<Participant>> getAllParticipants() async {
    final models = await dataSource.getAllParticipants();
    return models;
  }
}
