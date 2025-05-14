class RaceControlModel {
  final bool isRaceStarted;
  final int? globalStartTime; // timestamp when race started
  final String currentActiveSegment; // e.g., "swim", "t1", "bike", etc.
  final Map<String, String>
  segmentSequence; // defines the flow between segments

  RaceControlModel({
    this.isRaceStarted = false,
    this.globalStartTime,
    this.currentActiveSegment = "swim",
    this.segmentSequence = const {
      "swim": "t1",
      "t1": "bike",
      "bike": "t2",
      "t2": "run",
      "run": "finished",
    },
  });

  // Get the next segment in the sequence
  String getNextSegment(String currentSegment) {
    return segmentSequence[currentSegment] ?? "finished";
  }
}
