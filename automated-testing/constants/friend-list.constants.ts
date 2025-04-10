export const friendPayload = [
  {
      "name": "YM",
      "profile": "https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=311"
  },
  {
      "name": "NN",
      "profile": "https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=257"
  },
  {
      "name": "Zwe",
      "profile": "https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=41"
  },
  {
      "name": "MTE",
      "profile": "https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=57"
  },
  {
      "name": "CC",
      "profile": "https://api.dicebear.com/7.x/miniavs/svg?size=200&hair=classic01,curly,long,ponyTail&seed=123"
  }
];

export const API_URL = process.env.SUPABASE_URL;

export const API_ENDPOINT = {
  'friends': API_URL + 'friend?columns=%22name%22%2C%22profile%22&select=*'
}
