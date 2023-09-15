import 'dart:async';

import 'package:flutter/material.dart';

class DebouncedTextField extends StatefulWidget {
  final String value;
  final Duration delay;
  final void Function(String) commitValue;
  final String hint;

  const DebouncedTextField({
    required this.value,
    required this.delay,
    required this.commitValue,
    required this.hint,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<DebouncedTextField> {
  late var controller = TextEditingController(text: widget.value);
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
          widget.commitValue(value);
        });
      },
      decoration: InputDecoration(
        hintText: widget.hint,
      ),
    );
  }
}
