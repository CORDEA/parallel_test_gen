import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';

class TestRunner {
  Future<ProcessResult> run({required List<String> paths}) =>
      Process.run('dart', ['test', paths.join(' ')]);
}

int calculate() {
  return 6 * 7;
}

Future<void> runTests(TestRunner runner, TestStat stat) async {
  final group = stat.fileStats
      .map((e) => e.map((e) => e.path).toList())
      .toList(growable: false);
  final current =
      (await _listFiles(path: stat.path)).map((e) => e.path).toSet();
  final diff = current.difference(group.expand((e) => e).toSet());
  for (int i = 0; i < diff.length; i++) {
    group[i % group.length].add(diff.elementAt(i));
  }
  await Future.wait(group.map((e) => runner.run(paths: e)));
}

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
  final files = await _listFiles(path: path);
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

Future<List<FileSystemEntity>> _listFiles({required String path}) {
  return Directory(path)
      .list(recursive: true)
      .where((e) => e.uri.pathSegments.last.endsWith('_test.dart'))
      .toList();
}

class TestStat {
  const TestStat(this.path, this.fileStats);

  final String path;
  final List<List<TestFileStat>> fileStats;
}

class TestFileStat {
  const TestFileStat(this.path, this.duration);

  final String path;
  final Duration duration;
}
