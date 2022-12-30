import 'package:json_annotation/json_annotation.dart';

part 'test_stat.g.dart';

@JsonSerializable()
class TestFileStat {
  const TestFileStat({
    required this.path,
    required this.duration,
  });

  final String path;
  final Duration duration;

  factory TestFileStat.fromJson(Map<String, dynamic> json) =>
      _$TestFileStatFromJson(json);

  Map<String, dynamic> toJson() => _$TestFileStatToJson(this);
}

@JsonSerializable()
class TestFileStatGroup {
  const TestFileStatGroup(this.id, this.fileStats);

  final String id;
  final List<TestFileStat> fileStats;

  factory TestFileStatGroup.fromJson(Map<String, dynamic> json) =>
      _$TestFileStatGroupFromJson(json);

  Map<String, dynamic> toJson() => _$TestFileStatGroupToJson(this);
}

@JsonSerializable()
class TestStat {
  const TestStat({
    required this.path,
    required this.concurrency,
    required this.groups,
  });

  final String path;
  final int concurrency;
  final List<TestFileStatGroup> groups;

  factory TestStat.fromJson(Map<String, dynamic> json) =>
      _$TestStatFromJson(json);

  Map<String, dynamic> toJson() => _$TestStatToJson(this);
}
