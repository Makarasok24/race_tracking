import 'package:flutter/material.dart';
import 'package:race_tracking/data/dummy_data.dart';
import 'package:race_tracking/theme/theme.dart';
import 'package:race_tracking/widgets/segment_card.dart';

class RaceSegment extends StatelessWidget {
  const RaceSegment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Race Segments", style: TextStyle(color: RTAColors.white)),
        backgroundColor: RTAColors.primary,
        centerTitle: true,
        titleTextStyle: RTATextStyles.heading,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          itemCount: segmentDatas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final segment = segmentDatas[index];
            return SegmentCard(
              title: segment.title,
              imagePath: segment.imagePath,
            );
          },
        ),
      ),
    );
  }
}
