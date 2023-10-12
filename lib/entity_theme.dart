import 'package:flutter/material.dart';

import 'core/entity_type.dart';
import 'scaled_line.dart';
import 'widget_extension.dart';

extension EntityTheme on EntityType {
  Widget get banner {
    return Ink(
      color: _colors.primaryContainer,
      child: Icon(
        _icon,
        color: _colors.onPrimaryContainer,
      ).pad(const EdgeInsets.all(8)).fit.grow,
    );
  }

  Widget pointingBanner({required String name, required String target}) {
    return ScaledLine(
      name: name,
      color: _colors.primary.withOpacity(.5),
      targetName: target,
      child: banner,
    );
  }

  Widget chip(String name) {
    return AbsorbPointer(
      child: Chip(
        avatar: Ink(
          child: Icon(_icon, color: _colors.primary),
        ),
        label: Text(name),
      ),
    );
  }

  Widget starRibbon(int starCount) {
    return Material(
      color: _colors.primary,
      child: [
        for (var i = 0; i < starCount; ++i)
          Icon(Icons.star, color: _colors.onPrimary).fit.grow.expand(),
      ].column,
    );
  }

  IconData get _icon {
    return switch (this) {
      EntityType.generic => Icons.category,
      EntityType.webService => Icons.cloud,
      EntityType.knowledge => Icons.password,
      EntityType.biometrics => Icons.fingerprint,
      EntityType.phoneNumber => Icons.phone,
      EntityType.device => Icons.devices,
      EntityType.application => Icons.widgets,
      EntityType.operatingSystem => Icons.settings_applications,
    };
  }

  ColorScheme get _colors {
    return switch (this) {
      EntityType.generic => _seedScheme(Colors.yellow),
      EntityType.webService => _seedScheme(Colors.blue),
      EntityType.knowledge => _seedScheme(Colors.black),
      EntityType.biometrics => _seedScheme(Colors.green),
      EntityType.phoneNumber => _seedScheme(Colors.deepPurple),
      EntityType.device => _seedScheme(Colors.teal),
      EntityType.application => _seedScheme(Colors.grey),
      EntityType.operatingSystem => _seedScheme(Colors.lightGreen),
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
