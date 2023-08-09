import 'package:flutter/material.dart';

import 'core/entity_type.dart';
import 'entity_theme.dart';
import 'widget_extension.dart';

class EntityIcon extends StatelessWidget {
  final EntityType type;
  final EdgeInsets padding;

  const EntityIcon(this.type, {required this.padding, super.key});

  @override
  build(context) {
    final theme = EntityTheme(type);

    return Ink(
      color: theme.background,
      child: Icon(
        theme.icon,
        color: theme.foreground,
      ).pad(padding).fit().grow(),
    );
  }
}
