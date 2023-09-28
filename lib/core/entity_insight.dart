class EntityInsight {
  final bool hasLostFactor;
  final bool areAllFactorsCompromised;
  final int ancestorCount;
  final int descendantCount;

  const EntityInsight({
    required this.hasLostFactor,
    required this.areAllFactorsCompromised,
    required this.ancestorCount,
    required this.descendantCount,
  });
}
