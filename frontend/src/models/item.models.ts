import { Person } from "./person.models";

export interface ItemError {
  [key: string]: string;
}

export class Item {
  name: string;
  price: number;
  quantity: number;
  image: string;
  sharedNumber: number;
  error: ItemError;
  paidBy: Person | null;


  constructor ({
    name = '' as string,
    price = 0 as number,
    quantity = 1 as number,
    image = '' as string,
    error = {} as ItemError,
    sharedNumber = 0 as number,
    paidBy = null as Person | null,
  }) {
    this.name = name;
    this.price = price;
    this.quantity = quantity;
    this.image = image;
    this.sharedNumber = sharedNumber;
    this.paidBy = paidBy;
    this.error = error;
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