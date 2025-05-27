import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider with ChangeNotifier {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  SearchHistoryProvider() {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('saveSearchHistory') ?? true;
    notifyListeners();
  }

  Future<void> toggle(bool value) async {
    _isEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveSearchHistory', value);
    notifyListeners();
  }
}
