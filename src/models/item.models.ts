
export interface ItemError {
  [key: string]: string;
}

export class Item {
  name: string;
  price: number;
  quantity: number;
  error: ItemError;


  constructor ({
    name = '' as string,
    price = 0 as number,
    quantity = 1 as number,
    error = {} as ItemError,
  }) {
    this.name = name;
    this.price = price;
    this.quantity = quantity;
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
    if (this.quantity === 0) {
      error.quantity = 'Cannot be zero';
    }
    this.error = error;
    return Object.keys(error).length === 0;
  }
}