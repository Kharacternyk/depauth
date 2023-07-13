import 'package:flutter/material.dart';

import 'entity_theme.dart';
import 'types.dart';

class EntityIcon extends StatelessWidget {
  final Entity entity;
  final EdgeInsets padding;

  const EntityIcon(this.entity, {required this.padding, super.key});

  @override
  build(context) {
    final theme = EntityTheme(entity);

    return Ink(
      color: theme.background,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: FittedBox(
                    child: Padding(
                      padding: padding,
                      child: Icon(
                        theme.icon,
                        color: theme.foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
