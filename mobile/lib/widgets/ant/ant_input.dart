import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// antd v5 `<Input>` with the globals.scss overrides: 16px text, 32px tall,
/// 0.15rem/0.25rem padding below 576px (0.5rem above). With a [suffix] it
/// renders as `.ant-input-affix-wrapper` (4px padding, 35px tall).
class AntInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final int? maxLength;
  final Color? borderColor;
  final Widget? suffix;
  final bool autofocus;

  const AntInput({
    super.key,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.maxLength,
    this.borderColor,
    this.suffix,
    this.autofocus = false,
  });

  @override
  State<AntInput> createState() => _AntInputState();
}

class _AntInputState extends State<AntInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_rebuild);
  }

  /// Browsers show the start of an input's value again once it loses focus.
  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _rebuild();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Alignment get _placeholderAlignment {
    switch (widget.textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final affix = widget.suffix != null;
    final enabled = widget.enabled;
    final focused = enabled && _focusNode.hasFocus;

    final Color textColor;
    final Color background;
    if (enabled) {
      textColor = AppColors.text;
      background = AppColors.white;
    } else if (affix) {
      textColor = AppColors.textDisabled;
      background = AppColors.fillDisabled;
    } else {
      textColor = AppColors.inputDisabledText;
      background = AppColors.inputDisabledBg;
    }

    final style = cssText(size: 16, lineHeight: 25.142857, color: textColor);
    final field = Stack(
      children: [
        if (_controller.text.isEmpty && widget.placeholder != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: _placeholderAlignment,
                child: Text(
                  widget.placeholder!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: widget.textAlign,
                  style: style.copyWith(color: AppColors.textDisabled),
                ),
              ),
            ),
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          scrollController: _scrollController,
          enabled: enabled,
          autofocus: widget.autofocus,
          style: style,
          textAlign: widget.textAlign,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.maxLength != null
              ? [LengthLimitingTextInputFormatter(widget.maxLength)]
              : null,
          cursorColor: AppColors.main,
          cursorWidth: 1,
          decoration: const InputDecoration.collapsed(hintText: null),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ],
    );

    final horizontal = affix
        ? (Breakpoints.md(context) ? 8.0 : 4.0)
        : (Breakpoints.sm(context) ? 8.0 : 4.0);

    return GestureDetector(
      onTap: enabled ? _focusNode.requestFocus : null,
      child: Container(
        height: affix ? null : 32,
        padding: affix
            ? EdgeInsets.symmetric(horizontal: horizontal, vertical: 4)
            : EdgeInsets.symmetric(horizontal: horizontal),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: !enabled
                ? AppColors.border
                : focused
                    ? AppColors.main
                    : (widget.borderColor ?? AppColors.border),
          ),
          boxShadow: focused
              ? const [BoxShadow(color: Color(0x14102C57), spreadRadius: 2)]
              : null,
        ),
        child: affix
            ? Row(
                children: [
                  Expanded(child: field),
                  const SizedBox(width: 4),
                  widget.suffix!,
                ],
              )
            : field,
      ),
    );
  }
}
