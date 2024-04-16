'use client';

import Image from 'next/image';
import { Carousel, Avatar, Modal } from 'antd';
import { useEffect, useRef, useState } from 'react';
import type { CarouselRef } from 'antd/es/carousel';
import { LeftOutlined, RightOutlined, CheckOutlined } from '@ant-design/icons';

import { Item } from '@/models/item.models';
import { Person, generateRandomInteger } from '@/models/person.models';
import { Split, SplitDictionary } from '@/models/split.models';

export interface StepThreeParams {
  items: Item[];
  people: Person[];
  splitDict: SplitDictionary;
  setSplitDict: Function;
  setItems: Function;
}

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
];


export default function StepThree(params: { params: StepThreeParams }): JSX.Element {

  const slider = useRef<CarouselRef>(null);
  const [changingItemIndex, setChangingItemIndex] = useState<number | null>(null);
  const [currentIndex, setCurrentIndex] = useState<number>(0);

  useEffect(() =>  {
    const items = params.params.items;
    const splitDictLocal = params.params.splitDict;
    items.forEach((eachItem, index) => {
      eachItem.image = FOOD_IMAGES[generateRandomInteger(0, 13)];
      splitDictLocal[index] = new Split({
        itemIndex: index,
        itemPrice: eachItem.price,
        sharingPersonIndex: new Set<number>(),
      });
    });
    params.params.setSplitDict(splitDictLocal);
    params.params.setItems(items);
  }, []);

  function onChange(index: number) {
    setCurrentIndex(index);
  }

  function assignPerson(index: number): void {
    params.params.splitDict[currentIndex].sharingPersonIndex.has(index) 
      ? params.params.splitDict[currentIndex].sharingPersonIndex.delete(index)
      : params.params.splitDict[currentIndex].sharingPersonIndex.add(index);
    params.params.setSplitDict({ ...params.params.splitDict });
  }

  function isSelected(personIndex: number): boolean {
    return params.params.splitDict[currentIndex]?.sharingPersonIndex.has(personIndex);
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

  return <>
    <div className='flex flex-row gap-3 w-full'>
      <div className="w-1/5 flex items-center justify-center">
        <LeftOutlined className='text-xl text-main bg-second rounded-full p-4 cursor-pointer hover:opacity-50'
                       onClick={() => slider?.current?.prev() } />
      </div>
      <div className="w-3/5">
        <Carousel afterChange={onChange}
          ref={slider}>
          {
            params.params.items.map((each, itemIndex) => {
              return <div key={`food-image-${itemIndex}`}>
                <div className='cursor-pointer hover:opacity-50'
                      onClick={() => toggleModal(itemIndex) }>
                  <ItemImage image={each.image} />
                </div>
                <h6 className='text-center mx-auto text-grey text-xs'>
                  Item Name / Price
                </h6>
                <h4 className='text-center mb-10'>
                  { each.name } / { each.price }
                </h4>
              </div>
            })
          }
        </Carousel>
      </div>
      <div className="w-1/5 flex items-center justify-center">
        <RightOutlined className='text-xl text-main bg-second rounded-full p-4 cursor-pointer hover:opacity-50'
                       onClick={() => slider?.current?.next() } />
      </div>
    </div>

    <div className="flex flex-row flex-wrap gap-5 mt-5 max-h-[260px] overflow-auto max-w-[600px] m-auto justify-center">
      {
        params.params.people.map((each, personIndex) => {
          return <div key={`person-${personIndex}`} 
                      onClick={() => assignPerson(personIndex)}
                      className="flex flex-col items-center justify-center gap-3 hover:opacity-50 cursor-pointer relative">
            <div className={`absolute right-0 top-0 w-[25px] h-[25px] flex justify-center items-center transition-opacity duration-200 bg-main border-2 border-white rounded-full ${isSelected(personIndex) ? 'opacity-100': 'opacity-0'}`}>
              <CheckOutlined className='text-white' />
            </div>
            <div className={`rounded-full w-20 h-20 flex items-center justify-center transition-colors duration-200 ${isSelected(personIndex) ? 'bg-fourth' : 'bg-third '}`}>
              <Avatar src={each.profile} className='w-12 h-12 ' />
            </div>
            <p className="text-center">{ each.name || '-' }</p>
          </div>
        })
      }
    </div>


    <Modal title="Change Icon"
             footer={null}
             centered
             onCancel={ () => toggleModal(null) }
             open={changingItemIndex !== null} >
      <div className='grid grid-cols-4 gap-4 h-[320px] overflow-auto p-5'>
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
  </>
}

export function ItemImage(params: { image: string }): JSX.Element {
  return <div className='m-auto bg-second rounded-md w-fit p-4 mb-5'>
    <Image src={params.image}
      width={100}
      height={100}
      className='m-auto'
      alt='Food Images' />
  </div>
}