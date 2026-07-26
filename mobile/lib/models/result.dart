import 'item.dart';
import 'person.dart';

class Result {
  Person person;
  List<Item> items;
  double total;
  Map<String, List<Item>>? paidByNItems;
  Map<String, double>? totalToPayFor;
  double totalPercentage;

  Result({
    required this.person,
    List<Item>? items,
    this.total = 0,
    this.totalPercentage = 0,
    this.paidByNItems,
    this.totalToPayFor,
  }) : items = items ?? [];
}
