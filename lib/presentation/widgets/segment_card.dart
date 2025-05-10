import 'package:flutter/material.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/status_badge.dart';

class SegmentCard extends StatelessWidget {
  final String title;
  final String status;
  final String imagePath;
  final int participantCount;

  const SegmentCard({
    Key? key,
    required this.title,
    required this.status,
    required this.imagePath,
    this.participantCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(imagePath, width: 80, height: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$participantCount participants",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: RTAColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
