import 'package:flutter/material.dart';

typedef NumberInputParser<T> = T? Function(String text);

Future<T?> showNumberInputDialog<T>(
  BuildContext context, {
  required String title,
  required String initialValue,
  required String labelText,
  required NumberInputParser<T> parse,
  required TextInputType keyboardType,
  String confirmLabel = '发送',
  bool autofocus = false,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => _NumberInputDialog<T>(
      title: title,
      initialValue: initialValue,
      labelText: labelText,
      parse: parse,
      keyboardType: keyboardType,
      confirmLabel: confirmLabel,
      autofocus: autofocus,
    ),
  );
}

class _NumberInputDialog<T> extends StatefulWidget {
  const _NumberInputDialog({
    required this.title,
    required this.initialValue,
    required this.labelText,
    required this.parse,
    required this.keyboardType,
    required this.confirmLabel,
    required this.autofocus,
  });

  final String title;
  final String initialValue;
  final String labelText;
  final NumberInputParser<T> parse;
  final TextInputType keyboardType;
  final String confirmLabel;
  final bool autofocus;

  @override
  State<_NumberInputDialog<T>> createState() => _NumberInputDialogState<T>();
}

class _NumberInputDialogState<T> extends State<_NumberInputDialog<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = widget.parse(_controller.text);
    if (value != null) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(labelText: widget.labelText),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
    ],
  );
}
