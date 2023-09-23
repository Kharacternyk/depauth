import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/traveler.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class BottomBar extends StatelessWidget {
  final Widget viewRegionIndicator;
  final void Function(DeletableTraveler) delete;

  const BottomBar({
    required this.viewRegionIndicator,
    required this.delete,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return BottomAppBar(
      child: [
        viewRegionIndicator,
        const Spacer(),
        DragTarget<DeletableTraveler>(
          builder: (context, candidate, rejected) {
            return FloatingActionButton(
              backgroundColor:
                  candidate.isNotEmpty ? colors.error : colors.errorContainer,
              foregroundColor: candidate.isNotEmpty
                  ? colors.onError
                  : colors.onErrorContainer,
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(messages.deleteButtonTooltip),
                      showCloseIcon: true,
                    ),
                  );
              },
              tooltip: messages.deleteButtonTooltip,
              child: const Icon(Icons.delete),
            );
          },
          onAccept: delete,
        ),
        const SizedBox(width: 8),
        ScaledDraggable(
          dragData: const CreationTraveler(),
          child: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(messages.addButtonTooltip),
                    showCloseIcon: true,
                  ),
                );
            },
            tooltip: messages.addButtonTooltip,
            mouseCursor: SystemMouseCursors.grab,
            child: const Icon(Icons.add),
          ),
        ),
      ].row.group,
    );
  }
}
