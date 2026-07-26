import 'package:uuid/uuid.dart';
import 'person.dart';

class Item {
  late String uuid;
  String name;
  double price;
  double percent;
  int quantity;
  String image;
  int sharedNumber;
  Person? paidBy;
  bool isPercentage;
  late Map<String, String> error;

  Item({
    String? uuid,
    this.name = '',
    this.price = 0,
    this.quantity = 1,
    this.image = '',
    this.sharedNumber = 0,
    this.paidBy,
    this.isPercentage = false,
    this.percent = 0,
    Map<String, String>? error,
  }) {
    this.uuid = uuid ?? Uuid().v4();
    this.error = error ?? {};
  }

  Item copyWith({
    String? uuid,
    String? name,
    double? price,
    double? percent,
    int? quantity,
    String? image,
    int? sharedNumber,
    Person? paidBy,
    bool? isPercentage,
    Map<String, String>? error,
    bool clearPaidBy = false,
  }) {
    return Item(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      price: price ?? this.price,
      percent: percent ?? this.percent,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      sharedNumber: sharedNumber ?? this.sharedNumber,
      paidBy: clearPaidBy ? null : (paidBy ?? this.paidBy),
      isPercentage: isPercentage ?? this.isPercentage,
      error: error ?? Map<String, String>.from(this.error),
    );
  }

  bool isValid() {
    final e = <String, String>{};
    if (name.isEmpty) e['name'] = 'Cannot be blank';
    if (price == 0) e['price'] = 'Cannot be zero';
    if (paidBy == null) e['paidBy'] = 'Cannot be blank';
    if (quantity == 0) e['quantity'] = 'Cannot be zero';
    error = e;
    return e.isEmpty;
  }
}
