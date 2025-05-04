class Result {
  final int totalTime;
  final int rank;

  Result({
    required this.totalTime,
    required this.rank,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      totalTime: json['totalTime'] as int,
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTime': totalTime,
      'rank': rank,
    };
  }
}