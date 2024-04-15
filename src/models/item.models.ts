

export class Item {
  name: string;
  price: number;

  constructor ({
    name = '' as string,
    price = 0 as number,
  }) {
    this.name = name;
    this.price = price;
  }
}