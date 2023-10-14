class EntityType {
  final int value;

  const EntityType(this.value);

  static final Iterable<EntityType> knownTypes =
      List.generate(8, EntityType.new);

  @override
  operator ==(Object other) => other is EntityType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
