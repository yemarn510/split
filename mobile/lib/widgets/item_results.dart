import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/format.dart';

/// item-results.tsx: "Paid By ( Item )" on the left, "price / shared" and the
/// share amount on the right. Inherits the surrounding font size.
class ItemResults extends StatelessWidget {
  final List<Item> items;

  const ItemResults({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text('${item.paidBy?.name ?? ''} ( ${item.name} )')),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          item.isPercentage
                              ? '${jsNum(item.percent)} %'
                              : '${jsNum(item.price)} / ${jsNum(item.sharedNumber)}',
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 70),
                        child: Text(
                          toFixed2(item.isPercentage
                              ? item.price
                              : item.price / item.sharedNumber),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
