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
          join('test', 'fixtures', '2', '1_test.dart'),
          Duration.zero,
        ),
      ],
      [
        TestFileStat(
          join('test', 'fixtures', '2', '2_test.dart'),
          Duration.zero,
        ),
        TestFileStat(
          join('test', 'fixtures', '2', '4_test.dart'),
          Duration.zero,
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
    final path = join('test', 'fixtures', '1');
    final result = await listTestStats(TestRunner(), path: path);

    expect(result, hasLength(3));
    expect(result[0].path, join('test', 'fixtures', '1', '1_test.dart'));
    expect(result[0].duration, isNot(Duration.zero));
    expect(result[1].path, join('test', 'fixtures', '1', '2_test.dart'));
    expect(result[1].duration, isNot(Duration.zero));
    expect(result[2].path, join('test', 'fixtures', '1', '3_test.dart'));
    expect(result[2].duration, isNot(Duration.zero));
  });

  group('optimize', () {
    final stats = [
      TestFileStat('1', Duration(seconds: 1)),
      TestFileStat('2', Duration(seconds: 4)),
      TestFileStat('3', Duration(seconds: 5)),
      TestFileStat('4', Duration(seconds: 6)),
      TestFileStat('5', Duration(seconds: 8)),
      TestFileStat('6', Duration(seconds: 5)),
      TestFileStat('7', Duration(seconds: 10)),
      TestFileStat('8', Duration(seconds: 2)),
      TestFileStat('9', Duration(seconds: 6)),
      TestFileStat('10', Duration(seconds: 7)),
    ];

    test('with concurrency is 1', () {
      final result = optimize(path: 'path', stats: stats, concurrency: 1);

      expect(result.concurrency, 1);

      expect(result.fileStats, hasLength(1));
      expect(result.fileStats[0], hasLength(10));
    });

    test('with concurrency is 3', () {
      final result = optimize(path: 'path', stats: stats, concurrency: 3);

      expect(result.concurrency, 3);

      final statsResult = result.fileStats;
      expect(statsResult, hasLength(3));
      expect(statsResult[0][0].path, '7'); // 10
      expect(statsResult[0][1].path, '3'); // 15
      expect(statsResult[0][2].path, '8'); // 17
      expect(statsResult[0][3].path, '1'); // 18

      expect(statsResult[1][0].path, '5'); // 8
      expect(statsResult[1][1].path, '9'); // 14
      expect(statsResult[1][2].path, '2'); // 18

      expect(statsResult[2][0].path, '10'); // 7
      expect(statsResult[2][1].path, '4'); // 13
      expect(statsResult[2][2].path, '6'); // 18
    });

    test('with concurrency is 10', () {
      final result =
          optimize(path: 'path', stats: stats, concurrency: 10).fileStats;

      expect(result, hasLength(10));
    });

    test('with concurrency is 11', () {
      var hasError = false;
      try {
        optimize(path: 'path', stats: stats, concurrency: 11);
      } catch (_) {
        hasError = true;
      }

      expect(hasError, true);
    });
  });
}
