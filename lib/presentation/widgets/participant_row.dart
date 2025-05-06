import 'package:flutter/material.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/primary_button.dart';

class ParticipantRow extends StatelessWidget {
  const ParticipantRow({
    super.key,
    required this.bib,
    required this.finished,
    required this.finishTime,
    required this.onPressed,
  });

  final String bib;
  final bool finished;
  final String? finishTime;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: RTAColors.primary.withOpacity(0.1),
          child: Text(bib, style: TextStyle(color: RTAColors.primary)),
        ),
        title: finished && finishTime != null ? Text("$finishTime") : null,
        trailing: PrimaryButton(
          text: finished ? "Finished" : "Finish",
          onPressed: finished ? () {} : onPressed,
        ),
      ),
    );
  }
}
