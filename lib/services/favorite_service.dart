// lib/services/favorite_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import 'dart:developer';

class FavoriteService {
  static const _key = 'favorites';

  /// 즐겨찾기 추가
  static Future<void> addFavorite(FavoriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getFavorites();
    existing.add(item);
    final jsonList = existing.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// 즐겨찾기 제거
  static Future<void> removeFavorite(FavoriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getFavorites();
    existing.removeWhere((e) => e.formula == item.formula);
    final jsonList = existing.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// 즐겨찾기 불러오기
  static Future<List<FavoriteItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.map((e) => FavoriteItem.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      log('❌ 즐겨찾기 로드 오류: $e', name: 'FavoriteService');
      return [];
    }
  }
}
