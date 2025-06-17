// lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/constants.dart';
import 'package:hive/hive.dart';

class ApiService {
  /// A private helper method to construct headers with the auth token.
  Future<Map<String, String>> _getHeaders() async {
    final box = Hive.box('app_data');
    final token = box.get('accessToken');
    if (token == null) {
      // Return headers without auth for public routes like login/register
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- Auth Endpoints ---

  Future<http.Response> register(
      String name, String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/register');
    final headers = await _getHeaders();
    return http.post(
      url,
      headers: headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');
    final headers = await _getHeaders();
    return http.post(
      url,
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> googleSignIn(String idToken) async {
    final url = Uri.parse('$apiBaseUrl/auth/google-signin');
    final headers = await _getHeaders();
    return http.post(
      url,
      headers: headers,
      body: jsonEncode({'token': idToken}),
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

  // --- User & Profile Endpoints ---

  Future<http.Response> getUserProfile() async {
    final url = Uri.parse('$apiBaseUrl/users/me');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
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

  Future<http.Response> updateUserProvider(String provider) async {
    final url = Uri.parse('$apiBaseUrl/users/me/provider');
    final headers = await _getHeaders();
    return http.put(
      url,
      headers: headers,
      body: jsonEncode({'provider': provider}),
    );
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

  // --- Schedules & Status Endpoints ---

  Future<http.Response> getPeakStatus() async {
    final url = Uri.parse('$apiBaseUrl/status');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  Future<http.Response> getSchedules(String provider) async {
    final url = Uri.parse('$apiBaseUrl/schedules/$provider');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  // --- Notes Endpoints ---

  /// Fetches all notes for the logged-in user, filtered by their selected provider.
  Future<http.Response> getAllNotes() async {
    final url = Uri.parse('$apiBaseUrl/notes');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  /// Fetches notes for a specific date range. Used by the calendar and home screen tips.
  Future<http.Response> getNotesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Ensure dates are sent in UTC format as expected by the backend
    final startDateString = startOfDay.toUtc().toIso8601String();
    final endDateString = endOfDay.toUtc().toIso8601String();

    final url = Uri.parse(
        '$apiBaseUrl/notes?startDate=$startDateString&endDate=$endDateString');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  Future<http.Response> createNote(
      String content, String peakPeriod, DateTime date) async {
    final url = Uri.parse('$apiBaseUrl/notes');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'content': content,
      'peakPeriod': peakPeriod,
      'date': date.toUtc().toIso8601String(), // Send date in UTC
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
      'date': date.toUtc().toIso8601String(), // Send date in UTC
    });
    return http.put(url, headers: headers, body: body);
  }

  Future<http.Response> deleteNote(String noteId) async {
    final url = Uri.parse('$apiBaseUrl/notes/$noteId');
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }

  Future<http.Response> searchNotes(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$apiBaseUrl/notes/search?q=$encodedQuery');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }
}
