import 'package:parallel_test_gen/parallel_test_gen.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('listTestStats', () async {
    final path = join('test', 'fixtures', '1');
    final result = await listTestStats(path: path);

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

    test('with concurrent is 1', () {
      final result = optimize(stats, concurrent: 1);

      expect(result, hasLength(1));
      expect(result[0], hasLength(10));
    });

    test('with concurrent is 3', () {
      final result = optimize(stats, concurrent: 3);

      expect(result, hasLength(3));

      expect(result[0][0].path, '7'); // 10
      expect(result[0][1].path, '3'); // 15
      expect(result[0][2].path, '8'); // 17
      expect(result[0][3].path, '1'); // 18

      expect(result[1][0].path, '5'); // 8
      expect(result[1][1].path, '9'); // 14
      expect(result[1][2].path, '2'); // 18

      expect(result[2][0].path, '10'); // 7
      expect(result[2][1].path, '4'); // 13
      expect(result[2][2].path, '6'); // 18
    });

    test('with concurrent is 10', () {
      final result = optimize(stats, concurrent: 10);

      expect(result, hasLength(10));
    });

    test('with concurrent is 11', () {
      var hasError = false;
      try {
        optimize(stats, concurrent: 11);
      } catch (_) {
        hasError = true;
      }

      expect(hasError, true);
    });
  });
}
