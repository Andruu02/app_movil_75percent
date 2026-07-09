import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Cliente HTTP centralizado: agrega el header Authorization con el JWT
/// guardado y redirige al login si el backend responde 401.
class ApiClient {
  static const String _tokenKey = 'jwt_token';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String url) async {
    final response =
        await http.get(Uri.parse(url), headers: await _authHeaders());
    await _handleUnauthorized(response);
    return response;
  }

  static Future<http.Response> post(String url, {Object? body}) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _authHeaders(json: true),
      body: body != null ? jsonEncode(body) : null,
    );
    await _handleUnauthorized(response);
    return response;
  }

  static Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}
