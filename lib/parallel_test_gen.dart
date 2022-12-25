import 'dart:io';

int calculate() {
  return 6 * 7;
}

Future<List<TestFileStat>> listTestStats({required String path}) async {
  final files = await _listFiles(path: path);
  final stopwatch = Stopwatch();
  final result = <TestFileStat>[];
  for (final file in files) {
    stopwatch.start();
    final r = await Process.run('dart', ['test', file.path]);
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

class TestFileStat {
  const TestFileStat(this.path, this.duration);

  final String path;
  final Duration duration;
}
