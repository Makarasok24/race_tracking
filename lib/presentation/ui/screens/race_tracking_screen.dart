import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/participant_row.dart';

class RaceTrackingScreen extends StatefulWidget {
  final String segmentTitle;
  final String segmentImage;
  const RaceTrackingScreen({
    super.key,
    required this.segmentTitle,
    required this.segmentImage,
  });

  @override
  State<RaceTrackingScreen> createState() => _RaceTrackingScreenState();
}

class _RaceTrackingScreenState extends State<RaceTrackingScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;

  final List<Map<String, dynamic>> participants = [
    {"name": "John Doe", "bib": "001", "finished": false, "finishTime": null},
    {"name": "Jane Smith", "bib": "002", "finished": false, "finishTime": null},
    {
      "name": "Alex Johnson",
      "bib": "003",
      "finished": false,
      "finishTime": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _markFinished(int index) {
    setState(() {
      participants[index]["finished"] = true;
      participants[index]["finishTime"] = _formatTime(_elapsedSeconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.segmentTitle} Tracking",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: RTAColors.primary,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_circle_left),
          color: RTAColors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                widget.segmentImage,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: RTAColors.neutralDark,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Icon(Iconsax.timer_14, size: 50, color: RTAColors.white),
                  const SizedBox(width: 10),
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Text(
            //   "Elapsed Time: ${_formatTime(_elapsedSeconds)}",
            //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return ParticipantRow(
                    bib: participant["bib"],
                    finished: participant["finished"],
                    finishTime: participant["finishTime"],
                    onPressed: () => _markFinished(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
