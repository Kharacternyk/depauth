import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'storage_directory_scaffold_loader.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  build(context) {
    return MaterialApp(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.applicationName;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SafeArea(
        child: StorageDirectoryScaffoldLoader(),
      ),
    );
  }
}
