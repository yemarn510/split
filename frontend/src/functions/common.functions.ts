import { Item } from "@/models/item.models";
import { Person } from "@/models/person.models";
import { Result } from "@/models/results.models";
import { SplitDictionary } from "@/models/split.models";
import { createClient } from "@/utils/supabase/client";

const supabase = createClient();


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
      item.sharedNumber = peopleUUIDs.length;
      person.result.items.push(item); // Add Item to Person's Result
      person.result.total += item.price / peopleUUIDs.length; // Add Price to Person's Total
    });
  });

  return Object.keys(personDict).map((key) => personDict[key].result);
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