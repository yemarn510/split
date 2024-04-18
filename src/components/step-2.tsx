'use client';

import { Item } from "@/models/item.models";
import { Input, Button, Popconfirm, Avatar, Modal } from 'antd';
import { CheckOutlined, CloseOutlined, EditOutlined, DeleteOutlined, QuestionCircleOutlined } from '@ant-design/icons';
import { useEffect, useState } from "react";
import { AVATAR_URL, Person } from "@/models/person.models";


export interface StepTwoParams {
  items: Item[];
  people: Person[];
  setItems: Function;
}

export default function StepTwo(params: { params: StepTwoParams }): JSX.Element {

  const [ currentIndex, setCurrentIndex ] = useState<number | null>(null);
  const [originalItem, setOriginalItem] = useState<Item | null>(null);
  const [currentPaidBy, setCurrentPaidBy] = useState<number | null>(null);

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
    index === null && setCurrentPaidBy(null);
    if (currentIndex !== index) {
      return;
    }
    setCurrentPaidBy(index);
  }

  function setPaidBy(personIndex: number): void {
    params.params.items[currentIndex!].paidBy = params.params.people[personIndex];
    params.params.setItems([...params.params.items]);
    setCurrentPaidBy(null);
  }

  return <>
    <div className="w-full step-one-h">
      {
        params.params?.items?.map((eachItem, index) => {
          return <div className="flex flex-row w-full gap-3 md:gap-5 mb-3"
                      id={`item-${index}`}
                      key={index + 1}>
            <div className="w-1/6 pt-9 flex justify-center">
              { index + 1 }
            </div>

            <div className="w-1/6 flex flex-col">
              <label htmlFor="paid-by"
                    className="pb-2 text-main">
                Paid By
              </label>
              <div className={`bg-third cursor-pointer p-1 w-fit h-fit rounded-full text-center my-auto hover:opacity-50 ${!eachItem.paidBy && '!w-10 !h-10 flex items-center justify-center'}`}
                   id="paid-by"
                   onClick={() => togglePaidBy(index) }>
                {
                  eachItem.paidBy?.profile
                  ? <Avatar src={eachItem.paidBy.profile} className='w-8 h-8 ' />
                  : <QuestionCircleOutlined className='text-xl'/>
                }
              </div>
            </div>


            <div className={`w-2/6 flex flex-col`}>
              <label htmlFor="item-name"
                    className="pb-2 text-main">
                Item Name
              </label>
              <Input id="item-name"
                    type="text"
                    disabled={ currentIndex !== index }
                    defaultValue={eachItem.name}
                    onChange={(e) => {
                      e.preventDefault();
                      eachItem.name = e.target.value;
                      params.params.items[index] = eachItem;
                      params.params.setItems(params.params.items);
                      delete eachItem.error.name;
                    }}
                    placeholder="KFC, McDonalds, etc."
                    className="w-full"
              />
              <small className="text-danger">
                { eachItem.error.name || ' ' }
              </small>
            </div>

            <div className={`w-1/6 flex flex-col`}>
              <label htmlFor="item-price"
                    className="pb-2 text-main">
                Price
              </label>
              <Input id="item-price"
                    type="number"
                    inputMode="decimal"
                    disabled={ currentIndex !== index }
                    placeholder="0.00"
                    defaultValue={eachItem.price}
                    onChange={(e) => {
                      e.preventDefault();
                      eachItem.price = +e.target.value || 0;
                      params.params.items[index] = eachItem;
                      params.params.setItems(params.params.items);
                      delete eachItem.error.price;
                    }}
                    className="w-full"
              />
              <small className="text-danger">
                { eachItem.error.price || ' ' }
              </small>
            </div>

            <div className="w-1/5 flex items-start pt-9 justify-center">
                {
                  currentIndex === index
                    ? 
                      <div className="flex flex-row justify-center items-end pb-1 gap-5">
                        <CheckOutlined className="text-main text-xl" 
                                       onClick={() => saveEdit()}/>
                        <CloseOutlined className="text-danger text-xl"
                                       onClick={() => cancelEdit(index)}/>
                      </div>
                    : 
                      <div className="flex flex-row justify-center items-end pb-1 gap-5">
                        <EditOutlined className="text-main text-xl"
                                      onClick={() => editItem(index)} />
                        <Popconfirm title="Delete the task"
                                    description="Are you sure to delete this item?"
                                    onConfirm={() => deleteItem(index)}
                                    onCancel={ () => {}}
                                    okText="Yes"
                                    cancelText="No">
                          <DeleteOutlined className="text-danger text-xl"/>
                        </Popconfirm>
                      </div>
                }
              </div>
          </div>
        })
      }

      <Button className="w-full mt-3 h-8 min-h-8 sticky bottom-0"
        type="primary"
        onClick={ () => addItem() }>
        Add Item
      </Button>

      <Modal title="Set Paid By"
             footer={null}
             centered
             onCancel={ () => togglePaidBy(null) }
             open={ currentPaidBy !== null} >
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
    </div>
  </>
}

