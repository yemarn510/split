import { Item } from "@/models/item.models";


export default function checkValidOrNot(index: number, items: Item[], setItems: Function): boolean {
  const isValid = items[index].isValid();
  items[index].error = items[index].error || {};
  setItems([...items]);
  return isValid;
}