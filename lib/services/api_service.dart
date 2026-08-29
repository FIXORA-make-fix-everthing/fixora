import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/globals.dart';
import '../screens/login_screen.dart';
class ApiService {
  // Use 10.0.2.2 for Android emulator, or your local IP for physical device
  static const String baseUrl = 'http://192.168.x.x:5000/api'; 
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Helper method to get the token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Generic GET request
  Future<http.Response> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  // Generic POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
    return response;
  }

  Future<void> _handleUnauthorized() async {
    await logout();
    if (navigatorKey.currentContext != null) {
      final context = navigatorKey.currentContext!;
      if (!context.mounted) return;
      final role = Provider.of<AppState>(context, listen: false).currentRole;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen(role: role)),
        (route) => false,
      );
    }
  }

  // Save auth data on login
  Future<void> saveAuthData(String token, String userId) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_id', value: userId);
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
  }
}
