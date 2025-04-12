


export class Split {
  itemUUID: string;
  itemPrice: number;
  sharingPersonUUIDs: Set<string>;

  constructor({
    itemUUID = '',
    itemPrice = 0,
    sharingPersonUUIDs = new Set<string>(),
  }) {
    this.itemUUID = itemUUID;
    this.itemPrice = itemPrice;
    this.sharingPersonUUIDs = sharingPersonUUIDs;
  };

}


export interface SplitDictionary {
  [itemIndex: string]: Split;
}