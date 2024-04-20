'use client';

import { Item } from "@/models/item.models";
import { Input, Button, Popconfirm, Avatar, Modal, Tooltip, Upload, Popover, message } from 'antd';
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

const { Dragger } = Upload; 


export interface StepTwoParams {
  items: Item[];
  people: Person[];
  setItems: Function;
}

export default function StepTwo(params: { params: StepTwoParams }): JSX.Element {

  const [messageApi, contextHolder] = message.useMessage();
  const [openScanPopup, setOpenScanPopup] = useState<boolean>(false);
  const [originalItem, setOriginalItem] = useState<Item | null>(null);
  const [paidByIndex, setPaidByIndex] = useState<number | null>(null);
  const [scanner, setNewScanner] = useState<Scanner>(new Scanner({}));
  const [open, setOpen] = useState<boolean>(false);
  const [currentIndex, setCurrentIndex ] = useState<number | null>(null);

  useEffect(() => {
    if (params.params.items.length === 1) {
      setCurrentIndex(0);
    }
  }, []);

  useEffect(() => {
    scrollToId();
  }, [currentIndex]);

  function scrollToId(): void {
    const id = document.getElementById(`item-${currentIndex}`);
    if (id) {
      id.scrollIntoView();
    }
  }

  function addItem(): void {
    if (params.params.items.length && !checkValidOrNot(params.params.items.length - 1)) {
      return;
    }
    params.params.items.push(new Item({}));
    params.params.setItems([...params.params.items]);
    setCurrentIndex(params.params.items.length - 1);
  }

  function saveEdit(): void {
    if (!checkValidOrNot(currentIndex!)) {
      return;
    }
    params.params.setItems([...params.params.items]);
    setOriginalItem(null);
    setCurrentIndex(null);
  }

  function cancelEdit(index: number): void {
    const editingItem = params.params.items[index];
    if (editingItem.name === '' && editingItem.price === 0) {
      deleteItem(index);
      return;
    }
    params.params.items[index] = originalItem || new Item({});
    const allItems = structuredClone(params.params.items);
    params.params.setItems([]);
    setTimeout(() => {
      params.params.setItems(allItems.map(each => new Item({...each})));
      setOriginalItem(null);
      setCurrentIndex(null);
    }, 1);
  }

  function editItem(index: number): void {
    if (currentIndex && !checkValidOrNot(currentIndex!)) {
      return;
    }
    const cloned = structuredClone(params.params.items[index]);
    setOriginalItem(cloned);
    setCurrentIndex(index);
  }

  function deleteItem(index: number): void {
    params.params.items.splice(index, 1);
    params.params.setItems([...params.params.items]);
    currentIndex === index && setCurrentIndex(null);
  }

  function checkValidOrNot(index: number): boolean {
    const isValid = params.params.items[index].isValid();
    params.params.items[index].error = params.params.items[index].error || {};
    params.params.setItems([...params.params.items]);
    return isValid;
  }

  function togglePaidBy(index: number | null): void {
    setPaidByIndex(index);
  }

  function setPaidBy(personIndex: number): void {
    params.params.items[paidByIndex!].paidBy = params.params.people[personIndex];
    delete params.params.items[paidByIndex!].error.paidBy;
    params.params.setItems([...params.params.items]);
    setPaidByIndex(null);
  }

  function toggleScanItem(): void {
    setOpenScanPopup(!openScanPopup);
    setNewScanner(new Scanner({}));
  }

  const props: UploadProps = {
    name: 'image',
    multiple: false,
    maxCount: 1,
    className: 'w-full',
    listType: "picture",
    action: 'https://xw3pr7ak-7dqrsyftta-de.a.run.app/extract_data?output_language=English',
    onChange(info) {
      switch (info.file.status) {
        case 'uploading':
          message.loading('Uploading file...');
          break;
        case 'done':
          scanner.response =  info.file.response as ScanResponse;
          setNewScanner(scanner);
          break;
        case 'error':
          message.error(`${info.file.name} file upload failed.`);
          break;
      }
    },
  };

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

  return <>
    <div className="w-full step-one-h">
      { contextHolder }
      <table className="w-full">
        <thead>
          <tr>
            <th className="w-[20px]">No.</th>
            <th className="w-2/12">Paid By</th>
            <th className="w-5/12">Item Name</th>
            <th className="w-3/12">Price</th>
            <th className="w-1/12"></th>
          </tr>
        </thead>
        <tbody>
          {
            params.params?.items?.map((eachItem, itemIndex) => {
              return <tr key={`item-${itemIndex}`}>
                <td className="text-center">{ itemIndex + 1}</td>
                <td className="text-center">
                  <Tooltip title={eachItem.error.paidBy || '' }
                           open={!!eachItem.error.paidBy}
                           color={'#ff4d4f'}
                           zIndex={10} >
                    <PaidBy person={eachItem.paidBy}
                            toggle={() => togglePaidBy(itemIndex)} />
                  </Tooltip>
                </td>
                <td className="px-1 md:px-3">
                  <Tooltip title={eachItem.error.name || '' }
                           open={!!eachItem.error.name}
                           color={'#ff4d4f'}
                           zIndex={10} >
                    <Input id="item-name"
                        type="text"
                        disabled={ currentIndex !== itemIndex }
                        defaultValue={eachItem.name}
                        onChange={(e) => {
                          e.preventDefault();
                          eachItem.name = e.target.value;
                          params.params.items[itemIndex] = eachItem;
                          params.params.setItems(params.params.items);
                          delete eachItem.error.name;
                        }}
                        placeholder="KFC, McDonalds, etc."
                        className="w-full"
                    />
                  </Tooltip>
                </td>
                <td className="px-1 md:px-3">
                  <Tooltip title={eachItem.error.price || '' }
                           open={!!eachItem.error.price}
                           color={'#ff4d4f'}
                           zIndex={10} >
                    <Input id="item-price"
                            type="number"
                            inputMode="decimal"
                            disabled={ currentIndex !== itemIndex }
                            placeholder="0.00"
                            defaultValue={eachItem.price}
                            onChange={(e) => {
                              e.preventDefault();
                              eachItem.price = +e.target.value || 0;
                              params.params.items[itemIndex] = eachItem;
                              params.params.setItems(params.params.items);
                              delete eachItem.error.price;
                            }}
                            className="w-full"
                      />
                  </Tooltip>
                </td>
                <td>
                  {
                    currentIndex === itemIndex
                      ? 
                        <div className="flex flex-row justify-center items-end pb-1 gap-3 md:gap-5">
                          <CheckOutlined className="text-main text-xl" 
                                        onClick={() => saveEdit()}/>
                          <CloseOutlined className="text-danger text-xl"
                                        onClick={() => cancelEdit(itemIndex)}/>
                        </div>
                      : 
                        <div className="flex flex-row justify-center items-end pb-1 gap-3 md:gap-5">
                          <EditOutlined className="text-main text-xl"
                                        onClick={() => editItem(itemIndex)} />
                          <Popconfirm title="Delete the task"
                                      description="Are you sure to delete this item?"
                                      onConfirm={() => deleteItem(itemIndex)}
                                      onCancel={ () => {}}
                                      okText="Yes"
                                      cancelText="No">
                            <DeleteOutlined className="text-danger text-xl"/>
                          </Popconfirm>
                        </div>
                  }
                </td>
              </tr>
            })
          }
        </tbody>
      </table>

      <div className="flex flex-row w-full gap-1 sticky bottom-0  mt-3">
        <Button className="w-11/12 h-8 min-h-8 "
          type="primary"
          onClick={ () => addItem() }>
          Add Item
        </Button>
        <Button className="w-1/12 flex items-center cursor-pointer md:hover:opacity-50"
          type="primary"
          onClick={ () => toggleScanItem() }>
          <CameraOutlined className="text-lg" />
        </Button>
      </div>

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
                      key={personIndex}>
                  <div className='bg-third cursor-pointer p-1 w-fit h-fit rounded-full m-auto hover:opacity-50'
                                  onClick={() => setPaidBy(personIndex) }>
                        <Avatar src={person.profile} className='w-12 h-12 ' />
                      </div>
                  <h6 className="text-center">{person.name || '-'}</h6>
                </div>
              })
            }
          </div>
        </div>
      </Modal>

      <Modal title="Upload your receipt"
             footer={null}
             centered
             onCancel={ () => toggleScanItem() }
             open={ openScanPopup } >
        <div className="h-fit max-h-[350px] my-3 overflow-auto">
          <div className="flex flex-col">
            <Popover content={() => 
                      (PersonList({ 
                        profiles: params.params.people,
                        scanner: scanner,
                        setScanner: setNewScanner,
                        setOpen: setOpen,
                      }))
                    }
                    open={open}
                    title="Choose Who Paid">
              {
                scanner.paidBy?.profile
                ? <div className="flex flex-row gap-5 justify-center items-center"
                       onClick={ () => setOpen(!open)}>
                  <h5 className="w-auto">Paid By</h5>
                  <div className="w-auto">
                    <RoundedAvatar person={scanner.paidBy}/>
                  </div> 
                </div>
                : <Button className="w-full h-8 min-h-8"
                          onClick={ () => setOpen(!open)}>
                  Choose Paid By
                </Button>
              }
            </Popover>
            <hr className="w-full my-3" />
            <div className="w-auto h-auto">
              <Dragger {...props}>
                <p className="ant-upload-drag-icon">
                  <InboxOutlined />
                </p>
                <p className="ant-upload-text">Click or drag file to this area to upload</p>
                <p className="ant-upload-hint">
                  Support for a single or bulk upload. Strictly prohibited from uploading company data or other
                  banned files.
                </p>
              </Dragger>
            </div>
          </div>
        </div>
        
        <Button type="primary"
          className="w-full max-h-8"
          onClick={() => setScannedItems() }>
          Set
        </Button>
      </Modal>
    </div>
  </>
}



export function PaidBy(params: { person: Person | null, toggle: Function} ): JSX.Element {
  return <div className="w-full flex flex-col">
    <div className={`bg-third cursor-pointer p-1 w-fit h-fit rounded-full text-center m-auto hover:opacity-50 ${!params.person && '!w-10 !h-10 flex items-center justify-center'}`}
        id="paid-by"
        onClick={() => params.toggle() }>
      {
        params.person?.profile
        ? <Avatar src={params.person.profile} className='w-8 h-8 ' />
        : <QuestionCircleOutlined className='text-xl'/>
      }
    </div>
    <small>{ params.person?.name || '' }</small>
  </div>
}

export function PersonList(params: { profiles: Person[], scanner: Scanner, setScanner: Function, setOpen: Function}): JSX.Element {
  return <div className="w-[200px] h-16 flex flex-row gap-5 justify-between overflow-x-auto">
    {
      params.profiles.map((person, index) => {
        return <div key={`person-${index}`}
                    onClick={() => {
                        params.setScanner({
                          ...params.scanner,
                          paidBy: person,
                        });
                        params.setOpen(false);
                      }
                    }>
          <RoundedAvatar person={person} />
        </div>
      })
    }
  </div>
}

export function RoundedAvatar(params: { person: Person }): JSX.Element {
  return <div className="flex flex-col items-center gap-1 md:hover:opacity-50 cursor-pointer">
    <div className="p-1 w-fit h-fit bg-second rounded-full">
      <Avatar src={params.person.profile} className='w-8 h-8 ' />
    </div>
    <small className="text-center">{ params.person.name || '-' }</small>
  </div>

}