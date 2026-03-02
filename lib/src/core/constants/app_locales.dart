import 'package:flutter/material.dart';

class AppLocales {
  AppLocales._();

  static const String uz = 'uz';
  static const String ru = 'ru';
  static const String en = 'en';

  static const Locale uzLocale = Locale('uz');
  static const Locale ruLocale = Locale('ru');
  static const Locale enLocale = Locale('en');

  static const List<Locale> supported = [uzLocale, ruLocale, enLocale];
  static const Locale fallback = uzLocale;
  static const String path = 'assets/translations';

  static String nameOf(String code) {
    switch (code) {
      case uz: return "O'zbek";
      case ru: return 'Русский';
      case en: return 'English';
      default: return code;
    }
  }

  static String flagOf(String code) {
    switch (code) {
      case uz: return '🇺🇿';
      case ru: return '🇷🇺';
      case en: return '🇬🇧';
      default: return '🌐';
    }
  }
}