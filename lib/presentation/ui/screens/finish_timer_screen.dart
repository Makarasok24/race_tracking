import 'dart:async';

import 'package:flutter/material.dart';
import 'package:race_tracking/presentation/theme/theme.dart';
import 'package:race_tracking/presentation/widgets/participant_row.dart';

class FinishTimerScreen extends StatefulWidget {
  const FinishTimerScreen({super.key});

  @override
  State<FinishTimerScreen> createState() => _FinishTimerScreenState();
}

class _FinishTimerScreenState extends State<FinishTimerScreen> {
  Duration _duration = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _startTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now().subtract(_duration);
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _duration = DateTime.now().difference(_startTime!);
        });
      });
    });
  }

  void stopTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
    });
  }

  void resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _duration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMilliseconds = (duration.inMilliseconds % 1000 ~/ 10)
        .toString()
        .padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes % 60)}:"
        "${twoDigits(duration.inSeconds % 60)}:"
        "$twoDigitMilliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finish Timer"),
        titleTextStyle: RTATextStyles.title,
        centerTitle: true,
        backgroundColor: RTAColors.primary,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 30, color: RTAColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Icon(Icons.timer, size: 50, color: RTAColors.white),
                  const SizedBox(width: 10),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(
                      fontSize: 40,
                      color: RTAColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: 10, // Replace with your actual participant count
                separatorBuilder:
                    (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return ParticipantRow(
                    text: "Finish",
                    onPressed: () => _startTimer(),
                  ); // Replace with your actual participant row widget
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
