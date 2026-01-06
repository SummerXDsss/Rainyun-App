import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> saveApiKey(String userId, String apiKey) async {
    await _client.from('user_settings').upsert({
      'user_id': userId,
      'rainyun_api_key': apiKey,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> getApiKey(String userId) async {
    final response = await _client
        .from('user_settings')
        .select('rainyun_api_key')
        .eq('user_id', userId)
        .maybeSingle();
    
    return response?['rainyun_api_key'] as String?;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _client.from('user_settings').upsert({
      'user_id': userId,
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
