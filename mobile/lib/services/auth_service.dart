import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class AuthService {
  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : AppConfig.authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// `user.identities.at(0).identity_data`, which login-popup.tsx reads.
  Map<String, dynamic> get _identityData {
    final identities = currentUser?.identities;
    if (identities == null || identities.isEmpty) return const {};
    return identities.first.identityData ?? const {};
  }

  String get fullName => (_identityData['full_name'] as String?) ?? '';

  String? get avatarUrl => _identityData['avatar_url'] as String?;

  String get email => (_identityData['email'] as String?) ?? '';
}
