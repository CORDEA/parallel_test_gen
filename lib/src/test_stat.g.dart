// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestFileStat _$TestFileStatFromJson(Map<String, dynamic> json) => TestFileStat(
      id: json['id'] as String,
      path: json['path'] as String,
      duration: Duration(microseconds: json['duration'] as int),
    );

Map<String, dynamic> _$TestFileStatToJson(TestFileStat instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'duration': instance.duration.inMicroseconds,
    };

TestStat _$TestStatFromJson(Map<String, dynamic> json) => TestStat(
      path: json['path'] as String,
      concurrency: json['concurrency'] as int,
      fileStats: (json['fileStats'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => TestFileStat.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$TestStatToJson(TestStat instance) => <String, dynamic>{
      'path': instance.path,
      'concurrency': instance.concurrency,
      'fileStats': instance.fileStats,
    };
