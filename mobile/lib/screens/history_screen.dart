import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/history_service.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  final String historyId;

  const HistoryScreen({super.key, required this.historyId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryService _history =
      HistoryService(Supabase.instance.client);

  bool _loading = true;
  String? _error;
  String? _memo;
  String? _creatorName;
  Map<String, List<Map<String, dynamic>>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _history.fetchHistory(widget.historyId);
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final row in data.rows) {
        grouped.putIfAbsent(row.needToBePaidByName, () => []).add({
          'paidBy': row.paidByName,
          'item': row.itemName,
          'amount': row.amount,
          'final': row.finalPrice,
          'shared': row.numberOfSharedPerson,
          'isPercentage': row.isPercentage,
        });
      }
      if (!mounted) return;
      setState(() {
        _memo = data.memo;
        _creatorName = data.creatorName;
        _grouped = grouped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.second,
      appBar: AppBar(
        backgroundColor: AppColors.second,
        foregroundColor: AppColors.main,
        elevation: 0,
        title: const Text("Let's Split the Bills"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if ((_memo ?? '').isNotEmpty)
                      Text(
                        _memo!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.main,
                        ),
                      ),
                    if ((_creatorName ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        child: Text(
                          'Shared by $_creatorName',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.fourth),
                        ),
                      ),
                    ..._grouped.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.shareBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.fourth),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${entry.key} has to pay',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.main,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...entry.value.map((item) {
                              final line = item['isPercentage'] == true
                                  ? '${item['paidBy']} - ${item['item']} ${item['amount']} % - ${(item['final'] as double).toStringAsFixed(2)}'
                                  : '${item['paidBy']} - ${item['item']} ${item['amount']} / ${item['shared']} - ${(item['final'] as double).toStringAsFixed(2)}';
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(line),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
