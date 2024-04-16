


export class Split {
  itemIndex: number;
  itemPrice: number;
  sharingPersonIndex: Set<number>;

  constructor({
    itemIndex = 0,
    itemPrice = 0,
    sharingPersonIndex = new Set<number>(),
  }) {
    this.itemIndex = itemIndex;
    this.itemPrice = itemPrice;
    this.sharingPersonIndex = sharingPersonIndex;
  };

}


export interface SplitDictionary {
  [key: string]: Split;
}