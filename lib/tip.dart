import 'package:flutter/material.dart';

class Tip extends StatelessWidget {
  final bool isElevated;
  final String message;

  const Tip.onCard(this.message, {super.key}) : isElevated = true;
  const Tip.onSurfaceVariant(this.message, {super.key}) : isElevated = false;

  @override
  build(context) {
    final style = !isElevated
        ? TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )
        : null;

    return ListTile(
      title: Text(message, style: style),
      trailing: const Icon(Icons.tips_and_updates),
    );
  }
}
