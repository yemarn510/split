import { Item } from "./item.models";
import { Person } from "./person.models";


export class Result {
  person: Person;
  items: Item[];
  total: number;

  constructor({
    person = new Person({}),
    items = [],
    total = 0,
  }) {
    this.person = person;
    this.items = items;
    this.total = total;
  }
}