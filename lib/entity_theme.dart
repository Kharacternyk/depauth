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
  static final _orange = _seedScheme(Colors.orange);
  static final _purple = _seedScheme(Colors.deepPurple);
  static final _teal = _seedScheme(Colors.teal);
  static final _grey = _seedScheme(Colors.grey);
  static final _pink = _seedScheme(Colors.pink);
  static final _lime = _seedScheme(Colors.lime);

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
  static final _webService = _fromScheme(_blue, Icons.cloud, 'Web Service');
  static final _knowledge =
      _fromScheme(_red, Icons.pattern, 'Secret Knowledge (Passwords)');
  static final _biometrics =
      _fromScheme(_pink, Icons.fingerprint, 'Biometrics');
  static final _hardwareKey = _fromScheme(_green, Icons.key, 'Hardware Key');
  static final _phoneNumber = _fromScheme(_purple, Icons.phone, 'Phone Number');
  static final _device = _fromScheme(_teal, Icons.devices, 'Device');
  static final _application = _fromScheme(_grey, Icons.widgets, 'Application');
  static final _paymentInformation =
      _fromScheme(_orange, Icons.credit_card, 'Payment Information');
  static final _operatingSystem =
      _fromScheme(_lime, Icons.settings_applications, 'Operating System');

  factory EntityTheme(EntityType type) {
    return switch (type) {
      EntityType.generic => _generic,
      EntityType.hardwareKey => _hardwareKey,
      EntityType.webService => _webService,
      EntityType.knowledge => _knowledge,
      EntityType.biometrics => _biometrics,
      EntityType.phoneNumber => _phoneNumber,
      EntityType.device => _device,
      EntityType.application => _application,
      EntityType.paymentInformation => _paymentInformation,
      EntityType.operatingSystem => _operatingSystem,
    };
  }
}
