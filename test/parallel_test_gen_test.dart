
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
}
