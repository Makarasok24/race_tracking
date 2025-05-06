class ResultModel {
  final int totalTime;
  final int rank;

  ResultModel({
    required this.totalTime,
    required this.rank,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
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