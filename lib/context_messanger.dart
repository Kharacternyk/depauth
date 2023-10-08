import 'package:flutter/material.dart';

extension ContextMessanger on BuildContext {
  void pushMessage(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          showCloseIcon: true,
        ),
      );
  }
}
