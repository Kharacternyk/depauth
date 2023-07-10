import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:depauth/db.dart';
import 'package:depauth/types.dart';

class DbBenchmark extends BenchmarkBase {
  final Db db = Db();
  DbBenchmark() : super('Db');

  @override
  void exercise() {
    db.getEntity(const EntityId(1));
  }
}

void main() {
  DbBenchmark().report();
}
