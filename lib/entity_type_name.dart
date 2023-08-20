import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/entity_type.dart';

String getEntityTypeName(EntityType type, BuildContext context) {
  final messages = AppLocalizations.of(context)!;

  return switch (type) {
    EntityType.generic => messages.genericEntity,
    EntityType.hardwareKey => messages.hardwareKey,
    EntityType.webService => messages.webService,
    EntityType.knowledge => messages.secretKnowledge,
    EntityType.biometrics => messages.biometrics,
    EntityType.phoneNumber => messages.phoneNumber,
    EntityType.device => messages.device,
    EntityType.application => messages.application,
    EntityType.paymentInformation => messages.paymentInformation,
    EntityType.operatingSystem => messages.operatingSystem,
  };
}
