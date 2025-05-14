import 'package:flutter/material.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/presentation/theme/theme.dart';

class ParticipantTimer extends StatelessWidget {
  final RaceSegmentModel participant;
  final Function(String) onFinish;
  final bool showFinishButton;

  const ParticipantTimer({
    Key? key,
    required this.participant,
    required this.onFinish,
    this.showFinishButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format duration if available
    String durationText = participant.formatDuration();
    
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
                    color: participant.isCompleted ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            if (showFinishButton && !participant.isCompleted)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RTAColors.primary,
                ),
                onPressed: () => onFinish(participant.id),
                child: const Text(
                  "Finish",
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}