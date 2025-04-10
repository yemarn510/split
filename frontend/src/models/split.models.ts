


export class Split {
  itemIndex: number;
  itemPrice: number;
  sharingPersonUUIDs: Set<string>;

  constructor({
    itemIndex = 0,
    itemPrice = 0,
    sharingPersonUUIDs = new Set<string>(),
  }) {
    this.itemIndex = itemIndex;
    this.itemPrice = itemPrice;
    this.sharingPersonUUIDs = sharingPersonUUIDs;
  };

}


export interface SplitDictionary {
  [itemIndex: string]: Split;
}