import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/domain/entities/participant.dart';
import 'package:race_tracking/presentation/provider/race_timing_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/ui/screens/result_screen.dart';

class SegmentTimerScreen extends StatefulWidget {
  final String segmentId;
  final String title;
  final bool isFirstSegment;

  const SegmentTimerScreen({
    Key? key,
    required this.segmentId,
    required this.title,
    this.isFirstSegment = false,
  }) : super(key: key);

  @override
  State<SegmentTimerScreen> createState() => _SegmentTimerScreenState();
}

class _SegmentTimerScreenState extends State<SegmentTimerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _displayTimer;
  String _displayTime = "00:00:00";

  // Track completed participants locally
  Map<String, String> _completedTimes = {};

  // Get image based on segment ID
  String get _getSegmentImage {
    switch (widget.segmentId) {
      case 'swim':
        return 'assets/images/swimming.png';
      case 'bike':
        return 'assets/images/cycling.png';
      case 'run':
        return 'assets/images/running.png';
      case 't1':
        return 'assets/images/transition.jpg';
      case 't2':
        return 'assets/images/transition.jpg';
      case 'finished':
        return 'assets/images/finish.png';
      default:
        return 'assets/images/swimming.png';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RaceTimingProvider>(context, listen: false);

      // Load segment data
      provider.loadAllSegmentData();

      // Load all participants
      if (widget.segmentId == 'swim') {
        provider.loadAllParticipants();
      }

      // Start display timer if race is started
      if (provider.isRaceStarted && provider.globalStartTime != null) {
        _startDisplayTimer(provider.globalStartTime!);
      }
    });
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startDisplayTimer(int startTimeMs) {
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - startTimeMs;

      // Format as hh:mm:ss
      final seconds = (elapsed / 1000).floor() % 60;
      final minutes = (elapsed / (1000 * 60)).floor() % 60;
      final hours = (elapsed / (1000 * 60 * 60)).floor();

      setState(() {
        _displayTime =
            "${hours.toString().padLeft(2, '0')}:"
            "${minutes.toString().padLeft(2, '0')}:"
            "${seconds.toString().padLeft(2, '0')}";
      });
    });
  }

  // Show confirmation message when participant moves to next segment
  void _showMoveToNextSegmentConfirmation(
    String bibNumber,
    String nextSegmentName,
  ) {
    final snackBar = SnackBar(
      content: Text(
        'Participant #$bibNumber moved to $nextSegmentName segment',
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Helper method to determine next segment name
  String _getNextSegmentName(String currentSegment) {
    switch (currentSegment) {
      case 'swim':
        return 'Transition 1';
      case 't1':
        return 'Bike';
      case 'bike':
        return 'Transition 2';
      case 't2':
        return 'Run';
      case 'run':
        return 'Finished';
      default:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceTimingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              // Dynamic segment image and header
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange[300],
                  image: DecorationImage(
                    image: AssetImage(_getSegmentImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Race Tracking APP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Global Timer Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _displayTime,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    // Show start race button only for swimming segment and if race hasn't started
                    if (widget.segmentId == 'swim' && !provider.isRaceStarted)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Get current timestamp
                            final startTime =
                                DateTime.now().millisecondsSinceEpoch;

                            // Update provider
                            provider.startRace(startTime);

                            // Start local timer
                            _startDisplayTimer(startTime);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('START RACE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Participant list
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSimpleParticipantList(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleParticipantList(RaceTimingProvider provider) {
    List<dynamic> participants;

    // Use appropriate method based on segment
    if (widget.segmentId == 'swim') {
      participants = provider.getSwimmingParticipants();
    } else {
      participants = provider.getParticipantsBySegment(widget.segmentId);
    }

    // Filter by search query if needed
    var filteredParticipants = participants;
    if (_searchQuery.isNotEmpty) {
      filteredParticipants =
          participants
              .where(
                (p) => (p is Participant ? p.bib : p.id).toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    if (filteredParticipants.isEmpty) {
      return const Center(child: Text("No participants in this segment"));
    }

    return ListView.builder(
      itemCount: filteredParticipants.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final participant = filteredParticipants[index];
        final String bibNumber =
            participant is Participant ? participant.bib : participant.id;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Bib number
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    bibNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Spacing
              const Spacer(),

              // Either show time or finish button
              // FIXED: Check if participant is finished or in finished segment
              (provider.isParticipantFinished(bibNumber) ||
                      widget.segmentId == 'finished')
                  ? Text(
                    _completedTimes.containsKey(bibNumber)
                        ? _completedTimes[bibNumber]!
                        : "Completed",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  )
                  : _completedTimes.containsKey(bibNumber)
                  ? Text(
                    _completedTimes[bibNumber]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                  : SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed:
                          provider.isRaceStarted
                              ? () async {
                                // Store a reference to the current BuildContext that won't change
                                final currentContext = context;

                                // Calculate time from race start
                                final segmentTime = _calculateTimeFromStart(
                                  provider.globalStartTime!,
                                );

                                // Update local state immediately
                                setState(() {
                                  _completedTimes[bibNumber] = segmentTime;
                                });

                                // Get next segment name
                                String nextSegmentName = _getNextSegmentName(
                                  widget.segmentId,
                                );

                                try {
                                  // Process the completion - this might take time
                                  await provider.completeSegment(
                                    bibNumber,
                                    widget.segmentId,
                                  );

                                  // Check if widget is still mounted before showing UI
                                  if (!mounted) return;

                                  if (widget.segmentId == 'run') {
                                    if (mounted) {
                                      showDialog(
                                        context: currentContext,
                                        barrierDismissible: false,
                                        builder:
                                            (dialogContext) => AlertDialog(
                                              title: const Text(
                                                'Race Completed!',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.emoji_events,
                                                    color: Colors.amber,
                                                    size: 48,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Participant #$bibNumber has finished the race!',
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Total time: $segmentTime',
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Results have been saved.',
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                  },
                                                  child: Text('Continue'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                    Navigator.push(
                                                      dialogContext,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) =>
                                                                ResultScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: Text('View Results'),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  } else {
                                    // Show simple confirmation for other segments
                                    if (mounted) {
                                      _showMoveToNextSegmentConfirmation(
                                        bibNumber,
                                        nextSegmentName,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Handle errors, show error message if widget still mounted
                                  if (mounted) {
                                    ScaffoldMessenger.of(
                                      currentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Finish'),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  String _calculateTimeFromStart(int startTimeMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - startTimeMs;

    // Format as mm:ss.ms
    final seconds = (elapsed / 1000).floor() % 60;
    final minutes = (elapsed / (1000 * 60)).floor();
    final milliseconds = ((elapsed % 1000) ~/ 10);

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}."
        "${milliseconds.toString().padLeft(2, '0')}";
  }
}
