import { PaidByAndItems, TotalToPayFor } from "@/components/step-4";
import { Item } from "./item.models";
import { Person } from "./person.models";


export class Result {
  person: Person;
  items: Item[];
  total: number;
  paidByNItems?: PaidByAndItems;
  totalToPayFor?: TotalToPayFor;


  constructor({
    person = new Person({}),
    items = [],
    total = 0,
    paidByNItems: paidByNItems = {},
    totalToPayFor: TotalToPayFor = {}
  }) {
    this.person = person;
    this.items = items;
    this.total = total;
    this.paidByNItems = paidByNItems;
    this.totalToPayFor = TotalToPayFor;
  }
}