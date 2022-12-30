import 'dart:convert';
import 'dart:io';

import 'reader.dart';
import 'test_stat.dart';

class TestRunner {
  const TestRunner();

  Future<ProcessResult> run({required Iterable<String> paths}) =>
      Process.run('dart', ['test', ...paths]);
}

Future<void> runTests({
  required TestRunner runner,
  required TestStat stat,
  required String id,
}) async {
  final current =
      (await listFiles(Directory(stat.path))).map((e) => e.path).toSet();
  final diff = current.difference(stat.groups
      .map((e) => e.fileStats.map((e) => e.path))
      .expand((e) => e)
      .toSet());
  final groups = stat.groups;
  for (int i = 0; i < diff.length; i++) {
    groups[i % groups.length]
        .fileStats
        .add(TestFileStat(path: diff.elementAt(i), duration: Duration.zero));
  }
  final result = await runner.run(
    paths: groups.firstWhere((e) => e.id == id).fileStats.map((e) => e.path),
  );
  if (result.stdout != null) {
    stdout.add(utf8.encode(result.stdout));
  }
  if (result.stderr != null) {
    stderr.add(utf8.encode(result.stderr));
  }
}
