import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'entity_insight.dart';
import 'storage.dart';

abstract interface class EntityInsightOrigin {
  EntityInsight getEntityInsight(Identity<Entity> entity);
  ChangeNotifier get entityInsightNotifier;
}
