import 'factor.dart';
import 'storage.dart';

class FactorDigest {
  final Identity<Factor> identity;
  final int threshold;

  const FactorDigest(this.identity, this.threshold);
}
