import 'package:flutter/material.dart';

class CardDropdown extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final List<Widget> children;

  const CardDropdown({
    required this.leading,
    required this.title,
    required this.children,
    super.key,
  });

  @override
  build(context) {
    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      leading: leading,
      title: title,
      children: children,
    );
  }
}
