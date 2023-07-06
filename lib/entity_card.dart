import 'package:flutter/material.dart';

class EntityCard extends StatelessWidget {
  final String name;

  const EntityCard(this.name, {super.key});

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
            child: Material(
              color: colors.primaryContainer,
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      child: Padding(
                        padding: padding,
                        child: Icon(
                          Icons.key,
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
                child: Text(name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
