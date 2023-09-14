import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

class StatelessApplication extends StatelessWidget {
  final Widget child;

  const StatelessApplication(this.child, {super.key});

  @override
  build(context) {
    return MaterialApp(
      title: 'DepAuth',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SafeArea(child: child),
    );
  }
}
