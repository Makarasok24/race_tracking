import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/domain/repositories/race_timing_repository.dart';

class RaceTimingProvider extends ChangeNotifier {
  final RaceTimingRepository repository;

  Map<String, List<RaceSegmentModel>> _participantsBySegment = {
    'swim': [],
    't1': [],
    'bike': [],
    't2': [],
    'run': [],
    'finished': [],
  };

  bool _isLoading = true;
  String _errorMessage = '';

  RaceTimingProvider({required this.repository}) {
    loadAllSegmentData();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<RaceSegmentModel> getParticipantsBySegment(String segmentId) =>
      _participantsBySegment[segmentId] ?? [];

  // Load all segment data
  Future<void> loadAllSegmentData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Reset data
      _participantsBySegment = {
        'swim': [],
        't1': [],
        'bike': [],
        't2': [],
        'run': [],
        'finished': [],
      };

      // Load all segments
      await Future.wait([
        _loadSegment('swim'),
        _loadSegment('t1'),
        _loadSegment('bike'),
        _loadSegment('t2'),
        _loadSegment('run'),
        _loadSegment('finished'),
      ]);

      _isLoading = false;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading race data: $e';
      notifyListeners();
    }
  }

  // Load participants for a specific segment
  Future<void> _loadSegment(String segmentId) async {
    try {
      final participants = await repository.getParticipantsBySegment(segmentId);
      _participantsBySegment[segmentId] = participants;
      notifyListeners();
    } catch (e) {
      print('Error loading segment $segmentId: $e');
    }
  }

  Future<void> startParticipant(String bib) async {
    try {
      await repository.startParticipantRace(bib);
      await _loadSegment('swim'); 
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error starting participant: $e';
      notifyListeners();
    }
  }

  // Complete a segment for a participant
  Future<void> completeSegment(String bib, String segmentId) async {
    try {
      await repository.completeParticipant(bib, segmentId);

      // Determine the next segment
      String nextSegment;
      switch (segmentId) {
        case 'swim':
          nextSegment = 't1';
          break;
        case 't1':
          nextSegment = 'bike';
          break;
        case 'bike':
          nextSegment = 't2';
          break;
        case 't2':
          nextSegment = 'run';
          break;
        case 'run':
          nextSegment = 'finished';
          break;
        default:
          nextSegment = 'finished';
      }

      // Reload both segments
      await _loadSegment(segmentId);
      await _loadSegment(nextSegment);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error completing segment: $e';
      notifyListeners();
    }
  }

  // Get a single participant's timing
  Future<RaceSegmentModel?> getParticipantTiming(String bib) async {
    try {
      return await repository.getRaceTimingByBib(bib);
    } catch (e) {
      _errorMessage = 'Error getting participant timing: $e';
      notifyListeners();
      return null;
    }
  }
}
