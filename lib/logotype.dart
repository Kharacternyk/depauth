import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import 'widget_extension.dart';

class Logotype extends StatelessWidget {
  const Logotype({super.key});

  @override
  build(context) {
    return ScalableImageWidget.fromSISource(
      si: ScalableImageSource.fromSI(
        DefaultAssetBundle.of(context),
        'assets/logo.si',
      ),
    ).fit;
  }
}
