

export const AVATAR_URL = 'https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=';


export class Person {
  id: number | null;
  name: string;
  profile: string;

  constructor({
    id = null as number | null,
    name = '' as string,
    profile = '' as string,
  }) {
    this.id = id;
    this.name = name;
    this.profile = profile || `${AVATAR_URL}${generateRandomInteger(1, 400)}`;
  };
}

export function generateRandomInteger(min: number, max: number): number {
  const rand = min - 0.5 + Math.random() * (max - min + 1);
  return Math.round(rand);
}