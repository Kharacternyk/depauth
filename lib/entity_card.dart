import 'package:flutter/material.dart';

import 'types.dart';

class EntityCard extends StatelessWidget {
  final String name;
  final EntityType type;

  const EntityCard({required this.name, required this.type, super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shape: const Border(),
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              child: Container(
                padding: padding,
                child: Text(name),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: colors.primaryContainer,
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      child: Padding(
                        padding: padding,
                        child: Icon(
                          switch (type) {
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
            ),
          ),
        ],
      ),
    );
  }
}
