import 'package:flutter/material.dart';
import 'package:race_tracking/data/models/result_model.dart';
import 'package:race_tracking/domain/repositories/participant_repository.dart';
import 'package:race_tracking/domain/repositories/result_repositry.dart';

class ResultProvider extends ChangeNotifier {
  final ResultRepository _resultRepository;
  final ParticipantRepository _participantRepository;

  List<ResultModel> _results = [];
  List<dynamic> _participants = []; // Cache all participants
  bool _isLoading = false;
  String _errorMessage = '';

  ResultProvider({
    required ResultRepository resultRepository,
    required ParticipantRepository participantRepository,
  }) : _resultRepository = resultRepository,
       _participantRepository = participantRepository;

  List<ResultModel> get results => _results;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadResults() async {
    try {
      _isLoading = true;
      notifyListeners();

      // First load all participants for name lookup
      _participants = await _participantRepository.getAllParticipants();

      // Then load all results
      _results = await _resultRepository.getAllResults();

      // Look up participant names if missing
      for (int i = 0; i < _results.length; i++) {
        if (_results[i].name == null && _results[i].bib != null) {
          final participant = _findParticipantByBib(_results[i].bib!);
          if (participant != null) {
            // Update the result with the participant name
            final updatedResult = ResultModel(
              bib: _results[i].bib,
              name: participant.name,
              totalTime: _results[i].totalTime,
              rank: _results[i].rank,
              swimTime: _results[i].swimTime,
              bikeTime: _results[i].bikeTime,
              runTime: _results[i].runTime,
              t1Time: _results[i].t1Time,
              t2Time: _results[i].t2Time,
              swimSpeed: _results[i].swimSpeed,
              bikeSpeed: _results[i].bikeSpeed,
              runSpeed: _results[i].runSpeed,
              finishTime: _results[i].finishTime,
            );
            _results[i] = updatedResult;
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading results: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to find a participant by bib
  dynamic _findParticipantByBib(String bib) {
    try {
      return _participants.firstWhere((p) => p.bib == bib);
    } catch (e) {
      print("❌ No participant found with bib $bib");
      return null;
    }
  }

}
