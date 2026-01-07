import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  
  Session? get currentSession => _supabase.auth.currentSession;
  
  bool get isLoggedIn => currentSession != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
        emailRedirectTo: 'com.summer.rainyun3rd://login-callback',
      );
      
      if (response.user != null) {
        await _createUserProfile(response.user!, username);
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      return response;
    } catch (e) {
      debugPrint('❌ Update user error: $e');
      rethrow;
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent');
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }

  String? getUserMetadata(String key) {
    return currentUser?.userMetadata?[key]?.toString();
  }

  String? get userEmail => currentUser?.email;
  
  String? get userId => currentUser?.id;
  
  String? get username => getUserMetadata('username');

  Future<void> _createUserProfile(User user, String? username) async {
    try {
      await _supabase.from('user_profiles').insert({
        'user_id': user.id,
        'email': user.email,
        'username': username ?? user.email?.split('@')[0],
      });
      debugPrint('✅ User profile created');
    } catch (e) {
      debugPrint('⚠️ Failed to create user profile: $e');
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUser == null) return null;
      
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('⚠️ User profile not found, creating...');
        await _createUserProfile(currentUser!, username);
        return getUserProfile();
      }
      
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Get user profile error: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    String? rainyunApiKey,
    String? username,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (rainyunApiKey != null) data['rainyun_api_key'] = rainyunApiKey;
      if (username != null) data['username'] = username;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (preferences != null) data['preferences'] = preferences;

      await _supabase
          .from('user_profiles')
          .update(data)
          .eq('user_id', currentUser!.id);

      debugPrint('✅ User profile updated');
    } catch (e) {
      debugPrint('❌ Update user profile error: $e');
      rethrow;
    }
  }
}
