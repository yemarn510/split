import { UploadFile } from "antd";
import { Person } from "./person.models";


export class Scanner {
  paidBy: Person | null;
  image: UploadFile | null;
  response: ScanResponse | null;

  constructor({
    paidBy = null,
    image = null,
    response = null,
  }: {
    paidBy?: Person | null;
    image?: UploadFile | null;
    response?: ScanResponse | null;
  }) {
    this.paidBy = paidBy;
    this.image = image;
    this.response = response;
  }
}

export class ScannerError {
  [key: string]: string;
}


export interface Restaurant {
	name: string;
	address: string;
	phone: string;
}

export interface OrderItem {
	name: string;
	translated_name: string;
	description: string;
	price: number;
	quantity: number;
	total: number;
}

export interface ScanResponse {
	restaurant: Restaurant;
	items: OrderItem[];
	subtotal: number;
	tax: number;
	total: number;
	date: string;
	currency?: any;
	estimated_diner_count: number;
}