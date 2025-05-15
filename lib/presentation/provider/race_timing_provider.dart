import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:race_tracking/core/services/notification_service.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/data/models/result_model.dart';
import 'package:race_tracking/domain/entities/participant.dart';
import 'package:race_tracking/domain/repositories/participant_repository.dart';
import 'package:race_tracking/domain/repositories/race_timing_repository.dart';
import 'package:race_tracking/domain/repositories/result_repositry.dart';

class RaceTimingProvider extends ChangeNotifier {
  final RaceTimingRepository repository;
  final ParticipantRepository participantRepository;
  final ResultRepository resultRepository;
  final NotificationService _notificationService;

  List<dynamic> _allParticipants = [];
  Map<String, List<dynamic>> _participantsBySegment = {};
  bool _isLoading = false;
  bool _isRaceStarted = false;
  int? _globalStartTime;
  String _errorMessage = '';

  // Flag to prevent reloading data when navigating between screens
  static bool _isInitialized = false;

  RaceTimingProvider({
    required this.repository,
    required this.participantRepository,
    required this.resultRepository,
    required NotificationService notificationService,
  }) : _notificationService = notificationService {
    // Only load data if not already initialized
    if (!_isInitialized) {
      loadInitialData();
    }
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isRaceStarted => _isRaceStarted;
  int? get globalStartTime => _globalStartTime;
  String get errorMessage => _errorMessage;
  List<dynamic> get allParticipants => _allParticipants;

  // Get participants by segment
  List<dynamic> getParticipantsBySegment(String segmentId) {
    return _participantsBySegment[segmentId] ?? [];
  }

  // Load initial data - only called once
  Future<void> loadInitialData() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      await loadAllParticipants();
      await loadAllSegmentData();

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading initial data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all segment data
  Future<void> loadAllSegmentData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load data for each segment type in parallel
      final loadOperations = <Future>[];
      for (final segmentId in ['swim', 't1', 'bike', 't2', 'run', 'finished']) {
        loadOperations.add(_loadSegment(segmentId));
      }
      await Future.wait(loadOperations);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading segment data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load participants for a specific segment
  Future<void> _loadSegment(String segmentId) async {
    final participants = await repository.getParticipantsBySegment(segmentId);
    _participantsBySegment[segmentId] = participants;
  }

  // Load all participants
  Future<void> loadAllParticipants() async {
    try {
      _allParticipants = await participantRepository.getAllParticipants();
    } catch (e) {
      _errorMessage = 'Error loading participants: $e';
    }
  }

  // Reset race - only call this explicitly, not during navigation
  Future<void> resetRaceToInitialState() async {
    try {
      _isLoading = true;
      _isRaceStarted = false;
      _globalStartTime = null;
      _isInitialized = false;
      notifyListeners();

      // Clear existing race timing and results data
      await repository.clearAllRaceTimings();
      await resultRepository.clearAllResults();

      // Load participants if not loaded yet
      if (_allParticipants.isEmpty) {
        await loadAllParticipants();
      }

      // Create fresh swim entries for all participants
      for (var participant in _allParticipants) {
        await repository.createInitialSwimEntry(participant.bib);
      }

      // Reload segment data
      await loadAllSegmentData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error resetting race: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start the race globally
  Future<void> startRace([int? timestamp]) async {
    if (_isRaceStarted) return; // Race already started

    try {
      // Use provided timestamp or current time
      final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
      _globalStartTime = now;
      _isRaceStarted = true;

      // Update all participants in the swim segment to have started
      final swimParticipants = _participantsBySegment['swim'] ?? [];
      for (var participant in swimParticipants) {
        await startParticipant(participant.id);
      }

      // Send race start notification
      await _notificationService.notifyRaceStart(swimParticipants.length);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error starting race: $e';
      notifyListeners();
    }
  }

  // Start a participant
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

  // Helper method to determine the next segment
  String getNextSegment(String currentSegment) {
    switch (currentSegment) {
      case 'swim':
        return 't1';
      case 't1':
        return 'bike';
      case 'bike':
        return 't2';
      case 't2':
        return 'run';
      case 'run':
        return 'finished';
      default:
        return 'finished';
    }
  }

  // Complete a segment for a participant
  Future<void> completeSegment(String bib, String segmentId) async {
    try {
      // Don't allow completing segments for already finished participants
      if (segmentId == 'finished') {
        return; // No action needed, already finished
      }

      // Complete the current segment
      await repository.completeParticipant(bib, segmentId);

      // Get the next segment
      String nextSegment = getNextSegment(segmentId);

      // If finishing the run segment (race complete)
      if (nextSegment == 'finished') {
        await createResultOnFinish(bib);
      } else {
        // Move to next segment
        await repository.addParticipantToSegment(bib, nextSegment);
      }

      // Reload segment data
      await loadAllSegmentData();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error completing segment: $e';
      notifyListeners();
    }
  }

  // Create result when a participant finishes the race
  Future<void> createResultOnFinish(String bib) async {
    try {
      // Get participant information
      String participantName = '';
      for (var p in _allParticipants) {
        if (p.bib == bib) {
          participantName = p.name ?? '';
          break;
        }
      }

      // Get raw timing data
      final raceTiming = await repository.getRaceTimingRaw(bib);
      if (raceTiming == null) return;

      // Extract segment times
      int? swimTime, bikeTime, runTime, t1Time, t2Time;
      double? swimSpeed, bikeSpeed, runSpeed;

      // Calculate swim time and speed
      if (raceTiming.swim?.start != null && raceTiming.swim?.end != null) {
        swimTime = raceTiming.swim!.end! - raceTiming.swim!.start!;
        if (raceTiming.swim!.distance != null && swimTime > 0) {
          final hours = swimTime / 3600000;
          final calculatedSpeed = raceTiming.swim!.distance! / hours;
          swimSpeed = _capSpeed(calculatedSpeed, 6.0, 2.0, 0.4);
        }
      }

      // Calculate bike time and speed
      if (raceTiming.bike?.start != null && raceTiming.bike?.end != null) {
        bikeTime = raceTiming.bike!.end! - raceTiming.bike!.start!;
        if (raceTiming.bike!.distance != null && bikeTime > 0) {
          final hours = bikeTime / 3600000;
          final calculatedSpeed = raceTiming.bike!.distance! / hours;
          bikeSpeed = _capSpeed(calculatedSpeed, 50.0, 30.0, 10.0);
        }
      }

      // Calculate run time and speed
      if (raceTiming.run?.start != null && raceTiming.run?.end != null) {
        runTime = raceTiming.run!.end! - raceTiming.run!.start!;
        if (raceTiming.run!.distance != null && runTime > 0) {
          final hours = runTime / 3600000;
          final calculatedSpeed = raceTiming.run!.distance! / hours;
          runSpeed = _capSpeed(calculatedSpeed, 25.0, 12.0, 6.0);
        }
      }

      // Calculate transition times
      if (raceTiming.t1?.start != null && raceTiming.t1?.end != null) {
        t1Time = raceTiming.t1!.end! - raceTiming.t1!.start!;
      }

      if (raceTiming.t2?.start != null && raceTiming.t2?.end != null) {
        t2Time = raceTiming.t2!.end! - raceTiming.t2!.start!;
      }

      // Calculate total race time
      int totalTime = 0;
      if (raceTiming.globalStartTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        totalTime = now - raceTiming.globalStartTime!;
      } else if (swimTime != null &&
          bikeTime != null &&
          runTime != null &&
          t1Time != null &&
          t2Time != null) {
        totalTime = swimTime + bikeTime + runTime + t1Time + t2Time;
      }

      // Calculate rank based on existing results
      final existingResults = await resultRepository.getAllResults();
      int rank = 1;
      for (var r in existingResults) {
        if (r.totalTime < totalTime) rank++;
      }

      // Create and save result
      final result = ResultModel(
        bib: bib,
        name: participantName,
        totalTime: totalTime,
        rank: rank,
        swimTime: swimTime,
        bikeTime: bikeTime,
        runTime: runTime,
        t1Time: t1Time,
        t2Time: t2Time,
        swimSpeed: swimSpeed,
        bikeSpeed: bikeSpeed,
        runSpeed: runSpeed,
        finishTime: DateTime.now().millisecondsSinceEpoch,
      );

      await resultRepository.addResult(bib, result);

      // Move participant to finished segment
      await repository.addParticipantToSegment(bib, 'finished');

      // Send finish notification
      await _notificationService.notifyRaceFinish(
        bib,
        participantName,
        rank,
        totalTime,
      );
    } catch (e) {
      _errorMessage = 'Error creating result: $e';
      notifyListeners();
    }
  }

  // Helper method to cap speeds to realistic values
  double _capSpeed(
    double calculatedSpeed,
    double maxSpeed,
    double baseSpeed,
    double variation,
  ) {
    if (calculatedSpeed > maxSpeed) {
      return baseSpeed +
          (DateTime.now().millisecondsSinceEpoch % 10) * variation / 10;
    }
    return calculatedSpeed;
  }

  // Check if participant has finished the race
  bool isParticipantFinished(String bib) {
    final finishedParticipants = _participantsBySegment['finished'] ?? [];
    return finishedParticipants.any((p) => p.id == bib);
  }

  // Get participants for swimming segment
  List<dynamic> getSwimmingParticipants() {
    final swimmers = _participantsBySegment['swim'] ?? [];
    return swimmers.isEmpty ? _allParticipants : swimmers;
  }
}
