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
  @override
  void initState() {
    super.initState();
    // Load data from provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<RaceTimingProvider>(context, listen: false);

      // First load participants
      await provider.loadAllParticipants();

      // Then reset race state - moves all to swimming
      // await provider.resetRaceToInitialState();

      print("🔄 Race has been reset - all participants in swimming segment");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper method to navigate to segment timer screen
  void _navigateToSegment(String segmentId, String title, bool isFirstSegment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SegmentTimerScreen(
              segmentId: segmentId,
              title: title,
              isFirstSegment: isFirstSegment,
            ),
      ),
    );
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
    // Define ALL segments to display (including transitions)
    final segments = [
      {
        'id': 'swim',
        'title': 'Swimming',
        'imagePath': 'assets/images/swimming.png',
        'isFirstSegment': true,
      },
      {
        'id': 't1',
        'title': 'Transition 1',
        'imagePath': 'assets/images/transition.jpg',
        'isFirstSegment': false,
      },
      {
        'id': 'bike',
        'title': 'Cycling',
        'imagePath': 'assets/images/cycling.png',
        'isFirstSegment': false,
      },
      {
        'id': 't2',
        'title': 'Transition 2',
        'imagePath': 'assets/images/transition.jpg',
        'isFirstSegment': false,
      },
      {
        'id': 'run',
        'title': 'Running',
        'imagePath': 'assets/images/running.png',
        'isFirstSegment': false,
      },
      {
        'id': 'finished',
        'title': 'Finished',
        'imagePath': 'assets/images/finish.jpg', 
        'isFirstSegment': false,
      },
    ];

    return ListView.separated(
      itemCount: segments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final segment = segments[index];
        final segmentId = segment['id'] as String;

        // Get participants for this segment
        final participants = provider.getParticipantsBySegment(segmentId);

        // Add debug info to see what's happening
        print("Segment $segmentId has ${participants.length} participants");

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

        // Inside your itemBuilder
        return SegmentCard(
          title:
              segment['title']
                  as String, // Fix 1: Use 'segment' not 'segments' and cast to String
          status: status,
          imagePath: segment['imagePath'] as String, // Fix 2: Cast to String
          participantCount: participants.length,
          onTap: () {
            // Navigate to segment timer screen when tapped
            _navigateToSegment(
              segmentId,
              segment['title'] as String, // Fix 3: Cast to String
              segment['isFirstSegment']
                  as bool, // This is fine if your data is really boolean
            );
          },
        );
      },
    );
  }
}
