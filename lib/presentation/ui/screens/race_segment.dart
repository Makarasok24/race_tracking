import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/presentation/provider/race_timing_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/segment_card.dart';
import 'package:race_tracking/presentation/ui/screens/segment_timer_screen.dart';

class RaceSegment extends StatefulWidget {
  const RaceSegment({super.key});

  @override
  State<RaceSegment> createState() => _RaceSegmentState();
}

class _RaceSegmentState extends State<RaceSegment> {
  Timer? _globalTimer;
  String _globalTimeDisplay = "00:00:00";
  int? _globalStartTime;

  @override
  void initState() {
    super.initState();
    // Load data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RaceTimingProvider>(context, listen: false);
      provider.loadAllSegmentData();

      // Start global timer if active participants exist
      _checkAndStartGlobalTimer(provider);
    });
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    super.dispose();
  }

  void _checkAndStartGlobalTimer(RaceTimingProvider provider) {
    // Check if any segments have participants
    bool hasActiveParticipants = false;
    for (String segment in ['swim', 't1', 'bike', 't2', 'run']) {
      if (provider.getParticipantsBySegment(segment).isNotEmpty) {
        hasActiveParticipants = true;
        break;
      }
    }

    // If there are active participants, start the global timer
    if (hasActiveParticipants) {
      // Find the earliest global start time
      _globalStartTime = _findEarliestStartTime(provider);

      if (_globalStartTime != null) {
        _startGlobalTimer();
      }
    }
  }

  int? _findEarliestStartTime(RaceTimingProvider provider) {
    int? earliest;

    // Check all segments for the earliest start time
    for (String segmentId in ['swim', 't1', 'bike', 't2', 'run']) {
      final participants = provider.getParticipantsBySegment(segmentId);

      for (var participant in participants) {
        if (participant.globalStartTime != null &&
            (earliest == null || participant.globalStartTime! < earliest)) {
          earliest = participant.globalStartTime;
        }
      }
    }

    return earliest;
  }

  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_globalStartTime == null) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - _globalStartTime!;

      // Format hh:mm:ss
      final seconds = (elapsed / 1000).floor() % 60;
      final minutes = (elapsed / (1000 * 60)).floor() % 60;
      final hours = (elapsed / (1000 * 60 * 60)).floor();

      setState(() {
        _globalTimeDisplay =
            "${hours.toString().padLeft(2, '0')}:"
            "${minutes.toString().padLeft(2, '0')}:"
            "${seconds.toString().padLeft(2, '0')}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceTimingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Race Segments",
              style: TextStyle(color: RTAColors.white),
            ),
            backgroundColor: RTAColors.primary,
            centerTitle: true,
            titleTextStyle: RTATextStyles.title,
          ),
          body: Column(
            children: [
              // Global Timer Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RTAColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Global Race Time",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _globalTimeDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // Segments List
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.errorMessage.isNotEmpty
                        ? Center(child: Text(provider.errorMessage))
                        : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: _buildSegmentList(provider),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentList(RaceTimingProvider provider) {
    // Define segments to display
    final segments = [
      {
        'id': 'swim',
        'title': 'Swimming',
        'imagePath': 'assets/images/swimming.png',
      },
      {
        'id': 'bike',
        'title': 'Cycling',
        'imagePath': 'assets/images/cycling.png',
      },
      {
        'id': 'run',
        'title': 'Running',
        'imagePath': 'assets/images/running.png',
      },
    ];

    return ListView.separated(
      itemCount: segments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final segment = segments[index];
        final segmentId = segment['id']!;

        // Get participants for this segment
        final participants = provider.getParticipantsBySegment(segmentId);

        // Determine status
        String status = "Pending";
        if (participants.isNotEmpty) {
          status = "Active";

          // Check if all participants have completed this segment
          bool allCompleted = true;
          for (var participant in participants) {
            if (!participant.isCompleted) {
              allCompleted = false;
              break;
            }
          }

          if (allCompleted && participants.isNotEmpty) {
            status = "Completed";
          }
        }

        return GestureDetector(
          onTap: () {
            // Navigate to segment timer screen when tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => SegmentTimerScreen(
                      segmentId: segmentId,
                      title: segment['title']!,
                    ),
              ),
            );
          },
          child: SegmentCard(
            title: segment['title']!,
            status: status,
            imagePath: segment['imagePath']!,
            participantCount: participants.length,
          ),
        );
      },
    );
  }
}
