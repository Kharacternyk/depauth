import 'package:flutter/material.dart';

import 'core/entity_type.dart';

extension EntityTheme on EntityType {
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

  ThemeData get theme {
    return switch (this) {
      EntityType.generic => _seedTheme(Colors.yellow),
      EntityType.webService => _seedTheme(Colors.blue),
      EntityType.knowledge => _seedTheme(Colors.red),
      EntityType.biometrics => _seedTheme(Colors.green),
      EntityType.phoneNumber => _seedTheme(Colors.purple),
      EntityType.device => _seedTheme(Colors.teal),
      EntityType.application => _seedTheme(Colors.grey),
      EntityType.paymentInformation => _seedTheme(Colors.orange),
      EntityType.operatingSystem => _seedTheme(Colors.black),
    };
  }

  static ThemeData _seedTheme(Color seed) {
    if (_themes[seed] case ThemeData theme) {
      return theme;
    }

    final theme = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    _themes[seed] = theme;

    return theme;
  }

  static final _themes = <Color, ThemeData>{};
}
