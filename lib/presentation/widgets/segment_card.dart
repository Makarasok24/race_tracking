import 'package:flutter/material.dart';
import 'package:race_tracking/data/models/race_segment_model.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/ui/screens/race_tracking_screen.dart';
import 'package:race_tracking/presentation/widgets/status_badge.dart';

class SegmentCard extends StatelessWidget {
  const SegmentCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.status,
  });

  final String title;
  final String imagePath;
  final String status;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RaceTrackingScreen(
                  segmentTitle: title,
                  segmentImage: imagePath,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: RTAColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: RTAColors.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              // 💡 This makes the title + button take up remaining space
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        color: RTAColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
