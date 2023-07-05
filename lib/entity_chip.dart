import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'vendor/widget_arrows.dart';

class EntityChip extends StatelessWidget {
  final Entity entity;

  const EntityChip(this.entity, {super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                flex: 6,
                child: ArrowElement(
                  id: entity.name,
                  targetIds: entity.dependsOn.map((key, value) => MapEntry(
                      key, colors.primary.withOpacity(value.toDouble() * 0.8))),
                  sourceAnchor: Alignment.topCenter,
                  targetAnchor: Alignment.bottomCenter,
                  tipLength: 0,
                  width: 4,
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
                                    child: Container(
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
              ),
              const Spacer(),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
