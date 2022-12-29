import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser();

  final check = parser.addCommand('check');
  check.addOption('concurrency');

  final test = parser.addCommand('test');
  test.addOption('config');
  test.addOption('id');

  final result = parser.parse(arguments);
}
