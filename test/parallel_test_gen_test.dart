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
      [
        TestFileStat(
          id: '',
          path: join('test', 'fixtures', '2', '1_test.dart'),
          duration: Duration.zero,
        ),
      ],
      [
        TestFileStat(
          id: '',
          path: join('test', 'fixtures', '2', '2_test.dart'),
          duration: Duration.zero,
        ),
        TestFileStat(
          id: '',
          path: join('test', 'fixtures', '2', '4_test.dart'),
          duration: Duration.zero,
        ),
      ],
    ];

    await runTests(
      runner,
      TestStat(
        path: join('test', 'fixtures', '2'),
        concurrency: 0,
        fileStats: stats,
      ),
    );

    verify(
      () => runner.run(paths: [
        join('test', 'fixtures', '2', '1_test.dart'),
        join('test', 'fixtures', '2', '3_test.dart'),
      ]),
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
      expect(e.id, isNotEmpty);
      expect(e.duration, isNot(Duration.zero));
    }
  });

  group('optimize', () {
    final stats = [
      TestFileStat(
        id: 'id1',
        path: 'path1',
        duration: Duration(seconds: 1),
      ),
      TestFileStat(
        id: 'id2',
        path: 'path2',
        duration: Duration(seconds: 4),
      ),
      TestFileStat(
        id: 'id3',
        path: 'path3',
        duration: Duration(seconds: 5),
      ),
      TestFileStat(
        id: 'id4',
        path: 'path4',
        duration: Duration(seconds: 6),
      ),
      TestFileStat(
        id: 'id5',
        path: 'path5',
        duration: Duration(seconds: 8),
      ),
      TestFileStat(
        id: 'id6',
        path: 'path6',
        duration: Duration(seconds: 5),
      ),
      TestFileStat(
        id: 'id7',
        path: 'path7',
        duration: Duration(seconds: 10),
      ),
      TestFileStat(
        id: 'id8',
        path: 'path8',
        duration: Duration(seconds: 2),
      ),
      TestFileStat(
        id: 'id9',
        path: 'path9',
        duration: Duration(seconds: 6),
      ),
      TestFileStat(
        id: 'id10',
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

      expect(result.fileStats, hasLength(1));
      expect(result.fileStats[0], hasLength(10));
    });

    test('with concurrency is 3', () {
      final result = optimize(
        directory: Directory('path'),
        stats: stats,
        concurrency: 3,
      );

      expect(result.concurrency, 3);

      final statsResult = result.fileStats;
      expect(statsResult, hasLength(3));
      expect(statsResult[0][0].id, 'id7'); // 10
      expect(statsResult[0][0].path, 'path7');
      expect(statsResult[0][1].id, 'id3'); // 15
      expect(statsResult[0][1].path, 'path3');
      expect(statsResult[0][2].id, 'id8'); // 17
      expect(statsResult[0][3].id, 'id1'); // 18

      expect(statsResult[1][0].id, 'id5'); // 8
      expect(statsResult[1][1].id, 'id9'); // 14
      expect(statsResult[1][2].id, 'id2'); // 18

      expect(statsResult[2][0].id, 'id10'); // 7
      expect(statsResult[2][1].id, 'id4'); // 13
      expect(statsResult[2][2].id, 'id6'); // 18
    });

    test('with concurrency is 10', () {
      final result = optimize(
        directory: Directory('path'),
        stats: stats,
        concurrency: 10,
      ).fileStats;

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
