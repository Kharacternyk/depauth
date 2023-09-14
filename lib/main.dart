import 'package:flutter/material.dart';

import 'stateful_application.dart';
import 'stateless_application.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(StatelessApplication(await StatefulApplication.get()));
}
