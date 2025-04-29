import 'package:flutter/material.dart';
import 'package:race_tracking/model/race_segment_model.dart';
import 'package:race_tracking/theme/theme.dart';
import 'package:race_tracking/ui/screens/finish_timer_screen.dart';
import 'package:race_tracking/ui/screens/start_timer_screen.dart';

class SegmentTimerScreen extends StatelessWidget {
  final RaceSegmentModel segment;

  const SegmentTimerScreen({super.key, required this.segment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${segment.title} Timer",
          style: TextStyle(color: RTAColors.white),
        ),
        titleTextStyle: RTATextStyles.title,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 30, color: RTAColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: RTAColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                segment.imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Start Timer",
                  style: TextStyle(
                    fontSize: 20,
                    color: RTAColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size(100, 40),
                    minimumSize: const Size(100, 40),
                    foregroundColor: RTAColors.white,
                    backgroundColor: RTAColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartTimerScreen(),
                      ),
                    );
                  },
                  child: const Text("Start"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Finish Timer",
                  style: TextStyle(
                    fontSize: 20,
                    color: RTAColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    maximumSize: const Size(100, 40),
                    minimumSize: const Size(100, 40),
                    foregroundColor: RTAColors.white,
                    backgroundColor: RTAColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinishTimerScreen(),
                      ),
                    );
                  },
                  child: const Text("Finish"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
