class HistorySummary {
  final String id;
  final String? memo;

  HistorySummary({required this.id, this.memo});

  factory HistorySummary.fromJson(Map<String, dynamic> json) {
    return HistorySummary(
      id: json['id'] as String,
      memo: json['memo'] as String?,
    );
  }
}

class HistoryResultRow {
  final String historyId;
  final int resultIndex;
  final int itemIndex;
  final String needToBePaidByUuid;
  final String needToBePaidByName;
  final String paidByUuid;
  final String paidByName;
  final String itemName;
  final int numberOfSharedPerson;
  final double amount;
  final double finalPrice;
  final bool isPercentage;

  HistoryResultRow({
    required this.historyId,
    required this.resultIndex,
    required this.itemIndex,
    required this.needToBePaidByUuid,
    required this.needToBePaidByName,
    required this.paidByUuid,
    required this.paidByName,
    required this.itemName,
    required this.numberOfSharedPerson,
    required this.amount,
    required this.finalPrice,
    required this.isPercentage,
  });

  Map<String, dynamic> toJson() => {
        'history_id': historyId,
        'result_index': resultIndex,
        'item_index': itemIndex,
        'need_to_be_paid_by_uuid': needToBePaidByUuid,
        'need_to_be_paid_by_name': needToBePaidByName,
        'paid_by_uuid': paidByUuid,
        'paid_by_name': paidByName,
        'item_name': itemName,
        'number_of_shared_person': numberOfSharedPerson,
        'amount': amount,
        'final_price': finalPrice,
        'is_percentage': isPercentage,
      };

  factory HistoryResultRow.fromJson(Map<String, dynamic> json) {
    return HistoryResultRow(
      historyId: json['history_id'] as String,
      resultIndex: json['result_index'] as int,
      itemIndex: json['item_index'] as int,
      needToBePaidByUuid: json['need_to_be_paid_by_uuid'] as String,
      needToBePaidByName: json['need_to_be_paid_by_name'] as String,
      paidByUuid: json['paid_by_uuid'] as String,
      paidByName: json['paid_by_name'] as String,
      itemName: json['item_name'] as String,
      numberOfSharedPerson: json['number_of_shared_person'] as int,
      amount: (json['amount'] as num).toDouble(),
      finalPrice: (json['final_price'] as num).toDouble(),
      isPercentage: json['is_percentage'] as bool? ?? false,
    );
  }
}
