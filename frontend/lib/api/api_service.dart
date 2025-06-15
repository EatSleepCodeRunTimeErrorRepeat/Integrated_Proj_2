// lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/constants.dart';
import 'package:hive/hive.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final box = Hive.box('app_data');
    final token = box.get('accessToken');
    if (token == null) throw Exception('Auth token not found!');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

// NEW: Get the real-time peak status from the backend
  Future<http.Response> getPeakStatus() async {
    final url = Uri.parse('$apiBaseUrl/status');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  // FIX: Added the missing googleSignIn method
  Future<http.Response> googleSignIn(String token) async {
    final url = Uri.parse('$apiBaseUrl/auth/google-signin');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
  }

  Future<http.Response> register(
      String name, String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/register');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> verifyPassword(String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/verify-password');
    final headers = await _getHeaders();
    return http.post(
      url,
      headers: headers,
      body: jsonEncode({'password': password}),
    );
  }

  Future<http.Response> changePassword(
      String currentPassword, String newPassword) async {
    final url = Uri.parse('$apiBaseUrl/auth/change-password');
    final headers = await _getHeaders();
    return http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
  }

  Future<http.Response> getUserProfile() async {
    final url = Uri.parse('$apiBaseUrl/users/me');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> updateUserProvider(String provider) async {
    final url = Uri.parse('$apiBaseUrl/users/me/provider');
    final headers = await _getHeaders();
    return http.put(
      url,
      headers: headers,
      body: jsonEncode({'provider': provider}),
    );
  }

  Future<http.Response> updateUser({String? name, String? avatarUrl}) async {
    final url = Uri.parse('$apiBaseUrl/users/me');
    final headers = await _getHeaders();
    final Map<String, String> body = {};
    if (name != null) body['name'] = name;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    return http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getProviders() async {
    final url = Uri.parse('$apiBaseUrl/providers');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> updateNotificationPreferences(bool isEnabled) async {
    final url = Uri.parse('$apiBaseUrl/users/me/preferences');
    final headers = await _getHeaders();
    return http.put(
      url,
      headers: headers,
      body: jsonEncode({'notificationsEnabled': isEnabled}),
    );
  }

  Future<http.Response> getSchedules(String provider) async {
    final url = Uri.parse('$apiBaseUrl/schedules/$provider');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> getNotesForDate(DateTime date) async {
    final startOfDayLocal = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDayLocal = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final startDateString = startOfDayLocal.toUtc().toIso8601String();
    final endDateString = endOfDayLocal.toUtc().toIso8601String();
    final url = Uri.parse(
        '$apiBaseUrl/notes?startDate=$startDateString&endDate=$endDateString');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> createNote(
      String content, String peakPeriod, DateTime date) async {
    final url = Uri.parse('$apiBaseUrl/notes');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'content': content,
      'peakPeriod': peakPeriod,
      'date': date.toIso8601String(),
    });
    return http.post(url, headers: headers, body: body);
  }

  Future<http.Response> updateNote(
      String noteId, String content, String peakPeriod, DateTime date) async {
    final url = Uri.parse('$apiBaseUrl/notes/$noteId');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'content': content,
      'peakPeriod': peakPeriod,
      'date': date.toIso8601String(),
    });
    return http.put(url, headers: headers, body: body);
  }

  Future<http.Response> deleteNote(String noteId) async {
    final url = Uri.parse('$apiBaseUrl/notes/$noteId');
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }

  Future<http.Response> getAllNotes() async {
    final url = Uri.parse('$apiBaseUrl/notes/all');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> searchNotes(String query) async {
    final url = Uri.parse('$apiBaseUrl/notes/search?q=$query');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }
}
