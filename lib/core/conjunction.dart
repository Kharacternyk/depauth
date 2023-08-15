import 'disjunction.dart';
import 'proposition.dart';

class Conjunction<T> implements Proposition<T> {
  final List<Disjunction<T>> disjunctions;

  const Conjunction(this.disjunctions);

  @override
  getValue(getTermValue) {
    return disjunctions.every((disjunction) {
      return disjunction.getValue(getTermValue);
    });
  }

  @override
  getProbability(getTermProbability) =>
      _getProbability(disjunctions, getTermProbability);

  double _getProbability(
    List<Disjunction<T>> disjunctions,
    double Function(T) getTermProbability,
  ) {
    double probability = 0;

    for (var i = 0; i < disjunctions.length; ++i) {
      probability += disjunctions[i].getProbability(getTermProbability);
      probability -= _getProbability(
        disjunctions.sublist(0, i).map((disjunction) {
          return Disjunction(disjunction.terms.union(disjunctions[i].terms));
        }).toList(),
        getTermProbability,
      );
    }

    return probability;
  }
}
