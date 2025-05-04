import 'package:flutter/material.dart';
import 'package:race_tracking/model/race_segment_model.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/ui/screens/segment_timer_screen.dart';

class SegmentCard extends StatelessWidget {
  final RaceSegmentModel segment;

  const SegmentCard({super.key, required this.segment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SegmentTimerScreen(segment: segment),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: RTAColors.backgroundAccent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                segment.imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              segment.title,
              style: TextStyle(
                fontSize: 18,
                color: RTAColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
