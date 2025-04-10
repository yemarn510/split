
import { Avatar, Collapse, Modal, Button } from 'antd';
import { CaretRightOutlined, FileDoneOutlined } from '@ant-design/icons';
import { Result } from "@/models/results.models";
import type { CollapseProps } from 'antd';
import { useEffect, useState } from 'react';
import { Item } from '@/models/item.models';

export interface PaidByAndItems {
  [ key: string ]: Item[];
}

export interface TotalToPayFor {
  [ key: string ]: number;
}

export interface StepFourParams {
  results: Result[];
  setResults: Function;
}

export default function StepFour(params: { params: StepFourParams }): JSX.Element {

  const [itemsAndPerson, setItemAndPersonDict] = useState<{ [key: string]: CollapseProps['items']}>({});
  const [ expandKeys, setExpandKeys ] = useState<{ [key: string]: string[]}>({});
  const [detailResults, setDetailResults] = useState<Result | null>(null);


  useEffect(() => {
    const itemsAndPerson: { [key: string]: CollapseProps['items']} = {};
    const expandKeys: { [key: string]: string[]} = {};

    params.params.results
    .filter(each => each.total > 0.00)
    .forEach((eachResult, resultIndex) => {
      const items: CollapseProps['items'] = [];
      itemsAndPerson[resultIndex] = items;
      expandKeys[resultIndex] = [];

      const paidByNItems: PaidByAndItems = {};
      const totalToPayFor: TotalToPayFor  = {};

      eachResult.items.forEach((eachItem: Item) => {
        if (!paidByNItems[eachItem.paidBy?.name || '']) {
          paidByNItems[eachItem.paidBy?.name || ''] = [];
        }
        paidByNItems[eachItem.paidBy?.name || ''].push(eachItem);
      });

      Object.keys(paidByNItems).forEach((name: string) => {
        let totalForPerson = 0;
        paidByNItems[name].forEach((eachItem: Item, acc: number) => {
          totalForPerson += eachItem.price / eachItem.sharedNumber;
        });
        totalToPayFor[name] = totalForPerson;
      });

      eachResult.paidByNItems = paidByNItems;
      eachResult.totalToPayFor = totalToPayFor;

      const itemData = {
        key: `result-${resultIndex}`,
        label: <div className="flex flex-row gap-4">
          <div className="w-1/5 flex justify-center">
            <div className={`rounded-full w-14 h-14 flex items-center justify-center transition-colors duration-200 bg-third`}>
              <Avatar src={eachResult.person.profile} className='w-12 h-12 ' />
            </div>
          </div>
          <div className="w-3/5 flex flex-col justify-center">
            <h5 className="text-main font-bold">{ eachResult.person.name || '-' }</h5>
          </div>
        </div>,
        children: <ul className='w-full m-auto'>
          {
            Object.keys(totalToPayFor).map((paidByName, personIndex) => {
              return <li key={`result-item-${personIndex}`}
                         onClick={() => toggleDetails(eachResult, paidByName) }
                         className="flex flex-row justify-between cursor-pointer mb-2 md:hover:text-blue-600">
                <div className='w-2/3 flex flex-row items-center'>
                  { paidByName }
                  <div className='w-[20px] h-[20px] leading-[20px] text-center bg-third text-xs rounded-full ml-2'>
                  { paidByNItems[paidByName].length }
                  </div>
                </div>
                <div className='w-1/3 text-right'>
                  <b className='font-bold pl-1'>{ (totalToPayFor[paidByName]).toFixed(2)}</b>
                </div>
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

  function toggleDetails(result: Result | null, paidByName: string): void {
    if (result === null) {
      setDetailResults(null);
      return;
    }
    const clonedResult = structuredClone(result);
    clonedResult.items = clonedResult.items.filter(each => each.paidBy?.name === paidByName);
    setDetailResults(clonedResult);
  }

  function saveHistory(): void {
    // // const data = {
    // //   results: params.params.results,
    // //   createdAt: new Date().toISOString(),
    // // };
    // // const history = localStorage.getItem('history') || '[]';
    // // const historyList = JSON.parse(history);
    // // historyList.push(data);
    // // localStorage.setItem('history', JSON.stringify(historyList));
    // console.warn(params.params.results);
  }

  return <>
    <div className='max-w-[500px] m-auto'>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 m-auto">
        {
          params.params.results.filter(each => each.total > 0.00).map((each, index) => {
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
      <div className='flex flex-row justify-end mt-3 sticky bottom-0 hidden'>
        <Button type='primary'
          onClick={() => saveHistory() }
          icon={<FileDoneOutlined />}>
          Save History
        </Button>
      </div>
    </div>

    <Modal title="Details"
             footer={null}
             centered
             width={400}
             onCancel={ () => toggleDetails(null, '') }
             open={ detailResults !== null} >
      <div className='max-h-[300px] overflow-auto bg-second rounded-lg p-3'>
        <ul>
          {
            detailResults?.items.map((eachItem, itemIndex) => {
              return <li key={`result-item-${itemIndex}`}
                         className='flex flex-row justify-between mb-1'>
                <div className='w-1/2'>
                  { eachItem.paidBy?.name } ( { eachItem.name } )
                </div>
                <div className='w-1/2 flex flex-row justify-end'>
                  <span>
                    { eachItem.price } / { eachItem.sharedNumber } -
                  </span>
                  <span className='min-w-[70px] text-right font-bold'>
                    { (eachItem.price/eachItem.sharedNumber).toFixed(2)}
                  </span>
                </div>
              </li>
            })
          }
        </ul>
      </div>
    </Modal>
  </>;
}