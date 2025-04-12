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

export const MOCKED_CLIPBOARD_CONTENT_GENERAL = `YM\nYM - 312.50\nNN - 92.50\nZwe - 245.00\n---------------------------------------------\nNN\nYM - 312.50\nNN - 92.50\nZwe - 245.00\n---------------------------------------------\nZwe\nYM - 312.50\nNN - 92.50\nZwe - 245.00\n---------------------------------------------\nMTE\nYM - 312.50\nNN - 92.50\nZwe - 245.00\n---------------------------------------------`
export const UN_EVENLY_DIVIDED = `YM\nYM - 74.00\nCC - 75.00\n---------------------------------------------\nNN\nYM - 74.00\nMTE - 250.00\nZwe - 180.00\n---------------------------------------------\nZwe\nYM - 74.00\nMTE - 250.00\nZwe - 180.00\n---------------------------------------------\nMTE\nYM - 74.00\nMTE - 250.00\nZwe - 180.00\n---------------------------------------------\nCC\nYM - 74.00\nCC - 75.00\n---------------------------------------------`
export const TEST_DELETED_ITEMS = `YM\nYM - 258.00\nCC - 450.00\n---------------------------------------------\nNN\nYM - 258.00\n---------------------------------------------\nZwe\nYM - 258.00\n---------------------------------------------\nMTE\nYM - 258.00\n---------------------------------------------\nCC\nYM - 258.00\nCC - 450.00\n---------------------------------------------`
export const TEST_DELETED_AFTER_ITEM_DELETE=`YM\nYM - 258.00\n---------------------------------------------\nNN\nYM - 258.00\n---------------------------------------------\nZwe\nYM - 258.00\n---------------------------------------------\nMTE\nYM - 258.00\n---------------------------------------------\nCC\nYM - 258.00\n---------------------------------------------`
export const TEST_DELETED_A_FRIEND=`YM\nYM - 322.50\nCC - 450.00\n---------------------------------------------\nZwe\nYM - 322.50\n---------------------------------------------\nMTE\nYM - 322.50\n---------------------------------------------\nCC\nYM - 322.50\nCC - 450.00\n---------------------------------------------`


export const API_URL = process.env.SUPABASE_URL;

export const API_ENDPOINT = {
  'friends': API_URL + 'friend?columns=%22name%22%2C%22profile%22&select=*'
}


