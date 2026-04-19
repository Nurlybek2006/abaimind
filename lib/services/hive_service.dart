import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class HiveService {
  static const String userBox = 'user_box';
  static const String testsBox = 'tests_box';
  static const String newsBox = 'news_box';
  static const String chatBox = 'chat_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(userBox);
    await Hive.openBox(testsBox);
    await Hive.openBox(newsBox);
    await Hive.openBox(chatBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(cacheBox);
  }

  // User cache
  static Future<void> cacheUser(Map<String, dynamic> userData) async {
    final box = Hive.box(userBox);
    await box.put('currentUser', jsonEncode(userData));
  }

  static Map<String, dynamic>? getCachedUser() {
    final box = Hive.box(userBox);
    final data = box.get('currentUser');
    if (data == null) return null;
    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  // Tests cache
  static Future<void> cacheTests(List<Map<String, dynamic>> tests) async {
    final box = Hive.box(testsBox);
    await box.put('tests', jsonEncode(tests));
  }

  static List<Map<String, dynamic>> getCachedTests() {
    final box = Hive.box(testsBox);
    final data = box.get('tests');
    if (data == null) return [];
    final list = jsonDecode(data as String) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // News cache
  static Future<void> cacheNews(List<Map<String, dynamic>> news) async {
    final box = Hive.box(newsBox);
    await box.put('news', jsonEncode(news));
  }

  static List<Map<String, dynamic>> getCachedNews() {
    final box = Hive.box(newsBox);
    final data = box.get('news');
    if (data == null) return [];
    final list = jsonDecode(data as String) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // Chat cache
  static Future<void> cacheChatMessages(
      String chatRoomId, List<Map<String, dynamic>> messages) async {
    final box = Hive.box(chatBox);
    await box.put('chat_$chatRoomId', jsonEncode(messages));
  }

  static List<Map<String, dynamic>> getCachedMessages(String chatRoomId) {
    final box = Hive.box(chatBox);
    final data = box.get('chat_$chatRoomId');
    if (data == null) return [];
    final list = jsonDecode(data as String) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // Settings
  static Future<void> setDarkMode(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put('darkMode', value);
  }

  static bool getDarkMode() {
    final box = Hive.box(settingsBox);
    return box.get('darkMode', defaultValue: false) as bool;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Hive.box(userBox).clear();
    await Hive.box(testsBox).clear();
    await Hive.box(newsBox).clear();
    await Hive.box(chatBox).clear();
  }
}
