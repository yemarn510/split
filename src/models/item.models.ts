
export interface ItemError {
  [key: string]: string;
}

export class Item {
  name: string;
  price: number;
  image: string;
  sharedNumber: number;
  error: ItemError;


  constructor ({
    name = '' as string,
    price = 0 as number,
    quantity = 1 as number,
    image = '' as string,
    error = {} as ItemError,
    sharedNumber = 0 as number,
  }) {
    this.name = name;
    this.price = price;
    this.image = image;
    this.sharedNumber = sharedNumber;
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
    this.error = error;
    return Object.keys(error).length === 0;
  }
}