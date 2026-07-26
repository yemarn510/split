import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String? get displayName {
    final user = currentUser;
    if (user == null) return null;
    return (user.userMetadata?['full_name'] as String?) ??
        (user.userMetadata?['name'] as String?) ??
        user.email;
  }

  String? get avatarUrl {
    final user = currentUser;
    if (user == null) return null;
    return (user.userMetadata?['avatar_url'] as String?) ??
        (user.userMetadata?['picture'] as String?);
  }

  String? get email => currentUser?.email;
}
