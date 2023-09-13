import 'package:flutter/material.dart';

import 'application.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await Application.get());
}
