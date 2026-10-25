import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/history.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ant/ant.dart';
import 'rounded_avatar.dart';

/// The `user` / `histories` state of login-popup.tsx, owned by the home screen
/// so it survives the popup closing.
class LoginState extends ChangeNotifier {
  User? user;
  List<HistorySummary>? histories;
  bool historiesLoading = false;
  String? historiesError;

  void update(void Function(LoginState state) change) {
    change(this);
    notifyListeners();
  }
}

/// Bottom-left login trigger and its "Login" / "User Information" modal.
class LoginPopup extends StatelessWidget {
  final LoginState state;
  final AuthService auth;
  final bool isPremiumUser;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final ValueChanged<String> onOpenHistory;

  const LoginPopup({
    super.key,
    required this.state,
    required this.auth,
    required this.isPremiumUser,
    required this.onLogin,
    required this.onLogout,
    required this.onOpenHistory,
  });

  void _openPopup(BuildContext context) {
    showAntModal<void>(
      context: context,
      titleWidget: ListenableBuilder(
        listenable: state,
        builder: (_, __) => Text(state.user != null ? 'User Information' : 'Login'),
      ),
      builder: (modalContext) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => _PopupBody(
          state: state,
          auth: auth,
          isPremiumUser: isPremiumUser,
          onLogin: onLogin,
          onLogout: onLogout,
          onOpenHistory: (id) {
            Navigator.of(modalContext).pop();
            onOpenHistory(id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final md = Breakpoints.md(context);
    final gap = SizedBox(width: md ? 12 : 4);

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPopup(context),
        child: state.user != null
            ? Container(
                padding: EdgeInsets.fromLTRB(4, 4, md ? 12 : 4, 4),
                decoration: BoxDecoration(
                  color: AppColors.third,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GoogleAvatar(url: auth.avatarUrl, size: 35),
                    gap,
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        auth.fullName,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [const UnknownPerson(), gap, const Text('Login')],
              ),
      ),
    );
  }
}

class _PopupBody extends StatelessWidget {
  final LoginState state;
  final AuthService auth;
  final bool isPremiumUser;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final ValueChanged<String> onOpenHistory;

  const _PopupBody({
    required this.state,
    required this.auth,
    required this.isPremiumUser,
    required this.onLogin,
    required this.onLogout,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.user;
    final md = Breakpoints.md(context);

    // `mt-5` collapses with the title's 8px bottom margin: 20px in total.
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Flex(
                        direction: md ? Axis.horizontal : Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GoogleAvatar(url: auth.avatarUrl, size: 60),
                          SizedBox(width: md ? 20 : 0, height: md ? 0 : 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.fullName),
                              Text(auth.email),
                              Text(
                                isPremiumUser ? 'Premium User' : 'Regular User',
                                style: cssText(
                                  size: 11.2,
                                  lineHeight: 17.6,
                                  color: isPremiumUser ? AppColors.gold : AppColors.fourth,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 300),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AntIcon(AntIconData.history, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'History${state.histories != null ? ' (${state.histories!.length})' : ''}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(width: 300, child: _historyList()),
                  ],
                ),
              ),
            AntButton.primary(
              minWidth: 300,
              icon: AntIconData.google,
              label: user != null ? 'Logout' : 'Login with Google',
              onPressed: user != null ? onLogout : onLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyList() {
    final muted = cssText(size: 14, lineHeight: 22, color: AppColors.fourth);
    if (state.historiesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: AntSpin()),
      );
    }
    if (state.historiesError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(state.historiesError!, textAlign: TextAlign.center, style: muted),
      );
    }
    final histories = state.histories;
    if (histories == null || histories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text('No history yet.', textAlign: TextAlign.center, style: muted),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(right: 4),
        itemCount: histories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final history = histories[i];
          final memo = history.memo ?? '';
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onOpenHistory(history.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.main.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      memo.trim().isNotEmpty ? memo : 'Untitled history',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: cssText(
                        size: 14,
                        lineHeight: 22,
                        weight: FontWeight.w600,
                        color: AppColors.main,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('View', style: muted),
                  const SizedBox(width: 8),
                  const AntIcon(AntIconData.exportIcon, size: 14, color: AppColors.fourth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// `next/image` with the Google `avatar_url`, `rounded-full`.
class _GoogleAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const _GoogleAvatar({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? null
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
      ),
    );
  }
}
