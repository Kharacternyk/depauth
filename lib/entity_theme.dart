import 'package:flutter/material.dart';

import 'core/entity_type.dart';

class EntityTheme {
  final Color background;
  final Color foreground;
  final Color arrow;
  final IconData icon;
  final String typeName;

  EntityTheme._(
    this.background,
    this.foreground,
    this.arrow,
    this.icon,
    this.typeName,
  );

  static ColorScheme _seedScheme(Color seed) {
    return ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
  }

  static final _red = _seedScheme(Colors.red);
  static final _green = _seedScheme(Colors.green);
  static final _blue = _seedScheme(Colors.blue);
  static final _yellow = _seedScheme(Colors.yellow);

  static EntityTheme _fromScheme(
    ColorScheme scheme,
    IconData icon,
    String typeName,
  ) {
    return EntityTheme._(
      scheme.primaryContainer,
      scheme.onPrimaryContainer,
      scheme.primary,
      icon,
      typeName,
    );
  }

  static final _generic =
      _fromScheme(_yellow, Icons.category, 'Generic Entity');
  static final _webService = _fromScheme(_blue, Icons.web, 'Web Service');
  static final _person = _fromScheme(_red, Icons.person, 'Person');
  static final _hardwareKey = _fromScheme(_green, Icons.key, 'Hardware Key');

  factory EntityTheme(EntityType type) {
    return switch (type) {
      EntityType.generic => _generic,
      EntityType.hardwareKey => _hardwareKey,
      EntityType.webService => _webService,
      EntityType.person => _person,
    };
  }
}
