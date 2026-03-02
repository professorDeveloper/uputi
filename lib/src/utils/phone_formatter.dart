import 'package:flutter/cupertino.dart';

String extractPhone9Digits(TextEditingController phoneController) {
  final digits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith("998") && digits.length >= 12) {
    return digits.substring(3);
  }
  return digits;
}
String formatPhoneNumber(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 12) return input; // yiqilmasin
  return "${digits.substring(0, 3)} ${digits.substring(3, 5)} "
      "${digits.substring(5, 8)} ${digits.substring(8, 10)} "
      "${digits.substring(10, 12)}";
}
