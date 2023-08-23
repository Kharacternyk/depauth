class EntityInsight {
  final bool hasLostFactor;
  final bool areAllFactorsCompromised;
  final int ancestorCount;
  final int descendantCount;
  final double coupling;

  const EntityInsight({
    required this.hasLostFactor,
    required this.areAllFactorsCompromised,
    required this.ancestorCount,
    required this.descendantCount,
    required this.coupling,
  });
}
