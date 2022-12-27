class TestStat {
  const TestStat(this.path, this.fileStats);

  final String path;
  final List<List<TestFileStat>> fileStats;
}

class TestFileStat {
  const TestFileStat(this.path, this.duration);

  final String path;
  final Duration duration;
}
