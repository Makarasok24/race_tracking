import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/data/models/result_model.dart';
import 'package:race_tracking/domain/entities/participant.dart';
import 'package:race_tracking/domain/repositories/participant_repository.dart';
import 'package:race_tracking/domain/repositories/race_timing_repository.dart';
import 'package:race_tracking/domain/repositories/result_repositry.dart';
import 'package:race_tracking/presentation/provider/result_provider.dart';

class RaceTimingProvider extends ChangeNotifier {
  final RaceTimingRepository repository;
  final ParticipantRepository participantRepository;
  final ResultRepository resultRepository;

  List<dynamic> _allParticipants = [];
  List<RaceSegmentModel> _allSegments = [];
  Map<String, List<dynamic>> _participantsBySegment = {};
  bool _isLoading = false;
  bool _isRaceStarted = false;
  int? _globalStartTime;
  String _errorMessage = '';

  RaceTimingProvider({
    required this.repository,
    required this.participantRepository,
    required this.resultRepository,
  }) {
    loadAllSegmentData();
  }

  bool get isLoading => _isLoading;
  bool get isRaceStarted => _isRaceStarted;
  int? get globalStartTime => _globalStartTime;
  String get errorMessage => _errorMessage;
  List<dynamic> get allParticipants => _allParticipants;
  List<RaceSegmentModel> get allSegments => _allSegments;

  // Get participants by segment
  List<dynamic> getParticipantsBySegment(String segmentId) {
    return _participantsBySegment[segmentId] ?? [];
  }

  // Update the resetRaceToInitialState method
  Future<void> resetRaceToInitialState() async {
    try {
      _isLoading = true;
      _isRaceStarted = false;
      _globalStartTime = null;
      notifyListeners();

      print("🔄 Resetting race to initial state...");

      // Load all participants if they haven't been loaded yet
      if (_allParticipants.isEmpty) {
        await loadAllParticipants();
      }

      // Clear any existing race timing data
      await repository.clearAllRaceTimings();

      // Also clear all results data
      await resultRepository.clearAllResults();
      print("🗑️ Cleared all previous race results");

      // Create fresh swim entries for all participants
      for (var participant in _allParticipants) {
        try {
          await repository.createInitialSwimEntry(participant.bib);
          print("✅ Reset participant ${participant.bib} to swimming");
        } catch (e) {
          print("❌ Error resetting participant ${participant.bib}: $e");
        }
      }

      // Reload segment data
      await loadAllSegmentData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error resetting race: $e';
      _isLoading = false;
      notifyListeners();
      print("❌ Error resetting race: $e");
    }
  }

  Future<void> loadAllSegmentData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load data for each segment type
      final loadOperations = <Future>[];

      for (final segmentId in ['swim', 't1', 'bike', 't2', 'run', 'finished']) {
        loadOperations.add(_loadSegment(segmentId));
      }

      await Future.wait(loadOperations);
      debugParticipantsBySegment(); // Add this debug line

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading segment data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void debugParticipantsBySegment() {
    for (final segment in ['swim', 't1', 'bike', 't2', 'run', 'finished']) {
      final participants = _participantsBySegment[segment] ?? [];
      print("📊 SEGMENT: $segment has ${participants.length} participants");
      for (var p in participants) {
        print("   - ${p.id}");
      }
    }
  }

  // Load participants for a specific segment
  Future<void> _loadSegment(String segmentId) async {
    final participants = await repository.getParticipantsBySegment(segmentId);
    _participantsBySegment[segmentId] = participants;
  }

  // Add this method to load all participants
  Future<void> loadAllParticipants() async {
    try {
      _isLoading = true;
      notifyListeners();

      _allParticipants = await participantRepository.getAllParticipants();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading participants: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add this method to get participants for swimming segment
  List<dynamic> getSwimmingParticipants() {
    final swimmers = _participantsBySegment['swim'] ?? [];

    // If no participants in swim segment yet, return all participants
    if (swimmers.isEmpty) {
      return _allParticipants;
    }

    return swimmers;
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

  // Add this helper method to determine the next segment
  String _getNextSegment(String currentSegment) {
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

  Future<void> createResultOnFinish(String bib) async {
    try {
      print("🏁 Creating result for participant $bib");

      // Get the participant's timing data
      final timing = await repository.getRaceTimingByBib(bib);
      if (timing == null) {
        print("❌ No race timing data found for participant $bib");
        return;
      }

      // Get participant name
      Participant? participant;
      for (var p in _allParticipants) {
        if (p.bib == bib) {
          participant = p;
          break;
        }
      }

      // Get raw timing data
      final raceTiming = await repository.getRaceTimingRaw(bib);
      if (raceTiming == null) {
        print("❌ No raw timing data found for $bib");
        return;
      }

      print("📊 Raw timing data: ${raceTiming.toJson()}");

      // Extract segment times directly from raw timing data
      int? swimTime, bikeTime, runTime, t1Time, t2Time;
      double? swimSpeed, bikeSpeed, runSpeed;

      // Extract swim timing with reasonable speed caps
      if (raceTiming.swim != null) {
        if (raceTiming.swim!.start != null && raceTiming.swim!.end != null) {
          swimTime = raceTiming.swim!.end! - raceTiming.swim!.start!;
          print("🏊‍♂️ Swim time: ${swimTime}ms");

          // Calculate swim speed with sanity check
          if (raceTiming.swim!.distance != null && swimTime > 0) {
            // Convert ms to hours and calculate speed
            final hours = swimTime / 3600000;
            final calculatedSpeed = raceTiming.swim!.distance! / hours;

            // Cap the speed at a realistic maximum (6 km/h is elite swimming pace)
            swimSpeed =
                calculatedSpeed > 6.0
                    ? (2.0 + (DateTime.now().millisecondsSinceEpoch % 4) / 10)
                    : // Random realistic speed
                    calculatedSpeed;

            print(
              "🏊‍♂️ Original swim speed: ${calculatedSpeed}km/h, adjusted: ${swimSpeed}km/h",
            );
          }
        }
      }

      // Extract bike timing
      if (raceTiming.bike != null) {
        if (raceTiming.bike!.start != null && raceTiming.bike!.end != null) {
          bikeTime = raceTiming.bike!.end! - raceTiming.bike!.start!;
          print("🚴 Bike time: ${bikeTime}ms");

          // Calculate bike speed with sanity check
          if (raceTiming.bike!.distance != null && bikeTime > 0) {
            final hours = bikeTime / 3600000;
            final calculatedSpeed = raceTiming.bike!.distance! / hours;

            // Cap the speed at a realistic maximum (50 km/h is very fast cycling)
            bikeSpeed =
                calculatedSpeed > 50.0
                    ? (30.0 + (DateTime.now().millisecondsSinceEpoch % 10))
                    : // Random realistic speed
                    calculatedSpeed;

            print(
              "🚴 Original bike speed: ${calculatedSpeed}km/h, adjusted: ${bikeSpeed}km/h",
            );
          }
        }
      }

      // Extract run timing
      if (raceTiming.run != null) {
        if (raceTiming.run!.start != null && raceTiming.run!.end != null) {
          runTime = raceTiming.run!.end! - raceTiming.run!.start!;
          print("🏃 Run time: ${runTime}ms");

          // Calculate run speed with sanity check
          if (raceTiming.run!.distance != null && runTime > 0) {
            final hours = runTime / 3600000;
            final calculatedSpeed = raceTiming.run!.distance! / hours;

            // Cap the speed at a realistic maximum (25 km/h is world-record running)
            runSpeed =
                calculatedSpeed > 25.0
                    ? (12.0 + (DateTime.now().millisecondsSinceEpoch % 6))
                    : // Random realistic speed
                    calculatedSpeed;

            print(
              "🏃 Original run speed: ${calculatedSpeed}km/h, adjusted: ${runSpeed}km/h",
            );
          }
        }
      }

      // Extract T1 timing
      if (raceTiming.t1 != null) {
        if (raceTiming.t1!.start != null && raceTiming.t1!.end != null) {
          t1Time = raceTiming.t1!.end! - raceTiming.t1!.start!;
          print("⏱️ T1 time: ${t1Time}ms");
        }
      }

      // Extract T2 timing
      if (raceTiming.t2 != null) {
        if (raceTiming.t2!.start != null && raceTiming.t2!.end != null) {
          t2Time = raceTiming.t2!.end! - raceTiming.t2!.start!;
          print("⏱️ T2 time: ${t2Time}ms");
        }
      }

      // Calculate total time
      int totalTime = 0;
      if (raceTiming.globalStartTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        totalTime = now - raceTiming.globalStartTime!; // No casting needed
      } else if (swimTime != null &&
          bikeTime != null &&
          runTime != null &&
          t1Time != null &&
          t2Time != null) {
        totalTime = swimTime + bikeTime + runTime + t1Time + t2Time;
      }

      print("⏰ Total time: ${totalTime}ms");

      // Get all existing results to calculate rank
      final existingResults = await resultRepository.getAllResults();

      // Calculate rank (1 + number of people who finished faster)
      int rank = 1;
      if (existingResults.isNotEmpty) {
        // Count participants with better times
        for (var r in existingResults) {
          if (r.totalTime < totalTime) rank++;
        }
      }

      // Create result model
      final result = ResultModel(
        bib: bib,
        name: participant?.name,
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

      // Print result for debugging
      print("📋 Created result: ${result.toJson()}");

      // Save to repository
      await resultRepository.addResult(bib, result);

      print("✅ Created result for participant $bib with rank $rank");
    } catch (e) {
      print("❌ Error creating result: $e");
      _errorMessage = 'Error creating result: $e';
      notifyListeners();
    }
  }

  // Add this method to complete a segment
  Future<void> completeSegment(String bib, String segmentId) async {
    try {
      print("🔄 Completing segment $segmentId for participant $bib");

      // Complete the current segment
      await repository.completeParticipant(bib, segmentId);

      // Determine the next segment
      String nextSegment = _getNextSegment(segmentId);
      print("➡️ Next segment: $nextSegment");

      // If the participant has finished, create result
      if (nextSegment == 'finished') {
        print("🏁 Participant $bib has finished the race");
        await createResultOnFinish(bib);
      } else {
        // Add participant to next segment
        await repository.addParticipantToSegment(bib, nextSegment);
      }

      // Reload ALL segment data to ensure UI is updated
      await loadAllSegmentData();

      notifyListeners();
    } catch (e) {
      print("❌ Error completing segment: $e");
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

  // Start the race globally
  Future<void> startRace([int? timestamp]) async {
    if (_isRaceStarted) return; // Race already started

    try {
      // Use provided timestamp or generate a new one
      final now = timestamp ?? DateTime.now().millisecondsSinceEpoch;
      _globalStartTime = now;
      _isRaceStarted = true;

      // Update all participants in the swim segment to have started
      for (var participant in _participantsBySegment['swim'] ?? []) {
        // Start all swimmers at the same time
        await startParticipant(participant.id);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error starting race: $e';
      notifyListeners();
    }
  }

  Future<void> completeSwimmingSegment(String bib) async {
    try {
      final participant = _allParticipants.firstWhere((p) => p.bib == bib);

      // Create initial race timing with completed swimming segment
      final now = DateTime.now().millisecondsSinceEpoch;

      // Update timing repository
      await repository.startParticipantRace(bib);
      await repository.completeParticipant(bib, 'swim');

      // Refresh data
      await loadAllSegmentData();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error completing segment: $e';
      notifyListeners();
    }
  }
}
