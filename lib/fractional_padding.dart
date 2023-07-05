import 'package:flutter/material.dart';

class FractionalPadding extends StatelessWidget {
  final Widget child;
  final int childSizeFactor;

  const FractionalPadding({
    required this.child,
    required this.childSizeFactor,
    super.key,
  });

  @override
  build(context) {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          flex: childSizeFactor,
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                flex: childSizeFactor,
                child: child,
              ),
              const Spacer(),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
