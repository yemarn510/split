

export const AVATAR_URL = 'https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=';


export class Person {
  id: number | null;
  name: string;
  uuid: string;
  profile: string;
  selected: boolean = false;

  constructor({
    id = null as number | null,
    name = '' as string,
    profile = '' as string,
    selected = false as boolean,
  }) {
    this.id = id;
    this.uuid = this.randomUUID();
    this.name = name;
    this.profile = profile || `${AVATAR_URL}${generateRandomInteger(1, 400)}`;
    this.selected = selected;
  };

  randomUUID(): string {
    return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
      (+c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> +c / 4).toString(16)
    );
  }
}

export function generateRandomInteger(min: number, max: number): number {
  const rand = min - 0.5 + Math.random() * (max - min + 1);
  return Math.round(rand);
}