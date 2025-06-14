// lib/models/user_model.dart

class User {
  final String id;
  final String email;
  final String name;
  final String? provider;
  final bool notificationsEnabled;
  final String? avatarUrl; // <-- ADD THIS LINE

  User({
    required this.id,
    required this.email,
    required this.name,
    this.provider,
    required this.notificationsEnabled,
    this.avatarUrl, // <-- ADD THIS LINE
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      provider: json['provider'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      avatarUrl: json['avatarUrl'], // <-- ADD THIS LINE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'provider': provider,
      'notificationsEnabled': notificationsEnabled,
      'avatarUrl': avatarUrl, // <-- ADD THIS LINE
    };
  }
}
