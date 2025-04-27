import 'package:flutter/material.dart';
import 'package:race_tracking/theme/theme.dart';

class RaceForm extends StatelessWidget {
  const RaceForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timer", style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.heading,
      ),
    );
  }
}
