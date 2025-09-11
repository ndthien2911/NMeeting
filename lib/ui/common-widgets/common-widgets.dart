import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonWidgets {
  static textErrorStyle() {
    return TextStyle(fontSize: 16);
  }

  static outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(25),
      ),
    );
  }
}
