


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

export interface HistoryResult {
  history_id: string;
  result_index: number;
  item_index: number;
  need_to_be_paid_by_uuid: string;
  need_to_be_paid_by_name: string;
  paid_by_uuid: string;
  paid_by_name: string;
  item_name: string;
  number_of_shared_person: number;
  amount: number;
  final_price: number;
  is_percentage: boolean;
}