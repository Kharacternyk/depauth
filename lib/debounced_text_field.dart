import 'dart:async';

import 'package:flutter/material.dart';

class DebouncedTextField extends StatefulWidget {
  final Duration delay;
  final String Function() getInitialValue;
  final void Function(String) commitValue;
  final bool Function() isCanceled;
  final String hint;

  const DebouncedTextField({
    required this.getInitialValue,
    required this.delay,
    required this.commitValue,
    required this.hint,
    required this.isCanceled,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<DebouncedTextField> {
  late final controller = TextEditingController(text: widget.getInitialValue());
  Timer? debouncer;

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  build(context) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        debouncer?.cancel();
        debouncer = Timer(widget.delay, () {
          if (!widget.isCanceled()) {
            widget.commitValue(value);
          }
        });
      },
      decoration: InputDecoration(
        hintText: widget.hint,
      ),
    );
  }
}
