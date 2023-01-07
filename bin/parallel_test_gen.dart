import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:parallel_test_gen/parallel_test_gen.dart';
import 'package:parallel_test_gen/src/runner.dart';
import 'package:parallel_test_gen/src/test_stat.dart';
import 'package:path/path.dart';

const _configFile = 'test_config.json';
const runner = TestRunner();

void main(List<String> arguments) {
  CommandRunner('parallel_test_gen', '')
    ..addCommand(_CheckCommand())
    ..addCommand(_TestCommand())
    ..run(arguments);
}

class _CheckCommand extends Command {
  _CheckCommand() {
    argParser.addOption('concurrency', defaultsTo: '1');
  }

  @override
  String get description => 'Check the test status and output the result';

  @override
  String get name => 'check';

  @override
  Future<void> run() async {
    final results = argResults;
    if (results == null) {
      return;
    }
    final directory = results.rest.isEmpty
        ? Directory.current
        : Directory(results.rest.first);
    final stats = await listTestStats(runner, directory);
    final result = optimize(
      directory: directory,
      stats: stats,
      concurrency: int.parse(results['concurrency']),
    );
    final json = jsonEncode(result);
    final file = File(join(directory.path, _configFile));
    await file.writeAsString(json);
  }
}

class _TestCommand extends Command {
  _TestCommand() {
    argParser.addOption('config');
  }

  @override
  String get description => 'Run tests';

  @override
  String get name => 'test';

  @override
  Future<void> run() async {
    final results = argResults;
    if (results == null) {
      return;
    }
    final path =
        results['config'] ?? File(join(Directory.current.path, _configFile));
    final id = results.rest.first;
    final config =
        TestStat.fromJson(jsonDecode(await File(path).readAsString()));
    await runTests(runner: runner, stat: config, id: id);
  }
}
