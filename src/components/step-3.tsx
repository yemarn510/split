'use client';

import Image from 'next/image';
import { Avatar, Modal, Button } from 'antd';
import { useEffect, useState } from 'react';
import { UserAddOutlined, CheckOutlined } from '@ant-design/icons';

import { Item } from '@/models/item.models';
import { Person, generateRandomInteger } from '@/models/person.models';
import { Split, SplitDictionary } from '@/models/split.models';
import { split } from 'postcss/lib/list';
import RoundedAvatar from './custom-avatar';

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
  const [participantItemIndex, setParticipantItemIndex] = useState<number | null>(null);

  useEffect(() =>  {
    const items = params.params.items;
    const splitDictLocal = params.params.splitDict;

    for (let index = 0; index < items.length; index++) {
      const eachItem = items[index];
      eachItem.image = FOOD_IMAGES[generateRandomInteger(0, 20)];
      splitDictLocal[index] = splitDictLocal[index] || new Split({
        itemIndex: index,
        itemPrice: eachItem.price,
        sharingPersonIndex: new Set<number>(),
      });
    }

    params.params.setSplitDict(splitDictLocal);
    params.params.setItems(items);
  }, []);

  useEffect( () => {
    const localPeopleDict: { [key: string]: Person } = {};
    params.params.people.forEach((each, index) => {
      localPeopleDict[index] = each;
    });
    setPeopleDict(localPeopleDict);
  }, [params.params.people]);

  function assignPerson(index: number): void {
    if (participantItemIndex === null) {
      return;
    }
    const cloned = {...params.params.splitDict};
    const sharingPersonIndex = cloned[participantItemIndex]?.sharingPersonIndex || new Set<number>();
    sharingPersonIndex.has(index)
    ? sharingPersonIndex.delete(index)
    : sharingPersonIndex.add(index);
    cloned[participantItemIndex].sharingPersonIndex = sharingPersonIndex;
    params.params.setSplitDict(cloned);
  }

  function isSelected(personIndex: number): boolean {
    if (participantItemIndex === null) {
      return false;
    }
    return params.params.splitDict[participantItemIndex!]?.sharingPersonIndex.has(personIndex) || false;
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

  function toggleParticipants(index: number | null): void {
    setParticipantItemIndex(index);
  }

  function toggleSelectAll(): void {
    if (participantItemIndex === null) {
      return;
    }
    const finalResult = new Set<number>();
    const cloned = {...params.params.splitDict};
    const sharingPersonIndex = params.params.splitDict[participantItemIndex]?.sharingPersonIndex || new Set<number>();
    cloned[participantItemIndex].sharingPersonIndex = sharingPersonIndex.size === params.params.people.length
      ? finalResult
      : new Set<number>(params.params.people.map((_, index) => index));
    params.params.setSplitDict(cloned);
  }

  function isAllSelected(): boolean {
    if (participantItemIndex === null) {
      return false;
    }
    return params.params.splitDict[participantItemIndex]?.sharingPersonIndex.size === params.params.people.length;
  }

  return <>
    <div className='w-full'>
      <div className='step-3-h'>
        {
          params.params.items?.map((each, itemIndex) => {
            return <div className='w-full flex flex-col md:flex-row gap-5 items-center border-b border-main px-2 py-3 mt-2'
                        key={`food-image-${itemIndex}`}>
             <div className='w-full md:w-1/3 flex flex-col'>
              <div className='cursor-pointer hover:opacity-50'
                  onClick={() => toggleModal(itemIndex) }>
                <div className='w-fit h-fit m-auto relative'>
                  <ItemImage image={each.image} />

                  <div className='absolute -top-6 -right-8 z-10 flex flex-col justify-center p-1 rounded-lg'>
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
                params.params.splitDict[itemIndex]?.sharingPersonIndex.size > 0 &&
                <div className='w-full flex flex-row justify-center'>
                  <ShowSomeSharedPeople personDict={peopleDict}
                                        sharingParticipant={params.params.splitDict[itemIndex]?.sharingPersonIndex} />
                </div>
              }
              <Button icon={<UserAddOutlined />}
                        onClick={() => toggleParticipants(itemIndex)}
                        className='bg-second border border-main w-fit cursor-pointer mb-3 md:mb-0'>
                Select Participants
              </Button>
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
             onCancel={ () => setParticipantItemIndex(null) }
             open={participantItemIndex !== null} >
      <div className='mt-3'>
        <div className='w-full text-center'>
          <Button type="default"
                  className={`${isAllSelected() ? 'bg-main text-white' : ''} min-w-40 `}
                  onClick={() => toggleSelectAll()}>
            { isAllSelected()  ? 'Deselect All' : 'Select All' }
          </Button>
        </div>
        <div className='grid grid-cols-3 md:grid-cols-4 gap-2 md:gap-4 h-[320px] overflow-auto p-5'>
          {
            params.params.people.map((each, personIndex) => {
              return <div key={`person-${personIndex}`} 
                          onClick={() => assignPerson(personIndex)}
                          className="flex flex-col items-center justify-center gap-1 md:gap-3 cursor-pointer relative">
                <div className={`absolute right-2 top-2 w-[25px] h-[25px] flex justify-center items-center md:transition-opacity md:duration-200 bg-main border-2 border-white rounded-full ${isSelected(personIndex) ? 'opacity-100': 'opacity-0'}`}>
                  <CheckOutlined className='text-white' />
                </div>
                <div className={`rounded-full p-4 flex items-center justify-center md:transition-colors md:duration-200 ${isSelected(personIndex) ? 'bg-fourth' : 'bg-third '}`}>
                  <Avatar src={each.profile} className='w-12 h-12 ' />
                </div>
                <p className="text-center">{ each.name || '-' }</p>
              </div>
            })
          }
        </div>

        <div className='w-full text-right mt-2'>
          <Button type="default"
                  onClick={() => setParticipantItemIndex(null)}>
            Close
          </Button>
        </div>
      </div>
    </Modal>
  </>
}

export function ItemImage(params: { image: string }): JSX.Element {
  return <div className='m-auto bg-third rounded-md w-fit p-4 mb-1'>
    <Image src={params.image}
      width={80}
      height={80}
      priority
      className='m-auto'
      alt='Food Images' />
  </div>
}

export function ShowSomeSharedPeople(props: { personDict: PersonDict, sharingParticipant: Set<number> }): JSX.Element {

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
      props.sharingParticipant?.size > 0 && Array.from(props.sharingParticipant).slice(0, noOfParticipants).map((each, index) => {
        return <div className='flex flex-col'
                    key={`shared-person-${index}`}>
          <div className={`rounded-full bg-third w-auto h-auto p-2 mx-1 flex items-center justify-center`}>
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