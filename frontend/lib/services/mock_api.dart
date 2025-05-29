import 'dart:convert';

class MockApiService {
  Future<Map<String, dynamic>> fetchUserProfile() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    // Return mock user data
    return {
      "username": "PeakSmart123",
      "email": "user@example.com",
      "provider": "Provincial Electricity Authority",
    };
  }
}
