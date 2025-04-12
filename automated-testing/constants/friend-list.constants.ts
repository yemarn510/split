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

export const MOCKED_CLIPBOARD_CONTENT_GENERAL = `YM has to pay
NN - 92.50
Zwe - 245.00
-------------------------
NN has to pay
YM - 312.50
Zwe - 245.00
-------------------------
Zwe has to pay
YM - 312.50
NN - 92.50
-------------------------
MTE has to pay
YM - 312.50
NN - 92.50
Zwe - 245.00
-------------------------`

export const UN_EVENLY_DIVIDED = `YM has to pay
CC - 75.00
-------------------------
NN has to pay
YM - 74.00
MTE - 250.00
Zwe - 180.00
-------------------------
Zwe has to pay
YM - 74.00
MTE - 250.00
-------------------------
MTE has to pay
YM - 74.00
Zwe - 180.00
-------------------------
CC has to pay
YM - 74.00
-------------------------`

export const TEST_DELETED_ITEMS = `YM has to pay
CC - 450.00
-------------------------
NN has to pay
YM - 258.00
-------------------------
Zwe has to pay
YM - 258.00
-------------------------
MTE has to pay
YM - 258.00
-------------------------
CC has to pay
YM - 258.00
-------------------------`

export const TEST_DELETED_AFTER_ITEM_DELETE=`YM has to pay

-------------------------
NN has to pay
YM - 258.00
-------------------------
Zwe has to pay
YM - 258.00
-------------------------
MTE has to pay
YM - 258.00
-------------------------
CC has to pay
YM - 258.00
-------------------------`
export const TEST_DELETED_A_FRIEND=`YM has to pay
CC - 450.00
-------------------------
Zwe has to pay
YM - 322.50
-------------------------
MTE has to pay
YM - 322.50
-------------------------
CC has to pay
YM - 322.50
-------------------------`


export const API_URL = process.env.SUPABASE_URL;

export const API_ENDPOINT = {
  'friends': API_URL + 'friend?columns=%22name%22%2C%22profile%22&select=*'
}


