import 'dart:io';

import 'package:args/args.dart';
import 'package:parallel_test_gen/parallel_test_gen.dart';
import 'package:parallel_test_gen/src/runner.dart';

void main(List<String> arguments) {
  final parser = ArgParser();

  final check = parser.addCommand('check');
  check.addOption('concurrency');

  final test = parser.addCommand('test');
  test.addOption('config');
  test.addOption('id');

  final result = parser.parse(arguments);
  final command = result.command;
  if (command == null) {
    // TODO
    return;
  }

  switch (command.name) {
    case 'check':
      _check(command);
      break;
    case 'test':
      break;
  }
}

Future<void> _check(ArgResults results) async {
  final runner = TestRunner();
  final stats = await listTestStats(
    runner,
    results.rest.isEmpty ? Directory.current : Directory(results.rest.first),
  );
}
