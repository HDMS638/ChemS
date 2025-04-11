// lib/providers/font_provider.dart
import 'package:flutter/material.dart';

class FontProvider extends ChangeNotifier {
  double _fontScale = 1.0;

  double get fontScale => _fontScale;

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }
}
