import { Person } from "./person.models";

export interface ItemError {
  [key: string]: string;
}

export class Item {
  uuid: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
  sharedNumber: number;
  error: ItemError;
  paidBy: Person | null;


  constructor ({
    uuid = '' as string,
    name = '' as string,
    price = 0 as number,
    quantity = 1 as number,
    image = '' as string,
    error = {} as ItemError,
    sharedNumber = 0 as number,
    paidBy = null as Person | null,
  }) {
    this.uuid = uuid || this.randomUUID();
    this.name = name;
    this.price = price;
    this.quantity = quantity;
    this.image = image;
    this.sharedNumber = sharedNumber;
    this.paidBy = paidBy;
    this.error = error;
  }

  randomUUID(): string {
    return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
      (+c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> +c / 4).toString(16)
    );
  }

  isValid(): boolean {
    const error: ItemError = {};
    if (this.name === '') {
      error.name = 'Cannot be blank';
    }
    if (this.price === 0) {
      error.price = 'Cannot be zero';
    }
    if (this.paidBy === null) {
      error.paidBy = 'Cannot be blank';
    }
    if (this.quantity === 0) {
      error.quantity = 'Cannot be zero';
    }
    this.error = error;
    return Object.keys(error).length === 0;
  }
}