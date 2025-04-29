import 'package:flutter/material.dart';
import 'package:race_tracking/theme/theme.dart';
import 'package:race_tracking/widgets/primary_button.dart';

class ParticipantRow extends StatelessWidget {
  const ParticipantRow({
    super.key,
    required this.onPressed,
    required this.text,
  });
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(color: RTAColors.neutralDark),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("001", style: TextStyle(color: RTAColors.neutralDark)),
          ),
          Text(
            "--:--:--:--",
            style: TextStyle(
              fontSize: 20,
              color: RTAColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          PrimaryButton(text: text, onPressed: onPressed),
        ],
      ),
    );
  }
}
