import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'ant_icon.dart';

/// Shows an antd v5 centered `<Modal>`. [onCancel] runs for the close button
/// and mask clicks, like antd's `onCancel`; it defaults to popping the modal.
Future<T?> showAntModal<T>({
  required BuildContext context,
  String? title,
  Widget? titleWidget,
  required WidgetBuilder builder,
  double width = 520,
  bool closable = true,
  bool maskClosable = true,
  VoidCallback? onCancel,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.mask,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogContext, _, __) {
      void cancel() =>
          onCancel != null ? onCancel() : Navigator.of(dialogContext).pop();
      return _AntModalScaffold(
        width: width,
        title: titleWidget ?? (title != null ? Text(title) : null),
        closable: closable,
        onMaskTap: maskClosable ? cancel : null,
        onClose: cancel,
        child: Builder(builder: builder),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCirc);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.2, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AntModalScaffold extends StatelessWidget {
  final double width;
  final Widget? title;
  final bool closable;
  final VoidCallback? onMaskTap;
  final VoidCallback onClose;
  final Widget child;

  const _AntModalScaffold({
    required this.width,
    required this.title,
    required this.closable,
    required this.onMaskTap,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final md = media.size.width >= 768;
    final modalWidth = math.min(width, media.size.width - (md ? 32 : 16));

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onMaskTap),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AntModalPanel(
                    width: modalWidth,
                    padding: md ? 16 : 8,
                    title: title,
                    closable: closable,
                    onClose: onClose,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `.ant-modal-content`: white, 8px radius, title + body.
class AntModalPanel extends StatelessWidget {
  final double width;
  final double padding;
  final Widget? title;
  final bool closable;
  final VoidCallback onClose;
  final Widget child;

  const AntModalPanel({
    super.key,
    required this.width,
    required this.padding,
    required this.title,
    required this.closable,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: kAntShadow,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: DefaultTextStyle(
              style: AppText.ant,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, right: closable ? 32 : 0),
                      child: DefaultTextStyle(
                        style: cssText(
                          size: 16,
                          lineHeight: 24,
                          weight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        child: title!,
                      ),
                    ),
                  child,
                ],
              ),
            ),
          ),
          if (closable)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: AntIcon(
                      AntIconData.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `.ant-modal-footer`: right-aligned buttons, 12px above, 8px apart.
class AntModalFooter extends StatelessWidget {
  final List<Widget> children;

  const AntModalFooter({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}
