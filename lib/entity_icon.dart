import 'package:flutter/material.dart';

import 'types.dart';

ColorScheme _getScheme(Color color) =>
    ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);

final _green = _getScheme(Colors.green);
final _grey = _getScheme(Colors.blueGrey);
final _red = _getScheme(Colors.red);

class EntityIcon extends StatelessWidget {
  final Entity entity;
  final EdgeInsets padding;

  const EntityIcon(this.entity, {required this.padding, super.key});

  @override
  build(context) {
    final colors = switch (entity.type) {
      EntityType.hardwareKey => _green,
      EntityType.webService => _grey,
      EntityType.person => _red,
    };

    return Material(
      color: colors.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              child: Padding(
                padding: padding,
                child: Icon(
                  switch (entity.type) {
                    EntityType.hardwareKey => Icons.key,
                    EntityType.webService => Icons.web,
                    EntityType.person => Icons.person,
                  },
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
