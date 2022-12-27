import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';

import 'runner.dart';
import 'test_stat.dart';

TestStat optimize({
  required String path,
  required List<TestFileStat> stats,
  required int concurrent,
}) {
  if (concurrent > stats.length) {
    throw Exception();
  }
  final sorted = Queue<TestFileStat>.from(
    stats.sorted((a, b) => b.duration.compareTo(a.duration)),
  );
  final group = <List<TestFileStat>>[];
  final durations = <Duration>[];
  for (int i = 0; i < concurrent; i++) {
    final f = sorted.removeFirst();
    group.add([f]);
    durations.add(f.duration);
  }
  while (sorted.isNotEmpty) {
    var index = 0;
    final f = sorted.removeFirst();
    var min = Duration(days: 1);
    for (int i = 0; i < concurrent; i++) {
      if (min > durations[i]) {
        min = durations[i];
        index = i;
      }
    }
    group[index].add(f);
    durations[index] += f.duration;
  }
  return TestStat(path, group);
}

Future<List<TestFileStat>> listTestStats(
  TestRunner runner, {
  required String path,
}) async {
  final files = await listFiles(path: path);
  final stopwatch = Stopwatch();
  final result = <TestFileStat>[];
  for (final file in files) {
    stopwatch.start();
    final r = await runner.run(paths: [file.path]);
    final err = r.stderr;
    if (err is String && err.isNotEmpty) {
      stopwatch.reset();
      throw Exception(err);
    }
    result.add(TestFileStat(
      file.path,
      stopwatch.elapsed,
    ));
    stopwatch.reset();
  }
  return result;
}

Future<List<FileSystemEntity>> listFiles({required String path}) {
  return Directory(path)
      .list(recursive: true)
      .where((e) => e.uri.pathSegments.last.endsWith('_test.dart'))
      .toList();
}
