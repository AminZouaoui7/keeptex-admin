import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obsecureText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType keyboardType; // ✅ On ajoute keyboardType

  const MyTextfield({
    Key? key,
    required this.hintText,
    required this.obsecureText,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text, // ✅ Default: TextInputType.text
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obsecureText,
        controller: controller,
        keyboardType: keyboardType, // ✅ Utilisation ici
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon, color: Color.fromARGB(255, 0, 57, 166)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Colors.grey[200],
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

