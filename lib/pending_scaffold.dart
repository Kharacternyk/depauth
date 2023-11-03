import 'package:flutter/material.dart';

import 'logotype.dart';

class PendingScaffold extends StatelessWidget {
  final String message;

  const PendingScaffold(this.message, {super.key});

  @override
  build(context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox.square(
              dimension: 240,
              child: Logotype(),
            ),
            const CircularProgressIndicator(),
            Text(message),
          ],
        ),
      ),
    );
  }
}
