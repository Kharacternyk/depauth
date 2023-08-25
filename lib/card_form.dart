import 'package:flutter/material.dart';

class CardForm extends StatelessWidget {
  final List<Widget> children;

  const CardForm(this.children, {super.key});

  @override
  build(context) {
    return ListTileTheme(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: ListView(
        children: children,
      ),
    );
  }
}
