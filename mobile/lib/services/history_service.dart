import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history.dart';
import '../models/result.dart';

class HistoryService {
  HistoryService(this._client);

  final SupabaseClient _client;

  Future<List<HistorySummary>> fetchUserHistories(String userId) async {
    final data = await _client
        .from('history')
        .select('id, memo')
        .eq('creator_user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List)
        .map((e) => HistorySummary.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<String> saveHistory({
    required User user,
    required List<Result> results,
    String? memo,
  }) async {
    final creatorName = (user.userMetadata?['full_name'] as String?) ??
        (user.userMetadata?['name'] as String?) ??
        user.email ??
        'Unknown';

    final historyInsert = await _client
        .from('history')
        .insert({
          'creator_user_id': user.id,
          'creator_name': creatorName,
          'memo': (memo == null || memo.trim().isEmpty) ? null : memo.trim(),
        })
        .select('id')
        .single();

    final historyId = historyInsert['id'] as String;
    final rows = <Map<String, dynamic>>[];

    for (var resultIndex = 0; resultIndex < results.length; resultIndex++) {
      final result = results[resultIndex];
      if (result.total <= 0) continue;

      for (var itemIndex = 0; itemIndex < result.items.length; itemIndex++) {
        final item = result.items[itemIndex];
        if (item.paidBy == null) continue;

        final shared = item.sharedNumber == 0 ? 1 : item.sharedNumber;
        rows.add(
          HistoryResultRow(
            historyId: historyId,
            resultIndex: resultIndex,
            itemIndex: itemIndex,
            needToBePaidByUuid: result.person.uuid,
            needToBePaidByName: result.person.name,
            paidByUuid: item.paidBy!.uuid,
            paidByName: item.paidBy!.name,
            itemName: item.name,
            numberOfSharedPerson: item.sharedNumber,
            amount: item.isPercentage ? item.percent : item.price,
            finalPrice:
                item.isPercentage ? item.price : item.price / shared,
            isPercentage: item.isPercentage,
          ).toJson(),
        );
      }
    }

    if (rows.isNotEmpty) {
      await _client.from('history_results').insert(rows);
    }

    return historyId;
  }

  Future<({String? memo, String? creatorName, List<HistoryResultRow> rows})>
      fetchHistory(String historyId) async {
    final header = await _client
        .from('history')
        .select('memo, creator_name')
        .eq('id', historyId)
        .maybeSingle();

    final data = await _client
        .from('history_results')
        .select()
        .eq('history_id', historyId)
        .order('result_index')
        .order('item_index');

    final rows = (data as List)
        .map((e) =>
            HistoryResultRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return (
      memo: header?['memo'] as String?,
      creatorName: header?['creator_name'] as String?,
      rows: rows,
    );
  }
}
