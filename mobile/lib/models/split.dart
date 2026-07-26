class Split {
  String itemUUID;
  double itemPrice;
  Set<String> sharingPersonUUIDs;

  Split({
    this.itemUUID = '',
    this.itemPrice = 0,
    Set<String>? sharingPersonUUIDs,
  }) : sharingPersonUUIDs = sharingPersonUUIDs ?? {};

  Split copyWith({
    String? itemUUID,
    double? itemPrice,
    Set<String>? sharingPersonUUIDs,
  }) {
    return Split(
      itemUUID: itemUUID ?? this.itemUUID,
      itemPrice: itemPrice ?? this.itemPrice,
      sharingPersonUUIDs:
          sharingPersonUUIDs ?? Set<String>.from(this.sharingPersonUUIDs),
    );
  }
}

typedef SplitDictionary = Map<String, Split>;
