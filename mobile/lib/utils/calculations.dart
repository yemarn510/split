import '../models/item.dart';
import '../models/person.dart';
import '../models/result.dart';
import '../models/split.dart';

/// Port of `calculateResults` in frontend/src/functions/common.functions.ts.
List<Result> calculateResults(
  List<Item> items,
  List<Person> people,
  SplitDictionary splitDict,
) {
  final itemDict = <String, Item>{for (final item in items) item.uuid: item};
  final personDict = <String, Result>{
    for (final person in people) person.uuid: Result(person: person),
  };

  splitDict.forEach((itemUUID, split) {
    final peopleUUIDs = split.sharingPersonUUIDs.toList();
    for (final personUUID in peopleUUIDs) {
      final result = personDict[personUUID];
      final item = itemDict[itemUUID];
      if (result != null && item != null) {
        item.sharedNumber = peopleUUIDs.length;
        result.items.add(item);
        if (!item.isPercentage) {
          result.total += item.price / peopleUUIDs.length;
        }
      }
    }
  });

  return personDict.values.map((result) {
    final items = result.items.map((e) => e.clone()).toList();
    Item? firstWhereOrNull(bool Function(Item) test) {
      for (final e in items) {
        if (test(e)) return e;
      }
      return null;
    }

    final serviceCharges =
        firstWhereOrNull((e) => e.name.toLowerCase().contains('service'));
    final tax = firstWhereOrNull((e) =>
        e.name.toLowerCase().contains('tax') || e.name.toLowerCase().contains('vat'));
    final notPercentItems = items.where((e) => !e.isPercentage).toList();

    final totalDict = <String, double>{};
    for (final each in notPercentItems) {
      final paidByUUID = each.paidBy?.uuid;
      if (paidByUUID != null) {
        totalDict[paidByUUID] = (totalDict[paidByUUID] ?? 0) +
            each.price / (each.sharedNumber == 0 ? 1 : each.sharedNumber);
      }
    }

    var finalTotal = result.total;
    var serviceChargesPrice = 0.0;

    if (serviceCharges != null) {
      final paidByUUID = serviceCharges.paidBy?.uuid;
      final baseTotal = paidByUUID != null ? (totalDict[paidByUUID] ?? 0) : 0.0;
      serviceCharges.price = baseTotal * (serviceCharges.percent / 100);
      serviceChargesPrice = serviceCharges.price;
      finalTotal += serviceCharges.price;
    }

    if (tax != null) {
      final paidByUUID = tax.paidBy?.uuid;
      final baseTotal = paidByUUID != null ? (totalDict[paidByUUID] ?? 0) : 0.0;
      tax.price = (baseTotal + serviceChargesPrice) * (tax.percent / 100);
      finalTotal += tax.price;
    }

    final finalItems = notPercentItems;
    if (serviceCharges != null) finalItems.add(serviceCharges);
    if (tax != null) finalItems.add(tax);

    result.items = finalItems;
    result.total = finalTotal;
    return result;
  }).toList();
}

/// Port of `someStepsAreEmpty`.
bool someStepsAreEmpty(SplitDictionary splitDict) {
  return splitDict.values.any((s) => s.sharingPersonUUIDs.isEmpty);
}

/// `FOOD_IMAGES` in step-3.tsx, same order.
const List<String> foodImages = [
  'assets/svgs/reshot-icon-canned-fish-food-UHEQNSRM5T.svg',
  'assets/svgs/reshot-icon-chinese-food-TWD823CXPR.svg',
  'assets/svgs/reshot-icon-coffee-cup-TAV8UMWY7P.svg',
  'assets/svgs/reshot-icon-donut-5SQ3GDBYH4.svg',
  'assets/svgs/reshot-icon-fast-food-LQAPTFMSYJ.svg',
  'assets/svgs/reshot-icon-fish-food-DLVAPR347Z.svg',
  'assets/svgs/reshot-icon-food-32ZVXF59MT.svg',
  'assets/svgs/reshot-icon-food-bowl-with-lid-U9YN7LZAW3.svg',
  'assets/svgs/reshot-icon-food-drink-B4CS9RFA8L.svg',
  'assets/svgs/reshot-icon-food-JY2ZKM765U.svg',
  'assets/svgs/reshot-icon-fried-chicken-XAK6QZ3HBV.svg',
  'assets/svgs/reshot-icon-hot-food-DUYKGBF2XM.svg',
  'assets/svgs/reshot-icon-loaded-fries-6AF2QRM5VT.svg',
  'assets/svgs/reshot-icon-pizza-B9CZFQ6G7J.svg',
  'assets/svgs/reshot-icon-steak-dish-E6HGXNSQVY.svg',
  'assets/svgs/reshot-icon-burger-9KYM62VBX8.svg',
  'assets/svgs/reshot-icon-healthy-salad-2N7PDVZ6FU.svg',
  'assets/svgs/reshot-icon-noodle-K73RD5GY8V.svg',
  'assets/svgs/reshot-icon-salad-Q9GZYMD34B.svg',
  'assets/svgs/reshot-icon-soda-WPRA7HT5E6.svg',
  'assets/svgs/reshot-icon-soup-4HS8NVM7ZB.svg',
];
