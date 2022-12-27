import 'package:json_annotation/json_annotation.dart';

part 'test_stat.g.dart';

@JsonSerializable()
class TestFileStat {
  const TestFileStat({
    required this.id,
    required this.path,
    required this.duration,
  });

  final String id;
  final String path;
  final Duration duration;

  factory TestFileStat.fromJson(Map<String, dynamic> json) =>
      _$TestFileStatFromJson(json);

  Map<String, dynamic> toJson() => _$TestFileStatToJson(this);
}

@JsonSerializable()
class TestStat {
  const TestStat({
    required this.path,
    required this.concurrency,
    required this.fileStats,
  });

  final String path;
  final int concurrency;
  final List<List<TestFileStat>> fileStats;

  factory TestStat.fromJson(Map<String, dynamic> json) =>
      _$TestStatFromJson(json);

  Map<String, dynamic> toJson() => _$TestStatToJson(this);
}
