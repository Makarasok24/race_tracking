import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/participant_model.dart';

class ParticipantService {
  // Dummy API URL (not used in local storage version)
  final String apiUrl = 'https://yourapi.com/participants';

  Future<List<ParticipantModel>> fetchParticipants() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList('participants');
    if (data == null) return [];
    return data
        .map((jsonStr) => ParticipantModel.fromJson(json.decode(jsonStr)))
        .toList();
  }

  Future<void> saveParticipants(List<ParticipantModel> participants) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data =
        participants.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList('participants', data);
  }

  Future<void> deleteParticipant(int bibNumber) async {
    final participants = await fetchParticipants();
    participants.removeWhere((p) => p.bibNumber == bibNumber);
    await saveParticipants(participants);
  }
}
