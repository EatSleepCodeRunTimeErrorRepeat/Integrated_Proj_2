// lib/providers/auth_provider.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/calendar_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/notification_service.dart';

// Provides an instance of our ApiService to the rest of the app.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// This is the main StateNotifierProvider for authentication.
// The UI will watch this provider to react to changes in auth state.
final authProvider =
    StateNotifierProvider<AuthProvider, AuthState>((ref) => AuthProvider(ref));

/// Represents the state of authentication in the app.
/// It's an immutable class, meaning its properties can't be changed directly.
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;
  final bool isAuthenticated;
  final String?
      localAvatarPath; // For displaying a newly picked avatar instantly

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.localAvatarPath,
  }) : isAuthenticated =
            user != null; // isAuthenticated is true only if there is a user.

  /// Creates a copy of the state with updated values. This is the correct
  /// way to update the state in a notifier.
  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    String? localAvatarPath,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error, // Clear error if flag is true
      user:
          clearUser ? null : (user ?? this.user), // Clear user if flag is true
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
    );
  }
}

/// The "brain" that manages the authentication state and logic.
class AuthProvider extends StateNotifier<AuthState> {
  final Ref _ref;
  late final ApiService _apiService;
  late final Box _appDataBox;

  AuthProvider(this._ref) : super(AuthState(isLoading: true)) {
    // Initialize services when the provider is first created.
    _apiService = _ref.read(apiServiceProvider);
    _appDataBox = Hive.box('app_data');
    _checkInitialAuthStatus(); // Check if user is already logged in.
  }

  // --- 1. Initialization and Session Management ---

  /// Checks for a stored token when the app starts to keep the user logged in.
  Future<void> _checkInitialAuthStatus() async {
    final token = _appDataBox.get('accessToken');
    if (token != null) {
      // If a token exists, fetch the user's profile to confirm it's valid.
      await fetchUserProfile();
      await _loadSavedAvatar(); // Also load any locally saved avatar path
    } else {
      // If no token, set state to not loading and no user.
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  // --- 2. Core Authentication Methods ---

  // --- ADDED DEBUG LOGGING TO THIS METHOD ---
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      debugPrint("[AUTH DEBUG] 1. Starting Google Sign-In process...");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            // This is the client ID for your backend server. -----------------------------------------------------------------------------------------------------------------------------
            '549119570408-75rd2fhqunrqs4f5ftf21q38l8al27ob.apps.googleusercontent.com', //replace with your actual client ID
        // -----------------------------------------------------------------------------------------------------------------------------
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("[AUTH DEBUG] 2. User cancelled the Google Sign-In dialog.");
        state = state.copyWith(isLoading: false);
        return;
      }

      debugPrint("[AUTH DEBUG] 2. Google user selected: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("[AUTH DEBUG] 3. Failed to get idToken from Google.");
        throw Exception('Failed to get Google ID token.');
      }

      debugPrint(
          "[AUTH DEBUG] 3. Got idToken successfully. Preparing to send to backend.");

      final response = await _apiService.googleSignIn(idToken);

      debugPrint(
          "[AUTH DEBUG] 4. Received response from backend with status: ${response.statusCode}");

      if (response.statusCode == 200) {
        await _handleSuccessfulAuth(response.body);
      } else {
        _handleError(response.body);
      }
    } on SocketException catch (e) {
      // This specifically catches network errors (e.g., wrong IP, firewall)
      debugPrint(
          "[AUTH DEBUG] NETWORK ERROR: Could not connect to the server. ${e.message}");
      state = state.copyWith(
          isLoading: false,
          error:
              "Network Error: Could not reach the server. Please check your IP address and firewall settings.");
    } catch (e) {
      // This catches other errors in the process.
      debugPrint("[AUTH DEBUG] An unexpected error occurred: ${e.toString()}");
      state = state.copyWith(
          isLoading: false, error: "Google Sign-In failed. Please try again.");
    }
  }

  /// Handles standard email and password login.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.login(email, password);
      if (response.statusCode == 200) {
        await _handleSuccessfulAuth(response.body);
      } else {
        _handleError(response.body);
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: "Could not connect to the server.");
    }
  }

  /// Handles new user registration.
  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.register(name, email, password);
      if (response.statusCode == 201) {
        // After successful registration, you can either auto-login the user
        // or simply return true and let them log in manually. We will just return.
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        _handleError(response.body);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: "Connection failed. Please try again.");
      return false;
    }
  }

  /// Logs the user out, clears all stored data, and resets the state.
  Future<void> logout() async {
    // When logging out, cancel all previously scheduled notifications.
    await NotificationService().cancelAllNotifications();
    // Also sign out from Google to allow user to pick a different account next time.
    await GoogleSignIn().signOut();
    await _appDataBox.clear();
    // Reset the state to its initial, unauthenticated form.
    state = AuthState();
  }

  Future<bool> verifyPassword(String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.verifyPassword(password);
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        _handleError(response.body);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response =
          await _apiService.changePassword(currentPassword, newPassword);
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        _handleError(response.body);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  // --- 3. Profile and Data Management ---

  /// Fetches the current user's full profile from the backend.
  Future<void> fetchUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        state = state.copyWith(isLoading: false, user: user, error: null);
      } else {
        // If fetching the profile fails (e.g., expired token), log the user out.
        await logout();
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(), clearUser: true);
    }
  }

  /// Updates the user's selected electricity provider.
  Future<bool> updateProvider(String provider) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.updateUserProvider(provider);
      if (response.statusCode == 200) {
        await fetchUserProfile(); // Refetch profile to get the latest user data.
        return true;
      } else {
        _handleError(response.body);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Updates user's name. The avatar part is handled locally for now.
  Future<void> updateUser({String? name}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.updateUser(name: name);
      if (response.statusCode == 200) {
        await fetchUserProfile(); // Refetch to ensure state is fresh.
      } else {
        _handleError(response.body);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Updates notification preferences with optimistic UI.
  Future<void> updateNotificationPreference(bool enabled) async {
    if (state.user == null) return;

    // Optimistically update the UI state
    final originalUser = state.user!;
    final updatedUser = User(
      id: originalUser.id,
      email: originalUser.email,
      name: originalUser.name,
      provider: originalUser.provider,
      avatarUrl: originalUser.avatarUrl,
      notificationsEnabled: enabled, // Update this value
      peakHourAlertsEnabled: originalUser.peakHourAlertsEnabled,
    );
    state = state.copyWith(user: updatedUser);

    // Re-evaluate and schedule/cancel all notifications based on the new master setting
    await _triggerScheduling();

    // Persist the change to the backend
    try {
      await _apiService.updateNotificationPreferences(
          notificationsEnabled: enabled);
    } catch (e) {
      // If the API call fails, revert the state and show an error
      state = state.copyWith(user: originalUser);
      debugPrint("Failed to update master notification preference: $e");
    }
  }

  Future<void> updatePeakHourAlertPreference(bool enabled) async {
    if (state.user == null) return;

    // Optimistically update the UI state
    final originalUser = state.user!;
    final updatedUser = User(
      id: originalUser.id,
      email: originalUser.email,
      name: originalUser.name,
      provider: originalUser.provider,
      avatarUrl: originalUser.avatarUrl,
      notificationsEnabled: originalUser.notificationsEnabled,
      peakHourAlertsEnabled: enabled, // Update this value
    );
    state = state.copyWith(user: updatedUser);

    // Re-evaluate and schedule/cancel all notifications
    await _triggerScheduling();

    // Persist the change to the backend
    try {
      await _apiService.updateNotificationPreferences(
          peakHourAlertsEnabled: enabled);
    } catch (e) {
      // If the API call fails, revert the state
      state = state.copyWith(user: originalUser);
      debugPrint("Failed to update peak hour alert preference: $e");
    }
  }

  // --- 4. Helper and Cleanup Methods ---

  /// Centralized logic for handling a successful authentication response.
  Future<void> _handleSuccessfulAuth(String responseBody) async {
    final data = jsonDecode(responseBody);
    await _appDataBox.put('accessToken', data['accessToken']);
    await fetchUserProfile();
  }

  /// Centralized logic for handling an API error response.
  void _handleError(String responseBody) {
    final errorData = jsonDecode(responseBody);
    state = state.copyWith(isLoading: false, error: errorData['message']);
  }

  /// Clears any existing error message from the state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Loads the path of a locally stored avatar image.
  Future<void> _loadSavedAvatar() async {
    if (state.user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('avatar_path_${state.user!.id}');
    if (savedPath != null) {
      state = state.copyWith(localAvatarPath: savedPath);
    }
  }

  /// Saves the path of a newly picked avatar image for instant display.
  Future<void> updateLocalAvatar(XFile file) async {
    if (state.user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path_${state.user!.id}', file.path);
    state = state.copyWith(localAvatarPath: file.path);
  }

  Future<void> _triggerScheduling() async {
    // This helper function reads the necessary data and calls the notification service.
    if (state.user == null) return;

    // We need the schedules to calculate notifications. We can read the provider for this.
    final schedulesAsyncValue = _ref.read(schedulesProvider);
    final schedules = schedulesAsyncValue.asData?.value ??
        []; // Safely get list or empty list

    final bool generalOn = state.user!.notificationsEnabled ?? true;
    final bool peakAlertsOn = state.user!.peakHourAlertsEnabled ?? true;
    await NotificationService().schedulePeakHourAlerts(schedules,
        generalOn: generalOn, peakAlertsOn: peakAlertsOn);
  }
}
