import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsFormField extends StatefulWidget {
  const SettingsFormField({Key? key, required this.label, this.value, required this.onValueChange}) : super(key: key);

  final String label;
  final String? value;
  final Function(String) onValueChange;

  @override
  State<SettingsFormField> createState() => _SettingsFormFieldState();
}

class _SettingsFormFieldState extends State<SettingsFormField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.value ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(6),
        hintText: widget.label,
        labelText: widget.label,
      ),
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
      ],
      onChanged: widget.onValueChange,
    );
  }
}
