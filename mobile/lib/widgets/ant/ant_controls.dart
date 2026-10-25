import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// antd `<Checkbox>`: 16px box, 4px radius, 8px label padding, 14px label.
class AntCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;

  const AntCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!checked),
      child: SizedBox(
        height: 22,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: checked ? AppColors.main : AppColors.white,
                border: Border.all(color: checked ? AppColors.main : AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: checked ? const CustomPaint(painter: _TickPainter()) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(label, style: AppText.ant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  const _TickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.32);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// antd `<Radio>`: 16px circle, filled primary with a 6px white dot when checked.
class AntRadio extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final String label;

  const AntRadio({
    super.key,
    required this.checked,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 22,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? AppColors.main : AppColors.white,
                border: Border.all(color: checked ? AppColors.main : AppColors.border),
              ),
              child: checked
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(label, style: AppText.ant),
            ),
          ],
        ),
      ),
    );
  }
}

/// antd `<Spin />` (default size): four primary dots rotating in a 20px box.
class AntSpin extends StatefulWidget {
  const AntSpin({super.key});

  @override
  State<AntSpin> createState() => _AntSpinState();
}

class _AntSpinState extends State<AntSpin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Transform.rotate(
        angle: math.pi / 4 + _controller.value * 2 * math.pi,
        child: SizedBox(
          width: 20,
          height: 20,
          child: Stack(
            children: [
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: i.isOdd ? 11 : 0,
                  top: i >= 2 ? 11 : 0,
                  child: Opacity(
                    opacity: 0.3 +
                        0.7 * (0.5 + 0.5 * math.sin((_controller.value * 4 - i) * math.pi / 2)),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.main,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
