import 'dart:io';

import 'reader.dart';
import 'test_stat.dart';

class TestRunner {
  Future<ProcessResult> run({required List<String> paths}) =>
      Process.run('dart', ['test', paths.join(' ')]);
}

Future<void> runTests(TestRunner runner, TestStat stat) async {
  final group = stat.fileStats
      .map((e) => e.map((e) => e.path).toList())
      .toList(growable: false);
  final current =
      (await listFiles(Directory(stat.path))).map((e) => e.path).toSet();
  final diff = current.difference(group.expand((e) => e).toSet());
  for (int i = 0; i < diff.length; i++) {
    group[i % group.length].add(diff.elementAt(i));
  }
  await Future.wait(group.map((e) => runner.run(paths: e)));
}
