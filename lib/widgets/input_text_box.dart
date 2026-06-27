import 'package:flutter/material.dart';
import '../themes/palette.dart';

class InputTextBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final IconData? icon;
  final TextInputType? keyboardType;

  const InputTextBox({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: deepTeal) : null,
        filled: true,
        fillColor: white,
        labelStyle: const TextStyle(color: deepTeal),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}
