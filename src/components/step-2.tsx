'use client';

import { Item } from "@/models/item.models";
import { Button, Modal } from 'antd';
import {  
  CameraOutlined,
} from '@ant-design/icons';
import { useState } from "react";
import { Person } from "@/models/person.models";
import { Scanner } from "@/models/scanner.models";
import ScanReceipt, { ScanReceiptParams } from "./scan-receipt";
import ItemTable, { ItemTableParams } from "./item-table";
import RoundedAvatar from "./custom-avatar";
import checkValidOrNot from "@/common/service";



export interface StepTwoParams {
  items: Item[];
  people: Person[];
  setItems: Function;
}

export default function StepTwo(params: { params: StepTwoParams }): JSX.Element {

  
  const [openScanPopup, setOpenScanPopup] = useState<boolean>(false);
  const [paidByIndex, setPaidByIndex] = useState<number | null>(null);
  const [currentIndex, setCurrentIndex]= useState<number | null>(null);
  const [scanner, setScanner] = useState<Scanner>(new Scanner({}));

  function setPaidBy(personIndex: number): void {
    params.params.items[paidByIndex!].paidBy = params.params.people[personIndex];
    delete params.params.items[paidByIndex!].error.paidBy;
    params.params.setItems([...params.params.items]);
    setPaidByIndex(null);
  }

  function toggleScan(): void {
    setOpenScanPopup(!openScanPopup);
    setScanner(new Scanner({}));
  }

  function setScannedItems(): void {
    const scannedItems = scanner.response?.items || [];
    const cloned = [...params.params.items];
    scannedItems.forEach(each => {
      cloned.push(new Item({
        name: each.translated_name,
        price: each.price,
        paidBy: scanner.paidBy,
      }));
    });
    params.params.setItems(cloned);
    setOpenScanPopup(false);
  }

  function addItem(): void {
    if (params.params.items.length && !checkValidOrNot(params.params.items.length - 1, params.params.items, params.params.setItems)) {
      return;
    }
    params.params.items.push(new Item({}));
    params.params.setItems([...params.params.items]);
    setCurrentIndex(params.params.items.length - 1);
  }

  function mergeItems(newItems: Item[]): void {
    const cloned = [...params.params.items.filter( each => each.name !== '' && each.price !== 0)];
    const finalItemList = cloned.concat(newItems);
    params.params.setItems(finalItemList);
    toggleScan();
  }

  const scanReceipt: ScanReceiptParams = {
    scanner,
    setScanner,
    openScanPopup,
    toggleScan,
    mergeItems,
    people: params.params.people,
  };

  const itemTable: ItemTableParams = {
    items: params.params.items,
    setItems: params.params.setItems,
    currentIndex,
    setCurrentIndex,
    setPaidByIndex,
  };

  return <>
    <div className="w-full step-one-h">
      
      <ItemTable {...itemTable} />

      <div className="flex flex-row w-full gap-1 sticky bottom-0  mt-3">
        <Button className="w-11/12 h-8 min-h-8 "
          type="primary"
          onClick={ () => addItem() }>
          Add Item
        </Button>
        <Button className="w-1/12 flex items-center cursor-pointer md:hover:opacity-50"
          type="primary"
          onClick={ () => toggleScan() }>
          <CameraOutlined className="text-lg" />
        </Button>
      </div>

      <ScanReceipt {...scanReceipt} />

      <Modal title="Set Paid By"
             footer={null}
             centered
             onCancel={ () => setPaidByIndex(null) }
             open={ paidByIndex !== null} >
        <div className=" h-[320px] overflow-auto">
          <div className='grid grid-cols-3 self-start md:grid-cols-4 gap-4 p-5'>
            {
              params.params.people.map((person, personIndex) => {
                return <div className="flex flex-col"
                      onClick={() => setPaidBy(personIndex) }
                      key={personIndex}>
                  <RoundedAvatar person={person} />
                </div>
              })
            }
          </div>
        </div>
      </Modal>

    </div>
  </>
}


