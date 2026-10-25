import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ant/ant.dart';

/// "Go Back" / "Go Next" / "Share" controls in page.tsx and next-button.tsx:
/// a 40px outlined circle with an arrow plus a `text-main` label.
class CircleNavButton extends StatelessWidget {
  final AntIconData icon;
  final String label;
  final bool labelFirst;
  final bool dimmed;
  final VoidCallback onTap;

  const CircleNavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelFirst = false,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(width: Breakpoints.md(context) ? 12 : 4);
    final text = Text(label, style: cssText(color: AppColors.main));
    final circle = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.main),
      ),
      child: AntIcon(icon, size: 16, color: AppColors.main),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: labelFirst ? [text, gap, circle] : [circle, gap, text],
        ),
      ),
    );
  }
}

/// Mobile step header (`md:hidden`): "Step: n/4" pill and the step title.
class StepBadge extends StatelessWidget {
  final int current;
  final int total;
  final String title;

  const StepBadge({
    super.key,
    required this.current,
    required this.total,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.main,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text('Step: $current/$total', style: cssText(color: AppColors.white)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: cssText(size: 24, lineHeight: 36, color: AppColors.main),
          ),
        ),
      ],
    );
  }
}

/// antd `<Steps size="small" labelPlacement="vertical">` shown from `md:` up.
class AntSteps extends StatelessWidget {
  final int current;
  final List<String> steps;

  const AntSteps({super.key, required this.current, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: i == 0
                            ? const SizedBox.shrink()
                            : Container(
                                height: 1,
                                margin: const EdgeInsets.only(right: 12),
                                color: i <= current ? AppColors.main : const Color(0x0F050505),
                              ),
                      ),
                      _StepIcon(index: i, current: current),
                      Expanded(
                        child: i == steps.length - 1
                            ? const SizedBox.shrink()
                            : Container(
                                height: 1,
                                margin: const EdgeInsets.only(left: 12),
                                color: i < current ? AppColors.main : const Color(0x0F050505),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  style: cssText(
                    size: 14,
                    lineHeight: 22,
                    color: i <= current ? AppColors.text : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  final int index;
  final int current;

  const _StepIcon({required this.index, required this.current});

  @override
  Widget build(BuildContext context) {
    final finished = index < current;
    final active = index == current;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.main
            : finished
                ? AppColors.primaryBg
                : const Color(0x0F000000),
      ),
      child: finished
          ? const AntIcon(AntIconData.check, size: 12, color: AppColors.main)
          : Text(
              '${index + 1}',
              style: cssText(
                size: 12,
                lineHeight: 24,
                color: active ? AppColors.white : const Color(0xA6000000),
              ),
            ),
    );
  }
}

/// Tailwind `grid grid-cols-N gap-X`: equal-width columns, rows as tall as
/// their tallest cell, cells stretched to the row height.
class CssGrid extends StatelessWidget {
  final int columns;
  final double gap;
  final List<Widget> children;

  const CssGrid({
    super.key,
    required this.columns,
    required this.gap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      if (start > 0) rows.add(SizedBox(height: gap));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: gap),
              Expanded(
                child: start + c < children.length
                    ? children[start + c]
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// `<hr className="border-dashed">`: a 1px dashed rule.
class DashedLine extends StatelessWidget {
  final Color color;

  const DashedLine({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter(color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;

  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 3, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) => oldDelegate.color != color;
}
