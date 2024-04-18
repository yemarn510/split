
import { Avatar, Collapse } from 'antd';
import { CaretRightOutlined } from '@ant-design/icons';
import { Result } from "@/models/results.models";
import type { CollapseProps } from 'antd';
import { useEffect, useState } from 'react';

export interface StepFourParams {
  results: Result[];
}

export default function StepFour(params: { params: StepFourParams }): JSX.Element {

  const [itemsAndPerson, setItemAndPersonDict] = useState<{ [key: string]: CollapseProps['items']}>({});
  const [ expandKeys, setExpandKeys ] = useState<{ [key: string]: string[]}>({});


  useEffect(() => {
    const itemsAndPerson: { [key: string]: CollapseProps['items']} = {};
    const expandKeys: { [key: string]: string[]} = {};
    params.params.results.forEach((each, resultIndex) => {
      const items: CollapseProps['items'] = [];
      itemsAndPerson[resultIndex] = items;
      expandKeys[resultIndex] = [];

      const itemData = {
        key: `result-${resultIndex}`,
        label: <div className="flex flex-row gap-4">
          <div className="w-1/5 flex justify-center">
            <div className={`rounded-full w-14 h-14 flex items-center justify-center transition-colors duration-200 bg-third`}>
              <Avatar src={each.person.profile} className='w-12 h-12 ' />
            </div>
          </div>
          <div className="w-3/5 flex flex-col justify-center">
            <h5 className="text-main font-bold">{ each.person.name || '-' }</h5>
          </div>
        </div>,
        children: <ul className='w-full m-auto'>
          {
            each.items.map((eachItem, itemIndex) => {
              return <li key={`result-item-${itemIndex}`}
                        className="flex flex-row justify-between">
                <p>{ eachItem.paidBy?.name }</p>
                <p>
                  { eachItem.price } / { eachItem.sharedNumber } = 
                  <b className='font-bold pl-1'>{ (eachItem.price/eachItem.sharedNumber).toFixed(2)}</b>
                </p>
              </li>
            })
          }
        </ul>,
      }
      expandKeys[resultIndex].push(itemData.key);
      items.push(itemData);
      itemsAndPerson[resultIndex] = items;
    });
    setExpandKeys(expandKeys);

    setItemAndPersonDict(itemsAndPerson);
  }, []);

  return <>
    <div className='max-w-[500px] m-auto'>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 m-auto">
        {
          params.params.results.map((each, index) => {
            return <div className="flex flex-col justify-between border border-fourth rounded-lg"
                        key={`result-${index}`}>
              <div className='w-full h-auto'>
                <Collapse
                  expandIconPosition='end'
                  onChange={(keys) => {
                    expandKeys[index] = keys as string[];
                    setExpandKeys({...expandKeys});
                  }}
                  activeKey={  expandKeys[index] || [] }
                  expandIcon={({ isActive }) => <CaretRightOutlined rotate={isActive ? 90 : 0} />}
                  items={itemsAndPerson[index]} />
                </div>
                <div className='flex flex-row justify-between px-4 pb-2'>
                  <span className=''>Total</span>
                  <span className='font-bold'>{ each.total.toFixed(2) }</span>
                </div>
            </div>
          })
        }
      </div>
    </div>
  </>;
}