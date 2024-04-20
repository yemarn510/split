'use client';

import { Item } from "@/models/item.models";
import { Input, Button, Popconfirm, Avatar, Modal, Tooltip, Upload, message } from 'antd';
import { 
  CheckOutlined, 
  CloseOutlined, 
  EditOutlined, 
  DeleteOutlined, 
  CameraOutlined, 
  InboxOutlined,
  QuestionCircleOutlined
} from '@ant-design/icons';
import { useEffect, useState } from "react";
import { Person } from "@/models/person.models";
import type { UploadProps } from 'antd';
import { ScanResponse, Scanner } from "@/models/scanner.models";
import ScanReceipt, { ScanReceiptParams } from "./scan-receipt";
import ItemTable, { ItemTableParams } from "./item-table";



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



  function togglePaidBy(index: number | null): void {
    setPaidByIndex(index);
  }

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
    if (params.params.items.length && !checkValidOrNot(params.params.items.length - 1)) {
      return;
    }
    params.params.items.push(new Item({}));
    params.params.setItems([...params.params.items]);
    setCurrentIndex(params.params.items.length - 1);
  }

  function checkValidOrNot(index: number): boolean {
    const isValid = params.params.items[index].isValid();
    params.params.items[index].error = params.params.items[index].error || {};
    params.params.setItems([...params.params.items]);
    return isValid;
  }

  const scanReceipt: ScanReceiptParams = {
    scanner,
    setScanner,
    openScanPopup,
    toggleScan,
    people: params.params.people,
  };

  const itemTable: ItemTableParams = {
    items: params.params.items,
    setItems: params.params.setItems,
    currentIndex,
    setCurrentIndex,
    checkValidOrNot,
    togglePaidBy,
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
             onCancel={ () => togglePaidBy(null) }
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


export function PaidBy(params: { person: Person | null, toggle: Function} ): JSX.Element {
  return <div className="w-full flex flex-col"
    onClick={() => params.toggle() }>
    {
      params.person?.profile
      ? <RoundedAvatar person={params.person}/>
      : <UnknownPerson />
    }
  </div>
}

export function RoundedAvatar(params: { person: Person }): JSX.Element {
  return <div className="flex flex-col items-center gap-1 md:hover:opacity-50 cursor-pointer">
    <div className="p-1 w-fit h-fit bg-third rounded-full">
      <Avatar src={params.person.profile} className='w-8 h-8 ' />
    </div>
    <small className="text-center">{ params.person.name || '-' }</small>
  </div>
}

export function UnknownPerson(): JSX.Element {
  return <div className="w-full flex flex-col">
    <div className={`bg-third cursor-pointer p-1 rounded-full text-center m-auto hover:opacity-50 w-10 h-10 flex items-center justify-center`}>
      <QuestionCircleOutlined className='text-xl'/>
    </div>
  </div>
}