import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/result.dart';
import '../theme/app_colors.dart';
import '../widgets/rounded_avatar.dart';

class StepFourReview extends StatefulWidget {
  final List<Result> results;

  const StepFourReview({
    super.key,
    required this.results,
  });

  @override
  State<StepFourReview> createState() => _StepFourReviewState();
}

class _StepFourReviewState extends State<StepFourReview> {
  late List<_PreparedResult> _prepared;

  @override
  void initState() {
    super.initState();
    _prepared = _buildPrepared(widget.results);
  }

  @override
  void didUpdateWidget(covariant StepFourReview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.results != widget.results) {
      _prepared = _buildPrepared(widget.results);
    }
  }

  List<_PreparedResult> _buildPrepared(List<Result> results) {
    return results.where((r) => r.total > 0).map((result) {
      final paidByNItems = <String, List<Item>>{};
      final totalToPayFor = <String, double>{};

      for (final item in result.items) {
        final name = item.paidBy?.name ?? '';
        paidByNItems.putIfAbsent(name, () => []).add(item);
      }

      paidByNItems.forEach((name, items) {
        var total = 0.0;
        for (final item in items) {
          total += item.isPercentage
              ? item.price
              : item.price / (item.sharedNumber == 0 ? 1 : item.sharedNumber);
        }
        totalToPayFor[name] = total;
      });

      result.paidByNItems = paidByNItems;
      result.totalToPayFor = totalToPayFor;

      return _PreparedResult(
        result: result,
        paidByNItems: paidByNItems,
        totalToPayFor: totalToPayFor,
        expanded: true,
      );
    }).toList();
  }

  void _showDetails(Result result, String paidByName) {
    final filtered =
        result.items.where((e) => e.paidBy?.name == paidByName).toList();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Details'),
          content: Container(
            width: 320,
            constraints: const BoxConstraints(maxHeight: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.second,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              shrinkWrap: true,
              children: filtered.map((item) {
                final share = item.sharedNumber == 0 ? 1 : item.sharedNumber;
                final line = item.isPercentage
                    ? '${item.paidBy?.name} - ${item.name} ${item.percent} % - ${item.price.toStringAsFixed(2)}'
                    : '${item.paidBy?.name} - ${item.name} ${item.price} / $share - ${(item.price / share).toStringAsFixed(2)}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(line, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalTotal =
        widget.results.fold<double>(0, (sum, r) => sum + r.total);

    return ListView(
      children: [
        ..._prepared.asMap().entries.map((entry) {
          final index = entry.key;
          final prepared = entry.value;
          final result = prepared.result;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.fourth),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: prepared.expanded,
                    onExpansionChanged: (open) {
                      setState(() {
                        _prepared[index] = prepared.copyWith(expanded: open);
                      });
                    },
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    backgroundColor: AppColors.second,
                    collapsedBackgroundColor: AppColors.second,
                    trailing: Icon(
                      prepared.expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: AppColors.main,
                    ),
                    title: Row(
                      children: [
                        PersonAvatarOnly(
                          profileUrl: result.person.profile,
                          size: 48,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            result.person.name.isEmpty
                                ? '-'
                                : result.person.name,
                            style: const TextStyle(
                              color: AppColors.main,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: prepared.totalToPayFor.entries.map((e) {
                      final count = prepared.paidByNItems[e.key]?.length ?? 0;
                      return InkWell(
                        onTap: () => _showDetails(result, e.key),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Flexible(child: Text(e.key)),
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
                                        '$count',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  e.value.toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total'),
                      Text(
                        result.total.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.main, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Total',
                style: TextStyle(
                  color: AppColors.main,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                finalTotal.toStringAsFixed(2),
                style: const TextStyle(
                  color: AppColors.main,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreparedResult {
  final Result result;
  final Map<String, List<Item>> paidByNItems;
  final Map<String, double> totalToPayFor;
  final bool expanded;

  _PreparedResult({
    required this.result,
    required this.paidByNItems,
    required this.totalToPayFor,
    required this.expanded,
  });

  _PreparedResult copyWith({bool? expanded}) {
    return _PreparedResult(
      result: result,
      paidByNItems: paidByNItems,
      totalToPayFor: totalToPayFor,
      expanded: expanded ?? this.expanded,
    );
  }
}
