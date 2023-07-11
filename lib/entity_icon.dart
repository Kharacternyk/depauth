import 'package:flutter/material.dart';

import 'types.dart';

class EntityIcon extends StatelessWidget {
  final Entity entity;
  final EdgeInsets padding;

  const EntityIcon(this.entity, {required this.padding, super.key});

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;

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
