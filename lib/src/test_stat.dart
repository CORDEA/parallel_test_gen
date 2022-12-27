class TestStat {
  const TestStat({
    required this.path,
    required this.concurrency,
    required this.fileStats,
  });

  final String path;
  final int concurrency;
  final List<List<TestFileStat>> fileStats;
}

class TestFileStat {
  const TestFileStat(this.path, this.duration);

  final String path;
  final Duration duration;
}
