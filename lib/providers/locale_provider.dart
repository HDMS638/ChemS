import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ko'); // 기본 언어

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'ko'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}
