import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

import 'widget_extension.dart';

class CardForm extends StatelessWidget {
  final List<Widget> children;

  const CardForm(this.children, {super.key});

  @override
  build(context) {
    final orientation = MediaQuery.of(context).orientation;
    const padding = 4.0;

    return NormalizedOverflowBox(
      minWidth: 280,
      alignment: Alignment.centerLeft,
      child: ListTileTheme(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            switch (orientation) {
              Orientation.landscape => 0,
              Orientation.portrait => padding,
            },
            switch (orientation) {
              Orientation.landscape => padding,
              Orientation.portrait => 0,
            },
            padding,
            padding,
          ),
          children: children,
        ),
      ).group,
    );
  }
}
