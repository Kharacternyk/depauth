import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/entity_type.dart';

extension EntityTypeName on EntityType {
  String getName(BuildContext context) {
    final messages = AppLocalizations.of(context)!;
    return switch (value) {
      1 => messages.type1,
      2 => messages.type2,
      3 => messages.type3,
      4 => messages.type4,
      5 => messages.type5,
      6 => messages.type6,
      7 => messages.type7,
      _ => messages.genericType,
    };
  }
}
