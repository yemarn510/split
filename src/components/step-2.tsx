'use client';

import { Item } from "@/models/item.models";
import { Input, Button, Popconfirm, Avatar, Modal, Tooltip, Upload, Popover } from 'antd';
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

const { Dragger } = Upload; 


export interface StepTwoParams {
  items: Item[];
  people: Person[];
  setItems: Function;
}

export default function StepTwo(params: { params: StepTwoParams }): JSX.Element {

  const [file, setFile] = useState<File | null>(null);
  const [openScanPopup, setOpenScanPopup] = useState<boolean>(false);
  const [originalItem, setOriginalItem] = useState<Item | null>(null);
  const [paidByIndex, setPaidByIndex] = useState<number | null>(null);
  const [currentIndex, setCurrentIndex ] = useState<number | null>(null);
  const [open, setOpen] = useState(false);

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
    setFile(null);
  }

  function handleFileUpload(e: React.ChangeEvent<HTMLInputElement>): void {
    if (e.target.files && e.target.files.length) {
      setFile(e.target.files[0]);
    }
  }

  const personList = (
    <PersonList profiles={params.params.people} />
  )

  const props: UploadProps = {
    name: 'file',
    listType: "picture-card",
    action: 'https://xw3pr7ak-7dqrsyftta-de.a.run.app/extract_data?output_language=English',
    onChange(info) {
      if (info.file.status !== 'uploading') {
        console.log(info.file, info.fileList);
      }
      if (info.file.status === 'done') {
        console.warn(info.file.response);
        console.warn('File uploaded successfully');
        // message.success(`${info.file.name} file uploaded successfully`);
      } else if (info.file.status === 'error') {
        console.warn(info.file.response);
        console.warn('File uploaded successfully');
        // message.error(`${info.file.name} file upload failed.`);
      }
    },
  };

  return <>
    <div className="w-full step-one-h">
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
        <div className="h-[220px] overflow-auto flex flex-col">
          <div className="mb-3">
            <Popover content={() => (PersonList({ profiles: params.params.people }))}
                    title="Title"
                    trigger="click">
              <Button className="w-full h-8 min-h-8">
                Choose Paid By
              </Button>
            </Popover>
          </div>
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
      </Modal>
    </div>
  </>
}



export function PaidBy(params: { person: Person | null, toggle: Function} ): JSX.Element {
  return <div className="w-full flex flex-col">
    <div className={`bg-third cursor-pointer p-1 w-fit h-fit rounded-full text-center m-auto hover:opacity-50 ${!params.person && '!w-10 !h-10 flex items-center justify-center'}`}
        id="paid-by">
      {
        params.person?.profile
        ? <Avatar src={params.person.profile} className='w-8 h-8 ' />
        : <QuestionCircleOutlined className='text-xl'/>
      }
    </div>
    <small>{ params.person?.name || '' }</small>
  </div>
}

export function PersonList(params: { profiles: Person[]}): JSX.Element {
  return <div className="w-[200px] h-20 flex flex-row gap-5 justify-between overflow-x-auto">
    {
      params.profiles.map((person, index) => {
        return <div className="flex flex-col items-center gap-1 md:hover:opacity-50 cursor-pointer"
                    key={`person-${index}`}>
          <div className="p-1 w-fit h-fit bg-second rounded-full">
            <Avatar src={person.profile} className='w-8 h-8 ' />
          </div>
          <small className="text-center">{ person.name || '-' }</small>
        </div>
      })
    }
  </div>
}