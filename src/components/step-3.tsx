'use client';

import Image from 'next/image';
import { Person, generateRandomInteger } from '@/models/person.models';
import { Carousel, Avatar } from 'antd';
import { Item } from '@/models/item.models';
import { LeftOutlined, RightOutlined } from '@ant-design/icons';
import { useRef } from 'react';
import type { CarouselRef } from 'antd/es/carousel';

export interface StepThreeParams {
  items: Item[];
  people: Person[];
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
  './svgs/reshot-icon-hot-food-DUYKGBF2XM.svg',
  './svgs/reshot-icon-pizza-B9CZFQ6G7J.svg',
];


export default function StepThree(params: { params: StepThreeParams }): JSX.Element {

  const slider = useRef<CarouselRef>(null);

  function onChange(currentSlide: number) {
    console.warn(currentSlide);
  }

  return <>
    <div className='flex flex-row gap-3 w-full'>
      <div className="w-1/5 flex items-center justify-center">
        <LeftOutlined className='text-xl text-main bg-third rounded-full p-4 cursor-pointer hover:opacity-50'
                       onClick={() => slider?.current?.prev() } />
      </div>
      <div className="w-3/5">
        <Carousel afterChange={onChange}
          ref={slider}>
          {
            params.params.items.map((each, index) => {
              return <div key={`food-image-${index}`}>
                <div className='m-auto bg-third rounded-md w-fit p-4 mb-5'>
                  <Image src={FOOD_IMAGES[generateRandomInteger(0, 13)]}
                    width={100}
                    height={100}
                    className='m-auto'
                    alt='Food Images' />
                </div>
                <h4 className='text-center mb-10'>
                  { each.name } / { each.price }
                </h4>
              </div>
            })
          }
        </Carousel>
      </div>
      <div className="w-1/5 flex items-center justify-center">
        <RightOutlined className='text-xl text-main bg-third rounded-full p-4 cursor-pointer hover:opacity-50'
                       onClick={() => slider?.current?.next() } />
      </div>
    </div>

    <div className="flex flex-row flex-wrap gap-5 mt-5 max-h-[260px] overflow-auto max-w-[600px] m-auto justify-center">
      {
        params.params.people.map((each, personIndex) => {
          return <div key={`person-${personIndex}`} 
                      onClick={() => {}}
                      className="flex flex-col items-center justify-center gap-3">
            <div className="bg-third rounded-full w-20 h-20 flex items-center justify-center">
              <Avatar src={each.profile} className='w-12 h-12 ' />
            </div>
            <p className="text-center">{ each.name || '-' }</p>
          </div>
        })
      }
    </div>
    
  </>
}