abstract class Proposition<T> {
  bool getValue(bool Function(T) getTermValue);
  double getProbability(double Function(T) getTermProbability);
}
