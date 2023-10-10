import 'package:flutter/material.dart';

import 'core/edit_subject.dart';
import 'core/insightful_storage.dart';
import 'core/storage_insight.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_graph.dart';
import 'split_view.dart';
import 'storage_form.dart';
import 'view_region.dart';
import 'viewer.dart';
import 'widget_extension.dart';

class StorageScaffold extends StatelessWidget {
  final InsightfulStorage storage;
  final List<Widget> formLeading;
  final List<Widget> formTrailing;
  final Widget bottomBar;
  final ValueNotifier<EditSubject> editSubject;
  final ValueNotifier<bool> formHasTraveler;
  final ValueNotifier<ViewRegion> viewRegion;

  const StorageScaffold({
    required this.storage,
    required this.formLeading,
    required this.formTrailing,
    required this.bottomBar,
    required this.editSubject,
    required this.formHasTraveler,
    required this.viewRegion,
    super.key,
  });

  @override
  build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final storageForm = (StorageInsight insight) {
      return StorageForm(
        storageName: storage.name,
        insight: insight,
        resetLoss: storage.resetLoss,
        resetCompromise: storage.resetCompromise,
        leading: formLeading,
        trailing: formTrailing,
        rename: (name) => storage.name = name,
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
                region: viewRegion,
                child: EntityGraph(storage, editSubject: editSubject),
              ),
            ),
            sideChild: (EditSubject subject) {
              switch (subject) {
                case StorageSubject _:
                  return storageForm;
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
                            changeImportance: (value) {
                              storage.changeImportance(position, value);
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
      bottomNavigationBar: bottomBar,
    );
  }
}
