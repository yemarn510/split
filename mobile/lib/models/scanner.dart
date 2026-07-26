class OrderItem {
  final String name;
  final String translatedName;
  final String description;
  final double price;
  final int quantity;
  final double total;
  final bool isPercentage;
  final double percent;

  OrderItem({
    required this.name,
    required this.translatedName,
    this.description = '',
    required this.price,
    required this.quantity,
    required this.total,
    this.isPercentage = false,
    this.percent = 0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: (json['name'] ?? '').toString(),
      translatedName: (json['translated_name'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']),
      quantity: _toInt(json['quantity'], fallback: 1),
      total: _toDouble(json['total']),
      isPercentage: json['isPercentage'] == true,
      percent: _toDouble(json['percent']),
    );
  }
}

class ScanResponse {
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String date;
  final int estimatedDinerCount;

  ScanResponse({
    required this.items,
    this.subtotal = 0,
    this.tax = 0,
    this.total = 0,
    this.date = '',
    this.estimatedDinerCount = 0,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? [];
    return ScanResponse(
      items: rawItems
          .whereType<Map>()
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      subtotal: _toDouble(json['subtotal']),
      tax: _toDouble(json['tax']),
      total: _toDouble(json['total']),
      date: (json['date'] ?? '').toString(),
      estimatedDinerCount: _toInt(json['estimated_diner_count']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}
