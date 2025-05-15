import 'package:race_tracking/data/data_sources/firebase_race_timing_data_source.dart';
import 'package:race_tracking/data/data_sources/firebase_result_data_source.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/data/models/race_timing_model.dart';
import 'package:race_tracking/data/models/result_model.dart';
import 'package:race_tracking/data/models/segment_timing_model.dart';
import 'package:race_tracking/domain/repositories/race_timing_repository.dart';

class RaceTimingRepositoryImpl implements RaceTimingRepository {
  final FirebaseRaceTimingDataSource dataSource;
  final FirebaseResultDataSource? resultDataSource;

  RaceTimingRepositoryImpl({required this.dataSource, this.resultDataSource});

  @override
  Future<void> startParticipantRace(String bib) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create initial race timing model - no race ID required
    final raceTiming = RaceTimingModel(
      participantBib: bib,
      raceId:
          "default", 
      globalStartTime: now,
      currentSegment: "swim",
      isCompleted: false,
      swim: SegmentTimingModel(
        segmentId: "swim",
        start: now,
        distance: 1, // Default swim distance in km
        isCompleted: false,
      ),
    );

    // Add to data source
    return dataSource.addRaceTiming(raceTiming);
  }

  @override
  Future<void> completeParticipant(String bib, String segmentId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      print("Starting completeParticipant for bib: $bib, segment: $segmentId");

      // Fetch current race timing data
      final timing = await dataSource.getRaceTimingByBib(bib);
      if (timing == null) {
        throw Exception("No race timing found for participant $bib");
      }

      // Mark the current segment as completed
      Map<String, dynamic> segmentData = {'isCompleted': true, 'end': now};

      // Calculate duration based on segment type
      if (segmentId == "swim" && timing.swim?.start != null) {
        segmentData['duration'] = now - timing.swim!.start!;
      } else if (segmentId == "bike" && timing.bike?.start != null) {
        segmentData['duration'] = now - timing.bike!.start!;
      } else if (segmentId == "run" && timing.run?.start != null) {
        segmentData['duration'] = now - timing.run!.start!;
      } else if (segmentId == "t1" && timing.t1?.start != null) {
        segmentData['duration'] = now - timing.t1!.start!;
      } else if (segmentId == "t2" && timing.t2?.start != null) {
        segmentData['duration'] = now - timing.t2!.start!;
      }

      // Update the segment
      print("Updating segment data for $bib/$segmentId: $segmentData");
      await dataSource.updateSegment(bib, segmentId, segmentData);

      // Determine the next segment
      String nextSegment = _getNextSegment(segmentId);
      print("Next segment for $bib: $nextSegment");

      // If race is finished
      if (nextSegment == "finished") {
        // Calculate total time
        int totalTime = 0;
        if (timing.globalStartTime != null) {
          totalTime = now - timing.globalStartTime!;
        }

        // Update race to completed
        final completeData = {
          'currentSegment': 'finished',
          'isCompleted': true,
          'totalTime': totalTime,
        };

        print("Race finished for $bib with data: $completeData");
        await dataSource.updateRaceTiming(bib, completeData);

        // If we have a result data source, save the results
        if (resultDataSource != null) {
          try {
            // Extract segment times
            int? swimTime, bikeTime, runTime, t1Time, t2Time;
            double? swimSpeed, bikeSpeed, runSpeed;

            // Calculate segment times and speeds
            if (timing.swim != null && timing.swim!.duration != null) {
              swimTime = timing.swim!.duration;
              if (timing.swim!.distance != null) {
                swimSpeed = _calculateSpeed(timing.swim!.distance!, swimTime!);
              }
            }

            if (timing.bike != null && timing.bike!.duration != null) {
              bikeTime = timing.bike!.duration;
              if (timing.bike!.distance != null) {
                bikeSpeed = _calculateSpeed(timing.bike!.distance!, bikeTime!);
              }
            }

            if (timing.run != null && timing.run!.duration != null) {
              runTime = timing.run!.duration;
              if (timing.run!.distance != null) {
                runSpeed = _calculateSpeed(timing.run!.distance!, runTime!);
              }
            }

            if (timing.t1 != null && timing.t1!.duration != null) {
              t1Time = timing.t1!.duration;
            }

            if (timing.t2 != null && timing.t2!.duration != null) {
              t2Time = timing.t2!.duration;
            }

            // Create result model - rank is provisional (will need a separate process to update ranks)
            final result = ResultModel(
              bib: bib,
              name: null, // Will be populated from participants collection
              totalTime: totalTime,
              rank: 1, // Provisional rank, needs updating
              swimTime: swimTime,
              bikeTime: bikeTime,
              runTime: runTime,
              t1Time: t1Time,
              t2Time: t2Time,
              swimSpeed: swimSpeed,
              bikeSpeed: bikeSpeed,
              runSpeed: runSpeed,
              finishTime: now,
            );

            // Save the result
            await resultDataSource!.addResult(bib, result);
            print("✅ Saved result for participant $bib");
          } catch (e) {
            print("❌ Error saving result: $e");
          }
        }

        return;
      }

      // Start next segment
      Map<String, dynamic> nextSegmentData = {'currentSegment': nextSegment};

      // Add appropriate segment data based on next segment
      if (nextSegment == "t1") {
        nextSegmentData['t1'] = {
          'start': now,
          'isCompleted': false,
          'transitionId': 't1',
        };
      } else if (nextSegment == "bike") {
        nextSegmentData['bike'] = {
          'start': now,
          'isCompleted': false,
          'segmentId': 'bike',
          'distance': 20.0, // Default distance in km
        };
      } else if (nextSegment == "t2") {
        nextSegmentData['t2'] = {
          'start': now,
          'isCompleted': false,
          'transitionId': 't2',
        };
      } else if (nextSegment == "run") {
        nextSegmentData['run'] = {
          'start': now,
          'isCompleted': false,
          'segmentId': 'run',
          'distance': 5.0, // Default distance in km
        };
      }

      // Update with the next segment data
      print(
        "Moving participant $bib to segment $nextSegment with data: $nextSegmentData",
      );
      await dataSource.updateRaceTiming(bib, nextSegmentData);
      print(
        "✅ Successfully moved participant $bib from $segmentId to $nextSegment",
      );
    } catch (e) {
      print("❌ Error in completeParticipant: $e");
      throw Exception("Failed to complete segment: $e");
    }
  }

  // Helper method to calculate speed in km/h
  double _calculateSpeed(double distanceKm, int durationMs) {
    if (durationMs == 0) return 0;
    final hours = durationMs / 3600000; // Convert ms to hours
    return distanceKm / hours;
  }

  @override
  Future<RaceSegmentModel?> getRaceTimingByBib(String bib) async {
    final raceTiming = await dataSource.getRaceTimingByBib(bib);
    if (raceTiming == null) return null;

    return _convertToRaceSegmentModel(raceTiming);
  }

  @override
  Future<List<RaceSegmentModel>> getActiveParticipants() async {
    final participants = await dataSource.getActiveParticipants();
    return participants.map((p) => _convertToRaceSegmentModel(p)).toList();
  }

  @override
  Future<List<RaceSegmentModel>> getParticipantsBySegment(
    String segmentId,
  ) async {
    final participants = await dataSource.getParticipantsBySegment(segmentId);
    return participants.map((p) => _convertToRaceSegmentModel(p)).toList();
  }

  @override
  Future<RaceSegmentModel?> watchRaceTimingByBib(String bib) async {
    final raceTiming = await dataSource.getRaceTimingByBib(bib);
    if (raceTiming == null) return null;

    return _convertToRaceSegmentModel(raceTiming);
  }

  // Helper method to determine the next segment
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

  // Convert from RaceTimingModel to RaceSegmentModel
  RaceSegmentModel _convertToRaceSegmentModel(RaceTimingModel model) {
    // Determine segment type from current segment
    segment segmentType;
    String imagePath;
    String title;

    switch (model.currentSegment) {
      case 'swim':
        segmentType = segment.swimming;
        imagePath = 'assets/images/swim.png';
        title = 'Swimming';
        break;
      case 'bike':
        segmentType = segment.cycling;
        imagePath = 'assets/images/bike.png';
        title = 'Cycling';
        break;
      case 'run':
        segmentType = segment.running;
        imagePath = 'assets/images/run.png';
        title = 'Running';
        break;
      case 't1':
        segmentType = segment.swimming; // Closest match
        imagePath = 'assets/images/transition.png';
        title = 'Transition 1';
        break;
      case 't2':
        segmentType = segment.cycling; // Closest match
        imagePath = 'assets/images/transition.png';
        title = 'Transition 2';
        break;
      default:
        segmentType = segment.running; // Default
        imagePath = 'assets/images/finish.png';
        title = 'Finished';
    }

    // Determine status
    String status = model.isCompleted ? 'Completed' : 'In Progress';

    // Convert timestamps to DateTime
    DateTime? startTime;
    DateTime? endTime;
    Duration? duration;

    // Extract timing data based on current segment
    if (model.currentSegment == 'swim' && model.swim != null) {
      if (model.swim!.start != null) {
        startTime = DateTime.fromMillisecondsSinceEpoch(model.swim!.start!);
      }
      if (model.swim!.end != null) {
        endTime = DateTime.fromMillisecondsSinceEpoch(model.swim!.end!);
      }
      if (model.swim!.duration != null) {
        duration = Duration(milliseconds: model.swim!.duration!);
      }
    } else if (model.currentSegment == 'bike' && model.bike != null) {
      if (model.bike!.start != null) {
        startTime = DateTime.fromMillisecondsSinceEpoch(model.bike!.start!);
      }
      if (model.bike!.end != null) {
        endTime = DateTime.fromMillisecondsSinceEpoch(model.bike!.end!);
      }
      if (model.bike!.duration != null) {
        duration = Duration(milliseconds: model.bike!.duration!);
      }
    } else if (model.currentSegment == 'run' && model.run != null) {
      if (model.run!.start != null) {
        startTime = DateTime.fromMillisecondsSinceEpoch(model.run!.start!);
      }
      if (model.run!.end != null) {
        endTime = DateTime.fromMillisecondsSinceEpoch(model.run!.end!);
      }
      if (model.run!.duration != null) {
        duration = Duration(milliseconds: model.run!.duration!);
      }
    } else if (model.currentSegment == 't1' && model.t1 != null) {
      if (model.t1!.start != null) {
        startTime = DateTime.fromMillisecondsSinceEpoch(model.t1!.start!);
      }
      if (model.t1!.end != null) {
        endTime = DateTime.fromMillisecondsSinceEpoch(model.t1!.end!);
      }
      if (model.t1!.duration != null) {
        duration = Duration(milliseconds: model.t1!.duration!);
      }
    } else if (model.currentSegment == 't2' && model.t2 != null) {
      if (model.t2!.start != null) {
        startTime = DateTime.fromMillisecondsSinceEpoch(model.t2!.start!);
      }
      if (model.t2!.end != null) {
        endTime = DateTime.fromMillisecondsSinceEpoch(model.t2!.end!);
      }
      if (model.t2!.duration != null) {
        duration = Duration(milliseconds: model.t2!.duration!);
      }
    }

    // Create and return the model
    return RaceSegmentModel(
      id: model.participantBib,
      title: title,
      imagePath: imagePath,
      status: status,
      segmentType: segmentType,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      participants: [], 
    );
  }

  @override
  Future<void> addParticipantToSegment(String bib, String segmentId) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Get current timing data for the participant
      final timing = await dataSource.getRaceTimingByBib(bib);

      if (timing == null) {
        throw Exception('Participant not found');
      }

      // Create next segment data with proper field name
      Map<String, dynamic> nextSegmentData = {'currentSegment': segmentId};

      // Add appropriate segment data based on segment type
      if (segmentId == "t1") {
        nextSegmentData['t1'] = {
          'start': now,
          'isCompleted': false,
          'transitionId': 't1',
        };
      } else if (segmentId == "bike") {
        nextSegmentData['bike'] = {
          'start': now,
          'isCompleted': false,
          'segmentId': 'bike',
          'distance': 20.0,
        };
      } else if (segmentId == "t2") {
        nextSegmentData['t2'] = {
          'start': now,
          'isCompleted': false,
          'transitionId': 't2',
        };
      } else if (segmentId == "run") {
        nextSegmentData['run'] = {
          'start': now,
          'isCompleted': false,
          'segmentId': 'run',
          'distance': 5.0,
        };
      } else if (segmentId == "swim") {
        nextSegmentData['swim'] = {
          'start': now,
          'isCompleted': false,
          'segmentId': 'swim',
          'distance': 0.75,
        };
      }
      // Print debug information
      print("✅ Added participant $bib to segment $segmentId");

      return dataSource.updateRaceTiming(bib, nextSegmentData);
    } catch (e) {
      print("❌ Error adding participant to segment: $e");
      throw Exception('Failed to add participant to segment: $e');
    }
  }

  @override
  Future<void> clearAllRaceTimings() async {
    return dataSource.clearAllRaceTimings();
  }

  @override
  Future<void> createInitialSwimEntry(String bib) async {
    final raceTiming = RaceTimingModel(
      participantBib: bib,
      raceId: "default",
      currentSegment: "swim", // Always start in swimming
      isCompleted: false,
      swim: SegmentTimingModel(
        segmentId: "swim",
        distance: 0.75, // Default swim distance in km
        isCompleted: false,
      ),
    );

    return dataSource.addRaceTiming(raceTiming);
  }

  @override
  Future<List<String>> getAllParticipantBibs() async {
    return dataSource.getAllParticipantBibs();
  }

  @override
  Future<RaceTimingModel?> getRaceTimingRaw(String bib) async {
    return dataSource.getRaceTimingByBib(bib);
  }
}
