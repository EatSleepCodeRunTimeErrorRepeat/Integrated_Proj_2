// lib/models/user_model.dart

import 'package:flutter/foundation.dart';

@immutable // This annotation encourages the class to be immutable.
class User {
  final String id;
  final String email;
  final String name;
  final String? provider;
  final bool? notificationsEnabled;
  final bool? peakHourAlertsEnabled;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.provider,
    this.notificationsEnabled,
    this.peakHourAlertsEnabled,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String?,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      peakHourAlertsEnabled: json['peakHourAlertsEnabled'] ?? true,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'provider': provider,
      'notificationsEnabled': notificationsEnabled,
      'peakHourAlertsEnabled': peakHourAlertsEnabled,
      'avatarUrl': avatarUrl,
    };
  }
}
