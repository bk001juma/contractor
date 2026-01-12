

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  // User data management
  Future<void> saveUserData({
    required String userId,
    required String userType,
    required String email,
  }) async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.setString(_userIdKey, userId),
      prefs.setString(_userTypeKey, userType),
      prefs.setString(_userEmailKey, email),
    ]);
  }

  Future<Map<String, String?>> getUserData() async {
    final prefs = await _prefs;
    return {
      'userId': prefs.getString(_userIdKey),
      'userType': prefs.getString(_userTypeKey),
      'email': prefs.getString(_userEmailKey),
    };
  }

  Future<void> clearUserData() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_userIdKey),
      prefs.remove(_userTypeKey),
      prefs.remove(_userEmailKey),
    ]);
  }

  // Clear all auth data (logout)
  Future<void> clearAll() async {
    await clearToken();
    await clearUserData();
  }
}