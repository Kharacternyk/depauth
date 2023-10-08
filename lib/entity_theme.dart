import 'package:flutter/material.dart';

import 'core/entity_type.dart';

extension EntityTheme on EntityType {
  Color get background => _scheme.primaryContainer;
  Color get foreground => _scheme.onPrimaryContainer;
  Color get primaryColor => _scheme.primary;

  IconData get icon {
    return switch (this) {
      EntityType.generic => Icons.category,
      EntityType.webService => Icons.cloud,
      EntityType.knowledge => Icons.password,
      EntityType.biometrics => Icons.fingerprint,
      EntityType.phoneNumber => Icons.phone,
      EntityType.device => Icons.devices,
      EntityType.application => Icons.widgets,
      EntityType.paymentInformation => Icons.credit_card,
      EntityType.operatingSystem => Icons.settings_applications,
    };
  }

  ColorScheme get _scheme {
    return switch (this) {
      EntityType.generic => _seedScheme(Colors.yellow),
      EntityType.webService => _seedScheme(Colors.blue),
      EntityType.knowledge => _seedScheme(Colors.red),
      EntityType.biometrics => _seedScheme(Colors.green),
      EntityType.phoneNumber => _seedScheme(Colors.purple),
      EntityType.device => _seedScheme(Colors.teal),
      EntityType.application => _seedScheme(Colors.grey),
      EntityType.paymentInformation => _seedScheme(Colors.orange),
      EntityType.operatingSystem => _seedScheme(Colors.black),
    };
  }

  static ColorScheme _seedScheme(Color seed) {
    if (_schemes[seed] case ColorScheme scheme) {
      return scheme;
    }

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    _schemes[seed] = scheme;

    return scheme;
  }

  static final _schemes = <Color, ColorScheme>{};
}
