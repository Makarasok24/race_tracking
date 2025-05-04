import 'package:flutter/material.dart';
import 'package:race_tracking/presentation/theme/theme.dart';

import '../../theme/theme.dart';

class RaceForm extends StatefulWidget {
  const RaceForm({super.key});

  @override
  State<RaceForm> createState() => _RaceFormState();
}

class _RaceFormState extends State<RaceForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Race Form", style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.heading,
      ),
    );
  }
}
