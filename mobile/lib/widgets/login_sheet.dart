import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/history.dart';
import '../models/person.dart';
import '../services/auth_service.dart';
import '../services/friends_service.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../widgets/rounded_avatar.dart';
import '../screens/history_screen.dart';

class LoginSheet extends StatefulWidget {
  final ValueChanged<List<Person>> onPeopleLoaded;

  const LoginSheet({
    super.key,
    required this.onPeopleLoaded,
  });

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _auth = AuthService();
  late final FriendsService _friends =
      FriendsService(Supabase.instance.client);
  late final HistoryService _history =
      HistoryService(Supabase.instance.client);

  StreamSubscription<AuthState>? _authSub;
  bool _loading = false;
  bool _historiesLoading = false;
  String? _historiesError;
  List<HistorySummary> _histories = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadLoggedInData();
    }
    _authSub = _auth.authStateChanges.listen((state) {
      final user = state.session?.user;
      setState(() => _user = user);
      if (user != null) {
        _loadLoggedInData();
      } else {
        setState(() => _histories = []);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadLoggedInData() async {
    final user = _user ?? _auth.currentUser;
    if (user == null) return;
    setState(() {
      _historiesLoading = true;
      _historiesError = null;
    });
    try {
      final people = await _friends.fetchFriends();
      widget.onPeopleLoaded(people);
      final histories = await _history.fetchUserHistories(user.id);
      if (!mounted) return;
      setState(() {
        _histories = histories;
        _historiesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _historiesError = e.toString();
        _historiesLoading = false;
      });
    }
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loading = true);
    try {
      await _auth.signOut();
      if (!mounted) return;
      setState(() {
        _histories = [];
        _loading = false;
      });
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final loggedIn = user != null;

    return AlertDialog(
      title: Text(loggedIn ? 'User Information' : 'Login'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loggedIn) ...[
              CircleAvatar(
                radius: 30,
                backgroundImage: _auth.avatarUrl != null
                    ? NetworkImage(_auth.avatarUrl!)
                    : null,
                child: _auth.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                _auth.displayName ?? '-',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.main,
                ),
              ),
              Text(
                _auth.email ?? '',
                style: const TextStyle(color: AppColors.fourth),
              ),
              const SizedBox(height: 4),
              const Text(
                'Regular User',
                style: TextStyle(color: AppColors.fourth, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.main),
                  const SizedBox(width: 6),
                  Text(
                    'History (${_histories.length})',
                    style: const TextStyle(color: AppColors.main),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: _historiesLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _historiesError != null
                        ? Center(
                            child: Text(
                              _historiesError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.fourth),
                            ),
                          )
                        : _histories.isEmpty
                            ? const Center(
                                child: Text(
                                  'No history yet.',
                                  style: TextStyle(color: AppColors.fourth),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _histories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (_, i) {
                                  final h = _histories[i];
                                  final title = (h.memo ?? '').trim().isEmpty
                                      ? 'Untitled history'
                                      : h.memo!.trim();
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              HistoryScreen(historyId: h.id),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              AppColors.main.withValues(alpha: 0.2),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.main,
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            'View',
                                            style: TextStyle(
                                              color: AppColors.fourth,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.open_in_new,
                                            size: 14,
                                            color: AppColors.fourth,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              const UnknownPerson(size: AvatarSize.lg),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading
                    ? null
                    : () => loggedIn ? _logout() : _login(),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.g_mobiledata, size: 28),
                label: Text(loggedIn ? 'Logout' : 'Login with Google'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
