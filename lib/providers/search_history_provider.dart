// lib/providers/search_history_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider with ChangeNotifier {
  bool _isEnabled = true;
  List<String> _history = [];

  bool get isEnabled => _isEnabled;
  List<String> get history => _history;

  SearchHistoryProvider() {
    _loadSetting();
    _loadHistory();
  }

  /// 🔧 설정 불러오기
  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('saveSearchHistory') ?? true;
    notifyListeners();
  }

  /// 🔁 설정 변경
  Future<void> toggle(bool value) async {
    _isEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveSearchHistory', value);
    notifyListeners();
  }

  /// 🔍 검색 기록 불러오기
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList('searchHistory') ?? [];
    notifyListeners();
  }

  /// ➕ 검색어 추가
  Future<void> addSearchTerm(String term) async {
    if (!_isEnabled || term.isEmpty) return;

    _history.remove(term); // 중복 제거
    _history.insert(0, term); // 최근 항목 앞으로

    if (_history.length > 50) {
      _history = _history.sublist(0, 50); // 최대 50개 유지
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _history);
    notifyListeners();
  }

  /// 🧹 전체 검색 기록 삭제
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    _history.clear();
    notifyListeners();
  }
}
