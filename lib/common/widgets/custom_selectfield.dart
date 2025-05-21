import 'package:flutter/material.dart';

class CustomSelectField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> options;
  final String hintText;

  const CustomSelectField({
    super.key,
    required this.controller,
    required this.options,
    required this.hintText
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
      ),
      items: options
          .map((option) => DropdownMenuItem(
                value: option.toLowerCase(),
                child: Text(option),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.text = value;
        }
      },
    );
  }
}
