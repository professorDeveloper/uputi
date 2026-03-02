import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class AppStyle {
  AppStyle._();

  static TextStyle sfproDisplay28w600black = TextStyle(
      color: AppColor.black,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      fontFamily: 'SfProDisplay');

  static TextStyle sfProDisplay24w600 = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'SfProDisplay');
  static TextStyle sfProDisplay22w600 = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'SfProDisplay');
  static TextStyle sfproDisplay18Black = TextStyle(
      fontFamily: 'SfProDisplay', fontSize: 18, color: AppColor.black);

  static TextStyle sfproDisplay18Gray5 = TextStyle(
      fontFamily: 'SfProDisplay', fontSize: 18, color: AppColor.Gray5);
  static TextStyle sfproDisplay16Gray5 = TextStyle(
      fontFamily: 'SfProDisplay', fontSize: 16, color: AppColor.Gray5);
  static TextStyle sfproDisplay16Black = TextStyle(
      fontFamily: 'SfProDisplay', fontSize: 16, color: AppColor.black);
  static TextStyle sfProDisplay16White = TextStyle(
      fontFamily: 'SfProDisplay', fontSize: 16, color: AppColor.white);

  static TextStyle sfproDisplay16Nonormal = TextStyle(
      fontFamily: 'SfProDisplay', fontSize: 16, color: AppColor.grey);
  static TextStyle sfproDisplay15Black = TextStyle(
      fontFamily: 'SfProDisplay',
      fontSize: 15,
      color: AppColor.black,
      fontWeight: FontWeight.w500);

  static TextStyle sfproDisplay14w400Black = TextStyle(
      fontFamily: 'SfProDisplay',
      fontSize: 14,
      color: AppColor.black,
      fontWeight: FontWeight.w400);
  static TextStyle sfproDisplay14w400Gray5 = TextStyle(
      fontFamily: 'SfProDisplay',
      fontSize: 14,
      color: AppColor.Gray5,
      fontWeight: FontWeight.w400);
  static TextStyle sfproDisplay12w400White = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w400,
    height: 1.67,
  );
}
