import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'ant_icon.dart';

enum AntMessageType { success, error, info }

/// antd `message.useMessage()`: white notices stacked at the top center.
class AntMessage {
  static OverlayEntry? _entry;
  static final List<_Notice> _notices = [];

  static void error(BuildContext context, String text, {double seconds = 3}) =>
      show(context, text, type: AntMessageType.error, seconds: seconds);

  static void success(BuildContext context, String text, {double seconds = 3}) =>
      show(context, text, type: AntMessageType.success, seconds: seconds);

  static void info(BuildContext context, String text, {double seconds = 3}) =>
      show(context, text, type: AntMessageType.info, seconds: seconds);

  static void show(
    BuildContext context,
    String text, {
    AntMessageType type = AntMessageType.info,
    double seconds = 3,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final notice = _Notice(text, type);
    _notices.add(notice);
    if (_entry == null) {
      _entry = OverlayEntry(builder: (_) => _MessageList(notices: List.of(_notices)));
      overlay.insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }

    Timer(Duration(milliseconds: (seconds * 1000).round()), () {
      notice.leaving = true;
      _entry?.markNeedsBuild();
      Timer(const Duration(milliseconds: 300), () {
        _notices.remove(notice);
        if (_notices.isEmpty) {
          _entry?.remove();
          _entry = null;
        } else {
          _entry?.markNeedsBuild();
        }
      });
    });
  }
}

class _Notice {
  final String text;
  final AntMessageType type;
  final Key key = UniqueKey();
  bool leaving = false;

  _Notice(this.text, this.type);
}

class _MessageList extends StatelessWidget {
  final List<_Notice> notices;

  const _MessageList({required this.notices});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    return Positioned(
      top: top + 8,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (final notice in notices)
                _NoticeView(key: notice.key, notice: notice),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeView extends StatelessWidget {
  final _Notice notice;

  const _NoticeView({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notice.type) {
      AntMessageType.success => (AntIconData.checkCircleFilled, AppColors.success),
      AntMessageType.error => (AntIconData.closeCircleFilled, AppColors.danger),
      AntMessageType.info => (AntIconData.infoCircleFilled, AppColors.info),
    };

    final content = Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: kAntShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AntIcon(icon, size: 16, color: color),
            ),
            Flexible(
              child: Text(
                notice.text,
                textAlign: TextAlign.center,
                style: AppText.ant,
              ),
            ),
          ],
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: notice.leaving ? 0 : 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCirc,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (t - 1) * 30), child: child),
      ),
      child: content,
    );
  }
}
