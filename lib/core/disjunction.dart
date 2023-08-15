import 'proposition.dart';

class Disjunction<T> implements Proposition<T> {
  final Set<T> terms;

  const Disjunction(this.terms);

  @override
  getValue(getTermValue) => terms.any(getTermValue);

  @override
  getProbability(getTermProbability) {
    double inverseProbability = 1;

    for (final term in terms) {
      inverseProbability *= 1 - getTermProbability(term);
    }

    return 1 - inverseProbability;
  }
}
