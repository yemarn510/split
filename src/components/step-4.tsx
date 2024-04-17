
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


  useEffect(() => {
    const itemsAndPerson: { [key: string]: CollapseProps['items']} = {};
    params.params.results.forEach((each, resultIndex) => {
      const items: CollapseProps['items'] = [];
      itemsAndPerson[resultIndex] = items;

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
            <h6 className="text-sm font-bold text-fourth">
              Total: 
              <b className='text-main pl-2'>
                {each.total.toFixed(2)}
              </b>
            </h6>
          </div>
        </div>,
        children: <ul className='w-full m-auto'>
          {
            each.items.map((eachItem, itemIndex) => {
              return <li key={`result-item-${itemIndex}`}
                        className="flex flex-row justify-between">
                <p>{ eachItem.name }</p>
                <p>{ eachItem.price } / { eachItem.sharedNumber } </p>
              </li>
            })
          }
        </ul>,
      }
      items.push(itemData);
      itemsAndPerson[resultIndex] = items;
    });

    setItemAndPersonDict(itemsAndPerson);
  }, []);

  return <>
    <div className='step-four-h max-w-[500px] m-auto'>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 m-auto">
        {
          params.params.results.map((each, index) => {
            return <div className="flex flex-col border border-fourth rounded-lg"
                        key={`result-${index}`}>
              <div className='w-full h-auto'>
                <Collapse
                  bordered={false}
                  expandIconPosition='end'
                  defaultActiveKey={['1']}
                  expandIcon={({ isActive }) => <CaretRightOutlined rotate={isActive ? 90 : 0} />}
                  items={itemsAndPerson[index]} />
                </div>
            </div>
          })
        }
      </div>
    </div>
  </>;
}