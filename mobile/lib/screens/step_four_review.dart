import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/result.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/ant/ant.dart';
import '../widgets/item_results.dart';
import '../widgets/rounded_avatar.dart';

/// Port of step-4.tsx.
class StepFourReview extends StatefulWidget {
  final List<Result> results;

  const StepFourReview({super.key, required this.results});

  @override
  State<StepFourReview> createState() => _StepFourReviewState();
}

class _StepFourReviewState extends State<StepFourReview> {
  late List<Result> _visible;
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _visible = widget.results.where((r) => r.total > 0.00).toList();
    _expanded = List.filled(_visible.length, true);
    // Builds `paidByNItems` / `totalToPayFor` on each result, which the share
    // modal reads later.
    for (final result in _visible) {
      final paidByNItems = <String, List<Item>>{};
      for (final item in result.items) {
        paidByNItems.putIfAbsent(item.paidBy?.name ?? '', () => []).add(item);
      }
      final totalToPayFor = <String, double>{};
      paidByNItems.forEach((name, items) {
        var total = 0.0;
        for (final item in items) {
          total += item.isPercentage ? item.price : item.price / item.sharedNumber;
        }
        totalToPayFor[name] = total;
      });
      result.paidByNItems = paidByNItems;
      result.totalToPayFor = totalToPayFor;
    }
  }

  void _showDetails(Result result, String paidByName) {
    final items = result.items.where((e) => e.paidBy?.name == paidByName).toList();
    showAntModal<void>(
      context: context,
      title: 'Details',
      width: 400,
      builder: (_) => ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.second,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(child: ItemResults(items: items)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalTotal = widget.results.fold<double>(0, (sum, r) => sum + r.total);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _visible.length; i++) ...[
                _ResultCard(
                  result: _visible[i],
                  expanded: _expanded[i],
                  onToggle: () => setState(() => _expanded[i] = !_expanded[i]),
                  onTapPaidBy: (name) => _showDetails(_visible[i], name),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.main, width: 2)),
                ),
                child: DefaultTextStyle(
                  style: cssText(size: 24, lineHeight: 36, weight: FontWeight.w700, color: AppColors.main),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('Final Total'), Text(toFixed2(finalTotal))],
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

/// One bordered card: antd `<Collapse expandIconPosition="end">` + "Total".
class _ResultCard extends StatelessWidget {
  final Result result;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onTapPaidBy;

  const _ResultCard({
    required this.result,
    required this.expanded,
    required this.onToggle,
    required this.onTapPaidBy,
  });

  @override
  Widget build(BuildContext context) {
    final totals = result.totalToPayFor ?? {};

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.second,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Row(
                  children: [
                    SizedBox(
                      width: w / 5,
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.third,
                            shape: BoxShape.circle,
                          ),
                          child: ProfileImage(url: result.person.profile, size: 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: w * 3 / 5,
                      child: Text(
                        result.person.name.isEmpty ? '-' : result.person.name,
                        style: cssText(
                          size: 16,
                          lineHeight: 25.142857,
                          weight: FontWeight.w700,
                          color: AppColors.main,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 5, bottom: 5),
              child: AnimatedRotation(
                turns: expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: const AntIcon(AntIconData.caretRight, size: 12, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.second,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        children: [
          for (final name in totals.keys)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTapPaidBy(name),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Flexible(child: Text(name)),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.third,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${result.paidByNItems?[name]?.length ?? 0}',
                              style: cssText(size: 12, lineHeight: 20, color: AppColors.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          toFixed2(totals[name]!),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.fourth),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTextStyle(
            style: AppText.ant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: expanded ? content : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total'),
                Text(
                  toFixed2(result.total),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
