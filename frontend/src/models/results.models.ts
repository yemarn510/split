import { PaidByAndItems, TotalToPayFor } from "@/components/step-4";
import { Item } from "./item.models";
import { Person } from "./person.models";


export class Result {
  person: Person;
  items: Item[];
  total: number;
  paidByNItems?: PaidByAndItems;
  totalToPayFor?: TotalToPayFor;
  totalPercentage: number;

  constructor({
    person = new Person({}),
    items = [],
    total = 0,
    totalPercentage = 0,
    paidByNItems: paidByNItems = {},
    totalToPayFor: TotalToPayFor = {}
  }) {
    this.person = person;
    this.items = items;
    this.total = total;
    this.paidByNItems = paidByNItems;
    this.totalToPayFor = TotalToPayFor;
    this.totalPercentage = totalPercentage;
  }
}