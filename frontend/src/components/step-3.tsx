'use client';

import Image from 'next/image';
import { Avatar, Modal, Button } from 'antd';
import { useEffect, useState } from 'react';
import { UserAddOutlined, CheckOutlined, UsergroupAddOutlined } from '@ant-design/icons';

import { Item } from '@/models/item.models';
import { Person, generateRandomInteger } from '@/models/person.models';
import { Split, SplitDictionary } from '@/models/split.models';
import RoundedAvatar from './custom-avatar';
import UnknownPerson from './unknown-person';

export interface StepThreeParams {
  items: Item[];
  people: Person[];
  splitDict: SplitDictionary;
  setSplitDict: Function;
  setItems: Function;
}

type PersonDict = { [key: string]: Person };

const FOOD_IMAGES: string[] = [
  './svgs/reshot-icon-canned-fish-food-UHEQNSRM5T.svg',
  './svgs/reshot-icon-chinese-food-TWD823CXPR.svg',
  './svgs/reshot-icon-coffee-cup-TAV8UMWY7P.svg',
  './svgs/reshot-icon-donut-5SQ3GDBYH4.svg',
  './svgs/reshot-icon-fast-food-LQAPTFMSYJ.svg',
  './svgs/reshot-icon-fish-food-DLVAPR347Z.svg',
  './svgs/reshot-icon-food-32ZVXF59MT.svg',
  './svgs/reshot-icon-food-bowl-with-lid-U9YN7LZAW3.svg',
  './svgs/reshot-icon-food-drink-B4CS9RFA8L.svg',
  './svgs/reshot-icon-food-JY2ZKM765U.svg',
  './svgs/reshot-icon-fried-chicken-XAK6QZ3HBV.svg',
  './svgs/reshot-icon-hot-food-DUYKGBF2XM.svg',
  './svgs/reshot-icon-loaded-fries-6AF2QRM5VT.svg',
  './svgs/reshot-icon-pizza-B9CZFQ6G7J.svg',
  './svgs/reshot-icon-steak-dish-E6HGXNSQVY.svg',
  './svgs/reshot-icon-burger-9KYM62VBX8.svg',
  './svgs/reshot-icon-healthy-salad-2N7PDVZ6FU.svg',
  './svgs/reshot-icon-noodle-K73RD5GY8V.svg',
  './svgs/reshot-icon-salad-Q9GZYMD34B.svg',
  './svgs/reshot-icon-soda-WPRA7HT5E6.svg',
  './svgs/reshot-icon-soup-4HS8NVM7ZB.svg'
];


export default function StepThree(params: { params: StepThreeParams}): JSX.Element {

  const [changingItemIndex, setChangingItemIndex] = useState<number | null>(null);

  const [peopleDict, setPeopleDict] = useState<PersonDict>({});
  const [participantItemUUID, setParticipantItemUUID] = useState<string | null>(null);

  useEffect(() =>  {
    const items = params.params.items;
    const splitDictLocal = params.params.splitDict;
    const peopleUUIDs = new Set<string>(params.params.people.map((each) => each.uuid));

    for (let index = 0; index < items.length; index++) {
      const eachItem = items[index];
      eachItem.image = FOOD_IMAGES[generateRandomInteger(0, 20)];
      let splitDictPerItem = splitDictLocal[eachItem.uuid];
      if (splitDictPerItem) {
        splitDictPerItem.sharingPersonUUIDs = new Set<string>(Array.from(splitDictPerItem.sharingPersonUUIDs).filter((each) => peopleUUIDs.has(each)));
      } else { 
        splitDictPerItem = new Split({
          itemUUID: eachItem.uuid,
          itemPrice: eachItem.price,
          sharingPersonUUIDs: new Set<string>(),
        });
      }

      splitDictLocal[eachItem.uuid] = splitDictPerItem;
    }

    params.params.setSplitDict(splitDictLocal);
    params.params.setItems(items);
  }, []);

  useEffect( () => {
    const localPeopleDict: PersonDict = {};
    params.params.people.forEach((each) => {
      localPeopleDict[each.uuid] = each;
    });
    setPeopleDict(localPeopleDict);
  }, [params.params.people]);

  function assignPerson(uuid: string): void {
    if (participantItemUUID === null) {
      return;
    }
    const cloned = {...params.params.splitDict};
    const sharingPersonUUIDs = cloned[participantItemUUID]?.sharingPersonUUIDs || new Set<number>();
    sharingPersonUUIDs.has(uuid)
    ? sharingPersonUUIDs.delete(uuid)
    : sharingPersonUUIDs.add(uuid);
    cloned[participantItemUUID].sharingPersonUUIDs = sharingPersonUUIDs;
    params.params.setSplitDict(cloned);
  }

  function isSelected(uuid: string): boolean {
    if (participantItemUUID === null) {
      return false;
    }
    return params.params.splitDict[participantItemUUID!]?.sharingPersonUUIDs.has(uuid) || false;
  }

  function toggleModal(index: number | null): void {
    setChangingItemIndex(index);
  }

  function changeImage(index: number): void {
    const cloned = [...params.params.items];
    cloned[changingItemIndex!].image = FOOD_IMAGES[index];
    params.params.setItems(cloned);
    setChangingItemIndex(null);
  }

  function toggleSelectAll(uuid: string | null): void {
    if (uuid === null) {
      return;
    }
    const finalResult = new Set<string>();
    const cloned = {...params.params.splitDict};
    const sharingPersonUUIDs = params.params.splitDict[uuid]?.sharingPersonUUIDs || new Set<string>();
    cloned[uuid].sharingPersonUUIDs = sharingPersonUUIDs.size === params.params.people.length
      ? finalResult
      : new Set<string>(params.params.people.map((each) => each.uuid));
    params.params.setSplitDict(cloned);
  }

  function isAllSelected(uuid: string| null): boolean {
    if (uuid === null) {
      return false;
    }
    return params.params.splitDict[uuid]?.sharingPersonUUIDs.size === params.params.people.length;
  }

  return <>
    <div className='w-full'>
      <div className='step-3-h'>
        {
          params.params.items?.map((each, itemIndex) => {
            return <div className='w-full flex flex-col md:flex-row gap-5 items-center border-b border-main mx-0 md:px-2 py-3 mt-2'
                        key={`food-image-${itemIndex}`}>
             <div className='w-full md:w-1/3 flex flex-col'>
              <div className='cursor-pointer hover:opacity-50'
                  onClick={() => toggleModal(itemIndex) }>
                <div className='w-fit h-fit m-auto relative'>
                  <ItemImage image={each.image} />

                  <div className='absolute -top-4 -left-8 z-10 flex flex-col justify-center p-1 rounded-lg'>
                    <small className='text-center text-xs'>Paid By</small>
                    <RoundedAvatar person={each.paidBy!} size="small" bg={'bg-main'} />
                  </div>
                </div>
              </div>

              <h4 className='text-center'>
                { each.name } / { each.price }
              </h4>
             </div>
             <div className="w-full md:w-2/3 flex flex-col gap-3 items-center justify-center">
              {
                params.params.splitDict[each.uuid]?.sharingPersonUUIDs.size > 0 
                ?
                  <div className='w-full flex flex-row justify-center cursor-pointer gap-1 md:hover:opacity-50'
                      onClick={() => setParticipantItemUUID(each.uuid)}>
                    <ShowSomeSharedPeople personDict={peopleDict}
                                          sharingParticipant={params.params.splitDict[each.uuid]?.sharingPersonUUIDs} />
                  </div>
                : <div className='mb-[10px]'
                       onClick={() => setParticipantItemUUID(each.uuid)}>
                  <UnknownPerson size='lg' />
                </div>
              }
              
              <div className='flex flex-row gap-1 md:gap-3 w-full mb-3 md:mb-0'>
                <Button icon={<UserAddOutlined />}
                        type='primary'
                        onClick={() => setParticipantItemUUID(each.uuid)}
                        className='w-1/2 cursor-pointer px-1'>
                  Select Participants
                </Button>

                <Button icon={<UsergroupAddOutlined />}
                        type='default'
                        onClick={() => toggleSelectAll(each.uuid)}
                        className='w-1/2 bg-second border border-main cursor-pointer '>
                  { isAllSelected(each.uuid) ? 'Deselect All' : 'Select All' }
                </Button>
              </div>
             </div>
            </div>
          })
        }
      </div>  
    </div>


    <Modal title="Change Icon"
             footer={null}
             centered
             onCancel={ () => toggleModal(null) }
             open={changingItemIndex !== null} >
      <div className='grid grid-cols-3 md:grid-cols-4 gap-4 h-[320px] overflow-auto p-5'>
        {
          FOOD_IMAGES.map((eachImage, index) => {
            return <div key={`food-image-${index}`}
                        onClick={ () => changeImage(index) }
                        className='cursor-pointer hover:opacity-50'>
              <ItemImage image={eachImage} />
            </div> 
          })
        }
      </div>
    </Modal>

    <Modal title="Choose Participants"
             footer={null}
             centered
             closable={false}
             onCancel={ () => setParticipantItemUUID(null) }
             open={participantItemUUID !== null} >
      <div className='mt-3'>
        <div className='w-full text-center'>
          <Button type="default"
                  className={`${isAllSelected(participantItemUUID) ? 'bg-main text-white' : ''} min-w-40 `}
                  onClick={() => toggleSelectAll(participantItemUUID)}>
            { isAllSelected(participantItemUUID)  ? 'Deselect All' : 'Select All' }
          </Button>
        </div>
        <div className='h-[320px] overflow-auto p-5 my-2'>
          <div className='grid grid-cols-3 md:grid-cols-4 gap-2 md:gap-4'>
            {
              params.params.people.map((each, personIndex) => {
                return <div key={`person-${personIndex}`} 
                            onClick={() => assignPerson(each.uuid)}
                            className="flex flex-col items-center justify-center gap-1 md:gap-3 cursor-pointer">
                  <div className='relative w-fit h-fit'>
                    <div className={`absolute right-0 top-0 w-[25px] h-[25px] flex justify-center items-center 
                                      md:transition-opacity md:duration-200 bg-main border-2 border-white rounded-full
                                      ${isSelected(each.uuid) ? 'opacity-100': 'opacity-0'}`}>
                      <CheckOutlined className='text-white' />
                    </div>
                    <div className={`rounded-full p-4 w-fit flex items-center justify-center md:transition-colors 
                                     md:duration-200 ${isSelected(each.uuid) ? 'bg-fourth' : 'bg-third '}`}>
                      <Avatar src={each.profile} className='w-12 h-12 ' />
                    </div>
                    <p className="text-center">{ each.name || '-' }</p>
                  </div>
                </div>
              })
            }
          </div>
        </div>

        <div className='w-full text-right'>
          <Button type="default"
                  onClick={() => setParticipantItemUUID(null)}>
            Close
          </Button>
        </div>
      </div>
    </Modal>
  </>
}

export function ItemImage(params: { image: string }): JSX.Element {
  return <div className='m-auto bg-third rounded-md w-fit p-3 mb-1'>
    {
      params.image &&
      <Image src={params.image}
             width={80}
             height={80}
             priority
             className='m-auto'
             alt='Food Images' />
    }
  </div>
}

export function ShowSomeSharedPeople(props: { personDict: PersonDict, sharingParticipant: Set<string> }): JSX.Element {

  const [noOfParticipants, setNoOfParticipants] = useState<number>(3);

  useEffect(() => {
    window?.addEventListener('resize', () => {
      setNoOfParticipants(window.innerWidth < 500 ? 2 : 3)
    });

    return () => {
      window?.removeEventListener('resize', () => {
        setNoOfParticipants(window.innerWidth < 500 ? 2 : 3)
      });
    }
  }, []);  

  return <>
    {
      props.sharingParticipant?.size > 0 &&
      Array.from(props.sharingParticipant).slice(0, noOfParticipants).map((each, index) => {
        return <div className='flex flex-col'
                    key={`shared-person-${index}`}>
          <div className={`rounded-full bg-third w-fit h-auto p-2 mx-auto flex items-center justify-center`}>
            <Avatar src={props.personDict[each]?.profile} className='w-8 h-8 md:w-12 md:h-12 ' />
          </div>
          <h5 className='text-center'>{ props.personDict[each]?.name || '-' }</h5>
        </div>
      })
    }
    {
      props.sharingParticipant?.size > noOfParticipants
      ? <div className='rounded-full bg-fourth w-12 h-12 md:w-16 md:h-16 mx-1 flex items-center justify-center'>
        <h5 className='text-white'>+{props.sharingParticipant.size - noOfParticipants}</h5>
      </div>
      : null
    }
  </>
}