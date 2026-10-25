import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/history.dart';
import '../models/item.dart';
import '../models/person.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ant/ant.dart';
import '../widgets/next_button.dart';

/// Port of frontend/src/app/history/[historyId]/page.tsx.
class HistoryScreen extends StatefulWidget {
  final String historyId;

  const HistoryScreen({super.key, required this.historyId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryService _history = HistoryService(Supabase.instance.client);

  List<HistoryResultRow>? _rows;
  String? _errorMessage;
  String? _memo;
  String? _creatorName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _history.fetchHistory(widget.historyId);
      if (!mounted) return;
      setState(() {
        _memo = data.memo;
        _creatorName = data.creatorName;
        _rows = data.rows;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e is PostgrestException ? e.message : '$e');
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(
      ClipboardData(text: '${AppConfig.webBaseUrl}/history/${widget.historyId}'),
    );
    AntMessage.info(context, 'Copied to clipboard!', seconds: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.second,
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    Widget plain(String text) => Align(alignment: Alignment.topLeft, child: Text(text));

    if (_errorMessage != null) return plain('Failed to load history: $_errorMessage');
    final rows = _rows;
    if (rows == null) return plain('Loading...');
    if (rows.isEmpty) return plain('No history results found.');

    final media = MediaQuery.of(context);
    final fullHeight = media.size.height - media.viewPadding.top - media.viewPadding.bottom;
    final md = media.size.width >= 768;
    final mainStyle = cssText(color: AppColors.main);
    final boldMain = mainStyle.copyWith(fontWeight: FontWeight.w700);

    final groups = <String, List<HistoryResultRow>>{};
    for (final row in rows) {
      groups.putIfAbsent(row.needToBePaidByUuid, () => []).add(row);
    }

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Let’s Split the Bills',
                  textAlign: TextAlign.center,
                  style: md
                      ? cssText(size: 48, lineHeight: 48, color: AppColors.main)
                      : cssText(size: 36, lineHeight: 40, color: AppColors.main),
                ),
                if ((_memo ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Memo:', style: boldMain),
                        TextSpan(text: ' $_memo'),
                      ]),
                      textAlign: TextAlign.center,
                      style: mainStyle,
                    ),
                  ),
                if ((_creatorName ?? '').isNotEmpty)
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'Shared by:', style: boldMain),
                      TextSpan(text: ' $_creatorName'),
                    ]),
                    textAlign: TextAlign.center,
                    style: mainStyle,
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  constraints: BoxConstraints(maxHeight: fullHeight - 200),
                  decoration: BoxDecoration(
                    color: AppColors.shareBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final group in groups.values) _group(group),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AntButton(
                        block: true,
                        icon: AntIconData.rollback,
                        label: 'Go to Home',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AntButton.primary(
                        block: true,
                        icon: AntIconData.shareAlt,
                        label: 'Share',
                        onPressed: _copyToClipboard,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _group(List<HistoryResultRow> rows) {
    final items = rows.map((row) {
      return Item(
        name: row.itemName,
        price: row.isPercentage ? row.finalPrice : row.amount,
        sharedNumber: row.numberOfSharedPerson == 0 ? 1 : row.numberOfSharedPerson,
        paidBy: Person(name: row.paidByName),
        isPercentage: row.isPercentage,
        percent: row.isPercentage ? row.amount : 0,
      );
    }).toList();

    final totals = <String, double>{};
    for (final row in rows) {
      totals[row.paidByName] = (totals[row.paidByName] ?? 0) + row.finalPrice;
    }

    return HasToPayGroup(
      name: rows.first.needToBePaidByName,
      items: items,
      totals: totals,
      headingLineHeight: 36,
    );
  }
}
