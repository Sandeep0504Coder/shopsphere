import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final void Function()?  onTapFunc;
  final InputDecoration?  decoration;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const CustomTextField({super.key, required this.controller, this.hintText, this.onTapFunc, this.decoration, this.validator, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration ?? InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          )
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          )
        ),
      ),
      keyboardType: keyboardType,
      validator: validator??(val){},
      onTap: onTapFunc
    );
  }
}