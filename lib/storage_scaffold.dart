import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/edit_subject.dart';
import 'core/insightful_storage.dart';
import 'core/storage_insight.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_graph.dart';
import 'scaled_draggable.dart';
import 'split_view.dart';
import 'storage_form.dart';
import 'viewer.dart';
import 'widget_extension.dart';

class StorageScaffold extends StatelessWidget {
  final InsightfulStorage storage;
  final Widget storageDirectoryForm;
  final ValueNotifier<EditSubject> editSubject;
  final ValueNotifier<bool> formHasTraveler;
  final void Function(StorageTraveler) deleteStorage;

  const StorageScaffold({
    required this.storage,
    required this.storageDirectoryForm,
    required this.editSubject,
    required this.formHasTraveler,
    required this.deleteStorage,
    super.key,
  });

  @override
  build(BuildContext context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final storageForm = (StorageInsight insight) {
      return StorageForm(
        storageName: storage.name,
        insight: insight,
        resetLoss: storage.resetLoss,
        resetCompromise: storage.resetCompromise,
        goBack: () {
          editSubject.value = const StorageDirectorySubject();
        },
        rename: storage.setName,
        isRenameCanceled: () => storage.disposed,
      );
    }.listen(storage.storageInsight);

    return Scaffold(
      body: Stack(
        children: [
          (bool formHasTraveler) {
            return Ink(
              color: formHasTraveler
                  ? colors.primaryContainer
                  : colors.surfaceVariant,
            );
          }.listen(formHasTraveler),
          SplitView(
            mainChild: Material(
              child: Viewer(
                minScale: 1,
                maxScale: 20,
                child: EntityGraph(storage, editSubject: editSubject),
              ),
            ),
            sideChild: (EditSubject subject) {
              switch (subject) {
                case StorageSubject _:
                  return storageForm;
                case StorageDirectorySubject _:
                  return storageDirectoryForm;
                case EntitySubject subject:
                  final position = subject.position;
                  final listenableEntity =
                      storage.getListenableEntity(position);

                  return (TraversableEntity? entity) {
                    return switch (entity) {
                      TraversableEntity entity => () {
                          return EntityForm(
                            entity,
                            position: position,
                            hasTraveler: formHasTraveler,
                            isRenameCanceled: () => storage.disposed,
                            goBack: () {
                              editSubject.value = const StorageSubject();
                            },
                            insight: storage.getEntityInsight(entity.identity),
                            changeName: (name) {
                              storage.changeName(position, name);
                            },
                            changeType: (type) {
                              storage.changeType(position, type);
                            },
                            toggleLost: (value) {
                              storage.toggleLost(position, value);
                            },
                            toggleCompromised: (value) {
                              storage.toggleCompromised(position, value);
                            },
                            addDependency: (factor, entity) {
                              storage.addDependency(
                                position,
                                factor,
                                entity,
                              );
                            },
                            addDependencyAsFactor: (dependency) {
                              storage.addDependencyAsFactor(
                                position,
                                entity: entity.identity,
                                dependency: dependency,
                              );
                            },
                            removeDependency: (factor, entity) {
                              storage.removeDependency(
                                position,
                                factor,
                                entity,
                              );
                            },
                            addFactor: () {
                              storage.addFactor(position, entity.identity);
                            },
                          );
                        }.listen(storage.entityInsightNotifier),
                      null => storageForm,
                    };
                  }.listen(listenableEntity);
              }
            }.listen(editSubject),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: [
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
            onAccept: (traveler) {
              switch (traveler) {
                case EntityTraveler traveler:
                  storage.deleteEntity(traveler.position);
                case FactorTraveler traveler:
                  storage.removeFactor(traveler.position, traveler.factor);
                case DependencyTraveler traveler:
                  storage.removeDependency(
                    traveler.position,
                    traveler.factor,
                    traveler.entity,
                  );
                case StorageTraveler traveler:
                  deleteStorage(traveler);
              }
            },
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
      ),
    );
  }
}
