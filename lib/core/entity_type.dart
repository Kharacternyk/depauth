class EntityType {
  final int value;

  const EntityType(this.value);

  @override
  operator ==(Object other) => other is EntityType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
