import { Item } from "@/models/item.models";
import { Person } from "@/models/person.models";
import { Result } from "@/models/results.models";
import { SplitDictionary } from "@/models/split.models";
import { createClient } from "@/utils/supabase/client";

const supabase = createClient();


export function calculateResults(
  items: Item[], 
  people: Person[], 
  splitDict: SplitDictionary
): Result[] {

  const itemDict: { [key in string]: Item} = {};
  const personDict: { [key in string]: {
    person: Person,
    result: Result
  }} = {};

  items.forEach((each) => itemDict[each.uuid.toString()] = each);
  people.forEach((each) => {
    personDict[each.uuid] = {
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
    const peopleUUIDs = Array.from(split.sharingPersonUUIDs); // [0000-0000-0000-0000, 0000-0000-0000-1234]
    
    peopleUUIDs.forEach((personIndex) => {
      const person = personDict[personIndex.toString()]; // { person: Person, result: Result }
      const item = itemDict[itemIndex]; // Get Item Object

      if (item) {
        item.sharedNumber = peopleUUIDs.length || 0;
        person.result.items.push(item); // Add Item to Person's Result
        if (!item.isPercentage) {
          person.result.total += item.price / peopleUUIDs.length; // Add Price to Person's Total
        }
      }
    });
  });

  return Object.keys(personDict).map((key) => {
    const items = structuredClone(personDict[key].result.items);
    const serviceCharges = items.find(each => each.name.toLowerCase().includes('service'));
    const tax = items.find(each => each.name.toLowerCase().includes('tax') || each.name.toLowerCase().includes('vat') );
    const notPercentItems = items.filter(each => !each.isPercentage)
    const totalDict: { [personUUID in string]: number } = notPercentItems.reduce((acc, each) => {
      if (each.paidBy?.uuid) {
        acc[each.paidBy.uuid] = (acc[each.paidBy.uuid] || 0) + (each.price / (each.sharedNumber || 1));
      }
      return acc;
    }, {} as { [personUUID: string]: number });
    let finalTotal = structuredClone(personDict[key].result.total);
    let serviceChargesPrice = 0;
    let taxPrice = 0;

    if (serviceCharges) {
      const percentage = structuredClone(serviceCharges.percent);
      const paidByUUID = serviceCharges.paidBy?.uuid;
      const baseTotal = paidByUUID ? (totalDict[paidByUUID] || 0) : 0;
      serviceCharges.price = structuredClone(baseTotal * (percentage / 100));
      serviceChargesPrice = serviceCharges.price;
      finalTotal += serviceCharges.price;
    }

    if (tax) {
      const percentage = structuredClone(tax.percent);
      const paidByUUID = tax.paidBy?.uuid;
      const baseTotal = paidByUUID ? (totalDict[paidByUUID] || 0) : 0;
      tax.price = structuredClone((baseTotal + serviceChargesPrice) * (percentage / 100));
      taxPrice = tax.price;
      finalTotal += tax.price;
    }

    const finalItems = notPercentItems;
    if (serviceCharges) {
      finalItems.push(serviceCharges);
    }
    if (tax) {
      finalItems.push(tax);
    }

    personDict[key].result.items = finalItems;
    personDict[key].result.total = finalTotal;
    return personDict[key].result
  });
}


export function someStepsAreEmpty(splitDict: SplitDictionary): boolean {
  return Object.keys(splitDict).some((key) => {
    return splitDict[key].sharingPersonUUIDs.size === 0;
  });
}

export async function createOrUpdateFriends(people: Person[]): Promise<void> {

  const peopleToCreate: Partial<Person>[] = people.filter(each => !each.id).map(each => {
    return {
      name: each.name,
      profile: each.profile
    }
  });

  const peopleToUpdate: Person[] = people.filter( each => each.id);

  const { data, error } = await supabase.from('friend').select('*');

  if (error) {
    console.error(error);
    return;
  }

  const peopleToDelete: Set<number> = new Set<number>(data?.map(each => each.id));

  if (peopleToCreate.length) {
    const { error } = await supabase
      .from('friend')
      .insert(peopleToCreate)
      .select();
    
    if (error) {
      console.error(error);
      return;
    }
  }

  if (peopleToUpdate.length) {
    for (let eachFriend of peopleToUpdate) {
      const { error } = await supabase
        .from('friend')
        .update({ name: eachFriend.name, profile: eachFriend.profile })
        .eq('id', eachFriend.id)
        .select(); 
      if (error) {
        console.error(error);
        return;
      }
      peopleToDelete.delete(eachFriend.id as number);
    }
  }

  const peopleToDeleteIds: number[] = Array.from(peopleToDelete);

  if (peopleToDeleteIds.length) {  
    const { error } = await supabase
      .from('friend')
      .delete()
      .in('id', peopleToDeleteIds)
      .select();
    if (error) {
      console.error(error);
      return;
    }
  }
}