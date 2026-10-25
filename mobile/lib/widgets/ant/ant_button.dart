import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'ant_icon.dart';

enum AntButtonType { primary, normal }

/// antd v5 `<Button>`: 32px tall (24px when [small]), 6px radius, 14px text
/// and an 8px gap between icon and label.
class AntButton extends StatefulWidget {
  final String? label;
  final AntIconData? icon;
  final double iconSize;
  final Widget? child;
  final VoidCallback? onPressed;
  final AntButtonType type;
  final bool small;
  final bool loading;
  final bool disabled;

  /// Stretch to the available width (`w-full`).
  final bool block;
  final double? minWidth;
  final double? horizontalPadding;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;

  const AntButton({
    super.key,
    this.label,
    this.icon,
    this.iconSize = 14,
    this.child,
    this.onPressed,
    this.type = AntButtonType.normal,
    this.small = false,
    this.loading = false,
    this.disabled = false,
    this.block = false,
    this.minWidth,
    this.horizontalPadding,
    this.background,
    this.foreground,
    this.borderColor,
  });

  const AntButton.primary({
    super.key,
    this.label,
    this.icon,
    this.iconSize = 14,
    this.child,
    this.onPressed,
    this.small = false,
    this.loading = false,
    this.disabled = false,
    this.block = false,
    this.minWidth,
    this.horizontalPadding,
    this.background,
    this.foreground,
    this.borderColor,
  }) : type = AntButtonType.primary;

  @override
  State<AntButton> createState() => _AntButtonState();
}

class _AntButtonState extends State<AntButton> {
  bool _pressed = false;

  bool get _primary => widget.type == AntButtonType.primary;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled;
    final interactive = !disabled && !widget.loading && widget.onPressed != null;

    Color bg;
    Color fg;
    Color border;
    if (disabled) {
      bg = AppColors.fillDisabled;
      fg = AppColors.textDisabled;
      border = AppColors.border;
    } else if (_primary) {
      bg = widget.background ?? AppColors.main;
      fg = widget.foreground ?? AppColors.white;
      border = widget.borderColor ?? Colors.transparent;
      if (_pressed) bg = Color.lerp(bg, Colors.black, 0.3)!;
    } else {
      bg = widget.background ?? AppColors.white;
      fg = widget.foreground ?? AppColors.text;
      border = widget.borderColor ?? AppColors.border;
      if (_pressed) {
        fg = AppColors.main;
        border = AppColors.main;
      }
    }

    final textStyle = cssText(size: 14, lineHeight: 22, color: fg);
    final iconData = widget.loading ? AntIconData.loading : widget.icon;
    final hasLabel = widget.label != null || widget.child != null;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconData != null)
          AntIcon(
            iconData,
            size: widget.iconSize,
            color: fg,
            spin: identical(iconData, AntIconData.loading),
          ),
        if (iconData != null && hasLabel) const SizedBox(width: 8),
        if (widget.child != null)
          Flexible(child: widget.child!)
        else if (widget.label != null)
          Flexible(
            child: Text(
              widget.label!,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: textStyle,
            ),
          ),
      ],
    );

    final padding = widget.horizontalPadding ?? (widget.small ? 7 : 15);
    Widget button = Container(
      height: widget.small ? 24 : 32,
      constraints: BoxConstraints(minWidth: widget.minWidth ?? 0),
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(widget.small ? 4 : 6),
        boxShadow: !_primary && !disabled
            ? const [BoxShadow(color: Color(0x05000000), offset: Offset(0, 2))]
            : null,
      ),
      child: DefaultTextStyle.merge(style: textStyle, child: content),
    );

    if (widget.block) button = SizedBox(width: double.infinity, child: button);
    if (widget.loading) button = Opacity(opacity: 0.65, child: button);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      onTap: interactive ? widget.onPressed : null,
      child: button,
    );
  }
}
