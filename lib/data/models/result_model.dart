class ResultModel {
  final String? bib;
  final String? name;
  final int totalTime;
  final int rank;
  final int? swimTime;
  final int? bikeTime;
  final int? runTime;
  final int? t1Time;
  final int? t2Time;
  final double? swimSpeed;
  final double? bikeSpeed;
  final double? runSpeed;
  final int finishTime; // Timestamp when finished

  ResultModel({
    this.bib,
    this.name,
    required this.totalTime,
    required this.rank,
    this.swimTime,
    this.bikeTime,
    this.runTime,
    this.t1Time,
    this.t2Time,
    this.swimSpeed,
    this.bikeSpeed,
    this.runSpeed,
    required this.finishTime,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      bib: json['bib'] as String?,
      name: json['name'] as String?,
      totalTime: json['totalTime'] as int,
      rank: json['rank'] as int,
      swimTime: json['swimTime'] as int?,
      bikeTime: json['bikeTime'] as int?,
      runTime: json['runTime'] as int?,
      t1Time: json['t1Time'] as int?,
      t2Time: json['t2Time'] as int?,
      swimSpeed: (json['swimSpeed'] as num?)?.toDouble(),
      bikeSpeed: (json['bikeSpeed'] as num?)?.toDouble(),
      runSpeed: (json['runSpeed'] as num?)?.toDouble(),
      finishTime: json['finishTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalTime': totalTime,
      'rank': rank,
      'swimTime': swimTime,
      'bikeTime': bikeTime,
      'runTime': runTime,
      't1Time': t1Time,
      't2Time': t2Time,
      'swimSpeed': swimSpeed,
      'bikeSpeed': bikeSpeed,
      'runSpeed': runSpeed,
      'finishTime': finishTime,
    };
  }
}
