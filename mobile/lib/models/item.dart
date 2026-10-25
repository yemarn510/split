import 'package:uuid/uuid.dart';
import 'person.dart';

/// Mirrors frontend/src/models/item.models.ts. Items are mutated in place the
/// same way the web components mutate them.
class Item {
  String uuid;
  String name;
  double price;
  double percent;
  double quantity;
  String image;
  int sharedNumber;
  Person? paidBy;
  bool isPercentage;
  Map<String, String> error;

  Item({
    String uuid = '',
    this.name = '',
    this.price = 0,
    this.quantity = 1,
    this.image = '',
    Map<String, String>? error,
    this.sharedNumber = 0,
    this.paidBy,
    this.isPercentage = false,
    this.percent = 0,
  })  : uuid = uuid.isEmpty ? const Uuid().v4() : uuid,
        error = error ?? {};

  /// `structuredClone(item)` followed by `new Item(...)`.
  Item clone() => Item(
        uuid: uuid,
        name: name,
        price: price,
        quantity: quantity,
        image: image,
        error: Map.of(error),
        sharedNumber: sharedNumber,
        paidBy: paidBy,
        isPercentage: isPercentage,
        percent: percent,
      );

  bool isValid() {
    final e = <String, String>{};
    if (name == '') e['name'] = 'Cannot be blank';
    if (price == 0) e['price'] = 'Cannot be zero';
    if (paidBy == null) e['paidBy'] = 'Cannot be blank';
    if (quantity == 0) e['quantity'] = 'Cannot be zero';
    error = e;
    return e.isEmpty;
  }
}
