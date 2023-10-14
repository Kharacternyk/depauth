import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/entity_type.dart';
import 'scaled_line.dart';
import 'widget_extension.dart';

extension EntityTheme on EntityType {
  static Iterable<EntityType> knownTypes = [
    for (final (value, _, _, _) in _known) EntityType(value)
  ];

  String name(AppLocalizations messages) => _data.get(value).name(messages);

  Widget get banner {
    final data = _data.get(value);

    return Ink(
      color: data.colors.primaryContainer,
      child: Icon(
        data.icon,
        color: data.colors.onPrimaryContainer,
      ).pad(const EdgeInsets.all(8)).fit.grow,
    );
  }

  Widget pointingBanner({required String name, required String target}) {
    final data = _data.get(value);

    return ScaledLine(
      name: name,
      color: data.colors.primary.withOpacity(.5),
      targetName: target,
      child: banner,
    );
  }

  Widget chip(String name) {
    final data = _data.get(value);

    return AbsorbPointer(
      child: Chip(
        avatar: Ink(
          child: Icon(data.icon, color: data.colors.primary),
        ),
        label: Text(name),
      ),
    );
  }

  Widget starRibbon(int starCount) {
    final data = _data.get(value);

    return Material(
      color: data.colors.primary,
      child: [
        for (var i = 0; i < starCount; ++i)
          Icon(Icons.star, color: data.colors.onPrimary).fit.grow.expand(),
      ].column,
    );
  }

  static final _data = {
    for (final (value, icon, color, name) in _known)
      value: (
        icon: icon,
        colors: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
        ),
        name: name,
      )
  };
  static final _known = [
    (0, Icons.category, Colors.yellow, (_M m) => m.genericType),
    (1, Icons.cloud, Colors.blue, (_M m) => m.type1),
    (2, Icons.password, Colors.black, (_M m) => m.type2),
    (5, Icons.devices, Colors.green, (_M m) => m.type5),
    (6, Icons.widgets, Colors.grey, (_M m) => m.type6),
    (4, Icons.phone, Colors.indigo, (_M m) => m.type4),
    (8, Icons.explore, Colors.deepPurple, (_M m) => m.type8),
    (3, Icons.fingerprint, Colors.teal, (_M m) => m.type3),
    (7, Icons.settings_applications, Colors.lightGreen, (_M m) => m.type7),
  ];
}

extension _Map<K, V> on Map<K, V> {
  V get(K key) => this[key] ?? values.first;
}

typedef _M = AppLocalizations;
