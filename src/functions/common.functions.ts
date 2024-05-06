import { Item } from "@/models/item.models";
import { Person } from "@/models/person.models";
import { Result } from "@/models/results.models";
import { SplitDictionary } from "@/models/split.models";


export function calculateResults(
  items: Item[], 
  people: Person[], 
  splitDict:SplitDictionary): Result[] {

  const itemDict: { [key in string]: Item} = {};
  items.forEach((each, index) => itemDict[index.toString()] = each); 

  const personDict: { [key in string]: {
    person: Person,
    result: Result
  }} = {};
  people.forEach((each, index) => {
    personDict[index.toString()] = {
      person: each,
      result: new Result({
        person: each,
        total: 0,
        items: []
      })
    };
  });

  Object.keys(splitDict).forEach((itemIndex) => { // [ {'0': Split Obj, '1': Split Obj} ] -> [0, 1]
    const split = splitDict[itemIndex]; // Split Obj
    const peopleIndexes = Array.from(split.sharingPersonIndex); // [0, 1]
    peopleIndexes.forEach((personIndex) => {
      const person = personDict[personIndex.toString()]; // { person: Person, result: Result }
      const item = itemDict[itemIndex]; // Get Item Object
      item.sharedNumber = peopleIndexes.length;
      person.result.items.push(item); // Add Item to Person's Result
      person.result.total += item.price / peopleIndexes.length; // Add Price to Person's Total
    });
  });

  return Object.keys(personDict).map((key) => personDict[key].result);
}


export function someStepsAreEmpty(splitDict: SplitDictionary): boolean {
  return Object.keys(splitDict).some((key) => {
    return splitDict[key].sharingPersonIndex.size === 0;
  });
}