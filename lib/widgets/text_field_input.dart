import 'package:flutter/material.dart';
import 'package:spotted_ufersa/utils/colors.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context),
        borderRadius: BorderRadius.all(Radius.circular(39.0)));
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        fillColor: Color.fromARGB(226, 255, 255, 255),
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.only(left: 20, right: 15),
      ),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader = LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(
              0.0,
              0.0,
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2)),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
