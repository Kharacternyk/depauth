import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'context_messanger.dart';
import 'core/traveler.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class BottomBar extends StatelessWidget {
  final List<Widget> children;
  final void Function(DeletableTraveler) delete;

  const BottomBar({
    required this.children,
    required this.delete,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return BottomAppBar(
      child: [
        ...children,
        const Spacer(),
        DragTarget<DeletableTraveler>(
          builder: (context, candidate, rejected) {
            return FloatingActionButton(
              backgroundColor:
                  candidate.isNotEmpty ? colors.error : colors.errorContainer,
              foregroundColor: candidate.isNotEmpty
                  ? colors.onError
                  : colors.onErrorContainer,
              onPressed: () =>
                  context.pushMessage(messages.deleteButtonTooltip),
              tooltip: messages.deleteButtonTooltip,
              heroTag: null,
              child: const Icon(Icons.delete),
            );
          },
          onAccept: delete,
        ),
        const SizedBox(width: 8),
        ScaledDraggable(
          dragData: const CreationTraveler(),
          child: FloatingActionButton(
            onPressed: () => context.pushMessage(messages.addButtonTooltip),
            tooltip: messages.addButtonTooltip,
            mouseCursor: SystemMouseCursors.grab,
            heroTag: null,
            child: const Icon(Icons.add),
          ),
        ),
      ].row.group,
    );
  }
}
