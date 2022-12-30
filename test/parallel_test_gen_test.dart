import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:parallel_test_gen/parallel_test_gen.dart';
import 'package:parallel_test_gen/src/runner.dart';
import 'package:parallel_test_gen/src/test_stat.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

class MockTestRunner extends Mock implements TestRunner {}

void main() {
  test('runTests', () async {
    final runner = MockTestRunner();
    when(() => runner.run(paths: any(named: 'paths')))
        .thenAnswer((_) => Future.value(ProcessResult(0, 0, null, null)));

    final stats = [
      TestFileStatGroup(
        'id1',
        [
          TestFileStat(
            path: join('test', 'fixtures', '2', '1_test.dart'),
            duration: Duration.zero,
          ),
        ],
      ),
      TestFileStatGroup(
        'id2',
        [
          TestFileStat(
            path: join('test', 'fixtures', '2', '2_test.dart'),
            duration: Duration.zero,
          ),
          TestFileStat(
            path: join('test', 'fixtures', '2', '4_test.dart'),
            duration: Duration.zero,
          ),
        ],
      ),
    ];

    await runTests(
      runner: runner,
      stat: TestStat(
        path: join('test', 'fixtures', '2'),
        concurrency: 0,
        groups: stats,
      ),
      id: 'id1',
    );

    verify(
      () => runner.run(paths: [
        join('test', 'fixtures', '2', '1_test.dart'),
        join('test', 'fixtures', '2', '3_test.dart'),
      ]),
    );

    await runTests(
      runner: runner,
      stat: TestStat(
        path: join('test', 'fixtures', '2'),
        concurrency: 0,
        groups: stats,
      ),
      id: 'id2',
    );

    verify(
      () => runner.run(paths: [
        join('test', 'fixtures', '2', '2_test.dart'),
        join('test', 'fixtures', '2', '4_test.dart'),
      ]),
    );
  });

  test('listTestStats', () async {
    final directory = Directory(join('test', 'fixtures', '1'));
    final result = await listTestStats(TestRunner(), directory);

    expect(result, hasLength(3));
    expect(
      result.indexWhere(
        (e) => e.path == join('test', 'fixtures', '1', '1_test.dart'),
      ),
      isNot(-1),
    );
    expect(
      result.indexWhere(
        (e) => e.path == join('test', 'fixtures', '1', '2_test.dart'),
      ),
      isNot(-1),
    );
    expect(
      result.indexWhere(
        (e) => e.path == join('test', 'fixtures', '1', '3_test.dart'),
      ),
      isNot(-1),
    );
    for (final e in result) {
      expect(e.duration, isNot(Duration.zero));
    }
  });

  group('optimize', () {
    final stats = [
      TestFileStat(
        path: 'path1',
        duration: Duration(seconds: 1),
      ),
      TestFileStat(
        path: 'path2',
        duration: Duration(seconds: 4),
      ),
      TestFileStat(
        path: 'path3',
        duration: Duration(seconds: 5),
      ),
      TestFileStat(
        path: 'path4',
        duration: Duration(seconds: 6),
      ),
      TestFileStat(
        path: 'path5',
        duration: Duration(seconds: 8),
      ),
      TestFileStat(
        path: 'path6',
        duration: Duration(seconds: 5),
      ),
      TestFileStat(
        path: 'path7',
        duration: Duration(seconds: 10),
      ),
      TestFileStat(
        path: 'path8',
        duration: Duration(seconds: 2),
      ),
      TestFileStat(
        path: 'path9',
        duration: Duration(seconds: 6),
      ),
      TestFileStat(
        path: 'path10',
        duration: Duration(seconds: 7),
      ),
    ];

    test('with concurrency is 1', () {
      final result = optimize(
        directory: Directory('path'),
        stats: stats,
        concurrency: 1,
      );

      expect(result.concurrency, 1);

      expect(result.groups, hasLength(1));
      expect(result.groups[0].fileStats, hasLength(10));
    });

    test('with concurrency is 3', () {
      final result = optimize(
        directory: Directory('path'),
        stats: stats,
        concurrency: 3,
      );

      expect(result.concurrency, 3);

      final statsResult = result.groups;
      expect(statsResult, hasLength(3));
      expect(statsResult[0].fileStats[0].path, 'path7'); // 10
      expect(statsResult[0].fileStats[1].path, 'path3'); // 15
      expect(statsResult[0].fileStats[2].path, 'path8'); // 17
      expect(statsResult[0].fileStats[3].path, 'path1'); // 18

      expect(statsResult[1].fileStats[0].path, 'path5'); // 8
      expect(statsResult[1].fileStats[1].path, 'path9'); // 14
      expect(statsResult[1].fileStats[2].path, 'path2'); // 18

      expect(statsResult[2].fileStats[0].path, 'path10'); // 7
      expect(statsResult[2].fileStats[1].path, 'path4'); // 13
      expect(statsResult[2].fileStats[2].path, 'path6'); // 18
    });

    test('with concurrency is 10', () {
      final result = optimize(
        directory: Directory('path'),
        stats: stats,
        concurrency: 10,
      ).groups;

      expect(result, hasLength(10));
    });

    test('with concurrency is 11', () {
      var hasError = false;
      try {
        optimize(
          directory: Directory('path'),
          stats: stats,
          concurrency: 11,
        );
      } catch (_) {
        hasError = true;
      }

      expect(hasError, true);
    });
  });
}
