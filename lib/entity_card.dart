import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/entity.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_icon.dart';
import 'entity_theme.dart';
import 'fractional_padding.dart';
import 'scaled_line.dart';

class EntityCard extends StatelessWidget {
  final TraversableEntity entity;
  final void Function() deleteEntity;
  final void Function(Entity) changeEntity;
  final void Function({
    required int entityId,
    required int factorId,
  }) deleteDependency;

  const EntityCard(
    this.entity, {
    required this.deleteEntity,
    required this.changeEntity,
    required this.deleteDependency,
    super.key,
  });

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    final dependencyIcons = <Widget>[];

    for (final factor in entity.factors) {
      for (final dependency in factor.dependencies) {
        dependencyIcons.add(
          Expanded(
            key: ValueKey((factor.id, dependency.id)),
            child: ScaledLine(
              id: '${factor.id}:${dependency.id}',
              color: EntityTheme(dependency.type).arrow.withOpacity(0.5),
              targetId: dependency.id.toString(),
              child: EntityIcon(
                dependency.type,
                padding: padding,
              ),
            ),
          ),
        );
      }
      dependencyIcons.add(
        const Expanded(
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  child: Padding(
                    padding: padding,
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (dependencyIcons.isNotEmpty) {
      dependencyIcons.removeLast();
    }

    return FractionalPadding(
      childSizeFactor: 6,
      child: ArrowElement(
        id: entity.id.toString(),
        child: Card(
          elevation: 10,
          margin: EdgeInsets.zero,
          shape: const Border(),
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return EntityForm(
                    entity,
                    changeEntity: changeEntity,
                    deleteEntity: deleteEntity,
                    deleteDependency: deleteDependency,
                  );
                },
              );
            },
            child: Column(
              children: [
                if (entity.factors.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: dependencyIcons,
                    ),
                  ),
                Expanded(
                  child: FittedBox(
                    child: Padding(
                      padding: padding,
                      child: Text(entity.name),
                    ),
                  ),
                ),
                Expanded(
                  child: EntityIcon(
                    entity.type,
                    padding: padding,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
