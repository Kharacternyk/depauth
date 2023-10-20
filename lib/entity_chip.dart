import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'entity_theme.dart';

extension EntityChip on Entity {
  Widget get chip => type.chip(name);
}
