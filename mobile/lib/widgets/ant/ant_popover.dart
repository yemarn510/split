import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'ant_button.dart';
import 'ant_icon.dart';

/// Floating bubble anchored to [child], placed like antd's `placement="top"`:
/// above the anchor, flipped below when there is no room, shifted to stay on
/// screen, with an arrow pointing at the anchor's center. It follows the
/// anchor while scrolling and does not block the page behind it.
class AntFloating extends StatefulWidget {
  final bool open;
  final Widget child;
  final WidgetBuilder bubbleBuilder;
  final Color color;
  final EdgeInsets padding;
  final double radius;
  final double maxWidth;
  final double minHeight;
  final VoidCallback? onTapOutside;

  const AntFloating({
    super.key,
    required this.open,
    required this.child,
    required this.bubbleBuilder,
    this.color = AppColors.white,
    this.padding = const EdgeInsets.all(12),
    this.radius = 8,
    this.maxWidth = double.infinity,
    this.minHeight = 0,
    this.onTapOutside,
  });

  @override
  State<AntFloating> createState() => _AntFloatingState();
}

class _AntFloatingState extends State<AntFloating> {
  final OverlayPortalController _controller = OverlayPortalController();
  final _ArrowDirection _arrow = _ArrowDirection();

  @override
  void initState() {
    super.initState();
    // Shown once before the portal attaches (toggling it during a rebuild
    // asserts); the bubble itself is only built while [AntFloating.open].
    _controller.show();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: this,
      child: OverlayPortal.overlayChildLayoutBuilder(
        controller: _controller,
        overlayChildBuilder: (context, info) {
          if (!widget.open) return const SizedBox.shrink();
          final anchor = MatrixUtils.transformRect(
            info.childPaintTransform,
            Offset.zero & info.childSize,
          );
          final topInset = MediaQuery.paddingOf(context).top;
          return SizedBox.fromSize(
            size: info.overlaySize,
            child: CustomMultiChildLayout(
              delegate: _FloatingLayout(
                anchor: anchor,
                maxWidth: widget.maxWidth,
                topInset: topInset,
                arrow: _arrow,
              ),
              children: [
                LayoutId(
                  id: _FloatingSlot.bubble,
                  child: TapRegion(
                    groupId: this,
                    onTapOutside: widget.onTapOutside == null
                        ? null
                        : (_) => widget.onTapOutside!(),
                    child: _ZoomIn(
                      child: Container(
                        constraints: BoxConstraints(minHeight: widget.minHeight),
                        padding: widget.padding,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(widget.radius),
                          boxShadow: kAntShadow,
                        ),
                        child: DefaultTextStyle(
                          style: AppText.ant,
                          child: Builder(builder: widget.bubbleBuilder),
                        ),
                      ),
                    ),
                  ),
                ),
                LayoutId(
                  id: _FloatingSlot.arrow,
                  child: IgnorePointer(
                    child: _ZoomIn(
                      child: CustomPaint(
                        size: const Size(16, 8),
                        painter: _ArrowPainter(widget.color, _arrow),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

enum _FloatingSlot { bubble, arrow }

/// Shared between the layout delegate (which decides the flip) and the arrow
/// painter (which paints after layout in the same frame).
class _ArrowDirection {
  bool pointsDown = true;
}

class _FloatingLayout extends MultiChildLayoutDelegate {
  final Rect anchor;
  final double maxWidth;
  final double topInset;
  final _ArrowDirection arrow;

  static const double _gap = 12;
  static const double _arrowHeight = 8;

  _FloatingLayout({
    required this.anchor,
    required this.maxWidth,
    required this.topInset,
    required this.arrow,
  });

  @override
  void performLayout(Size size) {
    final bubble = layoutChild(
      _FloatingSlot.bubble,
      BoxConstraints(maxWidth: math.min(maxWidth, size.width)),
    );
    layoutChild(_FloatingSlot.arrow, BoxConstraints.tight(const Size(16, _arrowHeight)));

    var top = anchor.top - _gap - bubble.height;
    final flip = top < topInset;
    if (flip) top = anchor.bottom + _gap;
    arrow.pointsDown = !flip;

    final double left = (anchor.center.dx - bubble.width / 2)
        .clamp(0.0, math.max(0.0, size.width - bubble.width));
    positionChild(_FloatingSlot.bubble, Offset(left, top));

    final double arrowLeft = (anchor.center.dx - 8)
        .clamp(left + 8, math.max(left + 8, left + bubble.width - 24));
    final arrowTop = flip ? top - _arrowHeight : top + bubble.height;
    positionChild(_FloatingSlot.arrow, Offset(arrowLeft, arrowTop));
  }

  @override
  bool shouldRelayout(covariant _FloatingLayout old) =>
      old.anchor != anchor || old.maxWidth != maxWidth || old.topInset != topInset;
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final _ArrowDirection direction;

  _ArrowPainter(this.color, this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (direction.pointsDown) {
      path
        ..moveTo(0, 0)
        ..lineTo(w, 0)
        ..lineTo(w / 2 + 1.5, h - 1.2)
        ..quadraticBezierTo(w / 2, h, w / 2 - 1.5, h - 1.2)
        ..close();
    } else {
      path
        ..moveTo(0, h)
        ..lineTo(w, h)
        ..lineTo(w / 2 + 1.5, 1.2)
        ..quadraticBezierTo(w / 2, 0, w / 2 - 1.5, 1.2)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) => true;
}

class _ZoomIn extends StatelessWidget {
  final Widget child;
  const _ZoomIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCirc,
      builder: (context, value, child) => Opacity(
        opacity: ((value - 0.8) / 0.2).clamp(0.0, 1.0),
        child: Transform.scale(scale: value, child: child),
      ),
      child: child,
    );
  }
}

/// Always-open validation tooltip from item-table.tsx:
/// `<Tooltip open color="#ff4d4f" zIndex={10}>`.
class AntErrorTooltip extends StatelessWidget {
  final String? message;
  final Widget child;

  const AntErrorTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final text = message ?? '';
    return AntFloating(
      open: text.isNotEmpty,
      color: AppColors.danger,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      radius: 6,
      maxWidth: 250,
      minHeight: 32,
      bubbleBuilder: (_) => Text(
        text,
        style: cssText(size: 14, lineHeight: 22, color: AppColors.black),
      ),
      child: child,
    );
  }
}

/// antd `<Popover title content>` with a `.ant-popover-title`.
class AntPopover extends StatelessWidget {
  final bool open;
  final String? title;
  final WidgetBuilder contentBuilder;
  final VoidCallback? onTapOutside;
  final Widget child;

  const AntPopover({
    super.key,
    required this.open,
    this.title,
    required this.contentBuilder,
    this.onTapOutside,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AntFloating(
      open: open,
      onTapOutside: onTapOutside,
      bubbleBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title!,
                style: cssText(
                  size: 14,
                  lineHeight: 22,
                  weight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          Builder(builder: contentBuilder),
        ],
      ),
      child: child,
    );
  }
}

/// antd `<Popconfirm>`: opens on tap of [child], closes on outside tap.
class AntPopconfirm extends StatefulWidget {
  final String title;
  final String description;
  final String okText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Widget child;

  const AntPopconfirm({
    super.key,
    required this.title,
    required this.description,
    this.okText = 'OK',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    required this.child,
  });

  @override
  State<AntPopconfirm> createState() => _AntPopconfirmState();
}

class _AntPopconfirmState extends State<AntPopconfirm> {
  bool _open = false;

  void _close() => setState(() => _open = false);

  @override
  Widget build(BuildContext context) {
    return AntFloating(
      open: _open,
      onTapOutside: _close,
      bubbleBuilder: (context) => IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 8),
                  child: AntIcon(
                    AntIconData.exclamationCircleFilled,
                    size: 14,
                    color: AppColors.warning,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: cssText(
                        size: 14,
                        lineHeight: 22,
                        weight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.description),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AntButton(small: true, label: widget.cancelText, onPressed: _close),
                const SizedBox(width: 8),
                AntButton.primary(
                  small: true,
                  label: widget.okText,
                  onPressed: () {
                    _close();
                    widget.onConfirm();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _open = !_open),
        child: widget.child,
      ),
    );
  }
}
