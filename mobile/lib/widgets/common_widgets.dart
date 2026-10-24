import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CircleNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool dimmed;
  final bool labelAfter;

  const CircleNavButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.dimmed = false,
    this.labelAfter = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = [
      if (!labelAfter)
        Text(
          label,
          style: const TextStyle(color: AppColors.main, fontSize: 14),
        ),
      if (!labelAfter) const SizedBox(width: 6),
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.main),
        ),
        child: Icon(icon, color: AppColors.main, size: 18),
      ),
      if (labelAfter) const SizedBox(width: 6),
      if (labelAfter)
        Text(
          label,
          style: const TextStyle(color: AppColors.main, fontSize: 14),
        ),
    ];

    return Opacity(
      opacity: (enabled && !dimmed) ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
      ),
    );
  }
}

class PrimaryStickyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const PrimaryStickyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, height: 36, child: child);
    }
    return SizedBox(height: 36, child: child);
  }
}

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
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Step: $current/$total',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.main,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DesktopStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const DesktopStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 1,
                color: AppColors.fourth.withValues(alpha: 0.5),
              ),
            );
          }
          final index = i ~/ 2;
          final active = index <= currentStep;
          final current = index == currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current
                      ? AppColors.main
                      : (active
                          ? AppColors.main.withValues(alpha: 0.7)
                          : Colors.transparent),
                  border: Border.all(
                    color:
                        current || active ? AppColors.main : AppColors.fourth,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color:
                        current || active ? AppColors.white : AppColors.fourth,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 72,
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    color: current ? AppColors.main : AppColors.fourth,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
