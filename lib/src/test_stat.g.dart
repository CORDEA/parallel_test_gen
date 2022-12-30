// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestFileStat _$TestFileStatFromJson(Map<String, dynamic> json) => TestFileStat(
      path: json['path'] as String,
      duration: Duration(microseconds: json['duration'] as int),
    );

Map<String, dynamic> _$TestFileStatToJson(TestFileStat instance) =>
    <String, dynamic>{
      'path': instance.path,
      'duration': instance.duration.inMicroseconds,
    };

TestFileStatGroup _$TestFileStatGroupFromJson(Map<String, dynamic> json) =>
    TestFileStatGroup(
      json['id'] as String,
      (json['fileStats'] as List<dynamic>)
          .map((e) => TestFileStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TestFileStatGroupToJson(TestFileStatGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileStats': instance.fileStats,
    };

TestStat _$TestStatFromJson(Map<String, dynamic> json) => TestStat(
      path: json['path'] as String,
      concurrency: json['concurrency'] as int,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => TestFileStatGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TestStatToJson(TestStat instance) => <String, dynamic>{
      'path': instance.path,
      'concurrency': instance.concurrency,
      'groups': instance.groups,
    };
