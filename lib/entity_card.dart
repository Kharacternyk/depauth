import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'fractional_padding.dart';

class EntityCard extends StatelessWidget {
  final Entity entity;

  const EntityCard(this.entity, {super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    final colors = Theme.of(context).colorScheme;

    return FractionalPadding(
      childSizeFactor: 6,
        child: Card(
          elevation: 10,
          margin: EdgeInsets.zero,
          shape: const Border(),
          child: Column(
            children: [
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
                              switch (entity.type) {
                                EntityType.hardwareKey => Icons.key,
                                EntityType.webService => Icons.web,
                                EntityType.person => Icons.person
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
              Expanded(
                child: FittedBox(
                  child: Container(
                    padding: padding,
                    child: Text(entity.name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
