import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return new TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: TextSelection.collapsed(offset: newValue.text.length));
  }
}
