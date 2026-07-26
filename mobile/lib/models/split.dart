class ItemSplit {
  String itemUUID;
  double itemPrice;
  Set<String> sharingPersonUUIDs;

  ItemSplit({
    this.itemUUID = '',
    this.itemPrice = 0,
    Set<String>? sharingPersonUUIDs,
  }) : sharingPersonUUIDs = sharingPersonUUIDs ?? {};

  ItemSplit copyWith({
    String? itemUUID,
    double? itemPrice,
    Set<String>? sharingPersonUUIDs,
  }) {
    return ItemSplit(
      itemUUID: itemUUID ?? this.itemUUID,
      itemPrice: itemPrice ?? this.itemPrice,
      sharingPersonUUIDs:
          sharingPersonUUIDs ?? Set<String>.from(this.sharingPersonUUIDs),
    );
  }
}

typedef SplitDictionary = Map<String, ItemSplit>;
