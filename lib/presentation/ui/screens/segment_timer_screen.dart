import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/presentation/provider/race_timing_provider.dart';
import 'package:race_tracking/presentation/theme/theme.dart';

class SegmentTimerScreen extends StatefulWidget {
  final String segmentId;
  final String title;

  const SegmentTimerScreen({
    Key? key,
    required this.segmentId,
    required this.title,
  }) : super(key: key);

  @override
  State<SegmentTimerScreen> createState() => _SegmentTimerScreenState();
}

class _SegmentTimerScreenState extends State<SegmentTimerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RaceTimingProvider>(context, listen: false);
      provider.loadAllSegmentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceTimingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "${widget.title} Timing",
              style: TextStyle(color: RTAColors.white),
            ),
            backgroundColor: RTAColors.primary,
            centerTitle: true,
            titleTextStyle: RTATextStyles.title,
          ),
          body: Column(
            children: [
              // Search box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by BIB number",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Participant list
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildParticipantList(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantList(RaceTimingProvider provider) {
    final participants = provider.getParticipantsBySegment(widget.segmentId);

    // Filter by search query if needed
    var filteredParticipants = participants;
    if (_searchQuery.isNotEmpty) {
      filteredParticipants =
          participants
              .where(
                (p) => p.id.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }

    if (filteredParticipants.isEmpty) {
      return const Center(child: Text("No participants in this segment"));
    }

    return ListView.builder(
      itemCount: filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = filteredParticipants[index];

        // Format duration if available
        String durationText = "--:--";
        if (participant.startTime != null) {
          final now = DateTime.now();
          final elapsed =
              participant.endTime != null
                  ? participant.endTime!.difference(participant.startTime!)
                  : now.difference(participant.startTime!);

          final minutes = elapsed.inMinutes;
          final seconds = elapsed.inSeconds % 60;
          durationText =
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text("Bib #${participant.id}"),
            subtitle: Text(
              "Started: ${participant.startTime?.toString().substring(11, 19) ?? 'Not started'}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      participant.isCompleted ? "Completed" : "In progress",
                      style: TextStyle(
                        color:
                            participant.isCompleted
                                ? Colors.green
                                : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                if (!participant.isCompleted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RTAColors.primary,
                    ),
                    onPressed: () {
                      provider.completeSegment(
                        participant.id,
                        widget.segmentId,
                      );
                    },
                    child: const Text(
                      "Finish",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
