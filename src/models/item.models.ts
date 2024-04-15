
export interface ItemError {
  [key: string]: string;
}

export class Item {
  name: string;
  price: number;
  error: ItemError;


  constructor ({
    name = '' as string,
    price = 0 as number,
    error = {} as ItemError,
  }) {
    this.name = name;
    this.price = price;
    this.error = error;
  }

  isValid(): boolean {
    const error: ItemError = {};
    if (this.name === '') {
      error.name = 'Item name cannot be blank';
    }
    if (this.price === 0) {
      error.price = 'Item price cannot be zero';
    }
    this.error = error;
    return Object.keys(error).length === 0;
  }
}