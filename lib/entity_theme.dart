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

  ColorScheme get _colors {
    final color = _color;

    if (_schemes[color] case ColorScheme scheme) {
      return scheme;
    }

    final scheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
    );

    _schemes[color] = scheme;

    return scheme;
  }

  IconData get _icon {
    return switch (value) {
      1 => Icons.cloud,
      2 => Icons.password,
      3 => Icons.fingerprint,
      4 => Icons.phone,
      5 => Icons.devices,
      6 => Icons.widgets,
      7 => Icons.settings_applications,
      _ => Icons.category,
    };
  }

  Color get _color {
    return switch (value) {
      1 => Colors.blue,
      2 => Colors.black,
      3 => Colors.green,
      4 => Colors.deepPurple,
      5 => Colors.teal,
      6 => Colors.grey,
      7 => Colors.lightGreen,
      _ => Colors.yellow,
    };
  }

  static final _schemes = <Color, ColorScheme>{};
}
