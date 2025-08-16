
import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/api_service.dart';

class TokenManager {
  static const String _tokenKey = 'token';
  static const String _expiryTimeKey = 'expiry_time';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  static Future<void> saveToken(String token, int expiresIn, String refreshToken, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
    final expiryTime = DateTime.now().add(Duration(milliseconds: expiresIn));
    await prefs.setString(_expiryTimeKey, expiryTime.toIso8601String());
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<DateTime?> getExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimeString = prefs.getString(_expiryTimeKey);
    if (expiryTimeString != null) {
      return DateTime.parse(expiryTimeString);
    }
    return null;
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<bool> isTokenExpired() async {
    final expiryTime = await getExpiryTime();
    if (expiryTime == null) return true;
    return DateTime.now().isAfter(expiryTime);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryTimeKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }

  static Future<String?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('${DaikiAPI.api_key}/api/v1/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newToken = responseData['token'];
        final expiresIn = responseData['expires_in'];
        final newRefreshToken = responseData['refresh_token'];
        String? userId = await getUserId();
        if (userId == null) {
          throw Exception('User ID not found after token refresh');
        }
        await saveToken(newToken, expiresIn, newRefreshToken, userId);
        return newToken;
      } else {
        print('Failed to refresh token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
}