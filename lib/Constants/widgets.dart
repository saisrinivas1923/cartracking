
import 'package:flutter/material.dart';

class CustomWidget {
  static void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}