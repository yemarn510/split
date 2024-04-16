'use client';

import { Item } from "@/models/item.models";
import { Input, Button } from 'antd';
import { CheckOutlined, CloseOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { useState } from "react";


export interface StepOneParams {
  items: Item[];
  setItems: Function;
}

export default function StepOne(params: { params: StepOneParams }): JSX.Element {

  const [ currentIndex, setCurrentIndex ] = useState<number | null>(0);
  const [originalItem, setOriginalItem] = useState<Item | null>(null);

  function addItem(): void {
    if (!checkValidOrNot(params.params.items.length - 1)) {
      return;
    }
    params.params.items.push(new Item({}));
    params.params.setItems([...params.params.items]);
    setCurrentIndex((currentIndex || 0) + 1);
  }

  function saveEdit(index: number): void {
    if (!checkValidOrNot(currentIndex!)) {
      return;
    }
    params.params.setItems([...params.params.items]);
    setOriginalItem(null);
    setCurrentIndex(null);
  }

  function cancelEdit(index: number): void {
    const editingItem = params.params.items[index];
    if (editingItem.name === '' && editingItem.price === 0 && editingItem.quantity === 1) {
      params.params.items.splice(index, 1);
      params.params.setItems([...params.params.items]);
      setOriginalItem(null);
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
  }

  function checkValidOrNot(index: number): boolean {
    const isValid = params.params.items[index].isValid();
    params.params.items[index].error = params.params.items[index].error || {};
    params.params.setItems([...params.params.items]);
    return isValid;
  }

  return <>
    <div className="w-full">
      {
        params.params?.items?.map((eachItem, index) => {
          return <div className="flex flex-row w-full gap-5 mb-3"
                      key={index + 1}>
            <div className={`w-3/5 flex flex-col`}>
              <label htmlFor="item-name"
                    className="pb-2 text-main">
                Item Name
              </label>
              <Input id="item-name"
                    type="text"
                    disabled={ currentIndex !== index }
                    defaultValue={eachItem.name}
                    onChange={(e) => {
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

            <div className={`w-1/5 flex flex-col`}>
              <label htmlFor="item-price"
                    className="pb-2 text-main">
                Price
              </label>
              <Input id="item-price"
                    type="number"
                    disabled={ currentIndex !== index }
                    placeholder="0.00"
                    defaultValue={eachItem.price}
                    onChange={(e) => {
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

            <div className={`w-1/5 flex flex-col`}>
              <label htmlFor="item-quantity"
                    className="pb-2 text-main">
                Quantity
              </label>
              <Input id="item-quantity"
                    type="number"
                    disabled={ currentIndex !== index }
                    defaultValue={eachItem.quantity}
                    placeholder="0.00"
                    min={1}
                    onChange={(e) => {
                      eachItem.quantity = +e.target.value || 1;
                      params.params.items[index] = eachItem;
                      params.params.setItems(params.params.items);
                      delete eachItem.error.quantity;
                    }}
                    className="w-full"
              />
              <small className="text-danger">
                { eachItem.error.quantity || ' ' }
              </small>
            </div>

            <div className="w-1/5 flex items-start pt-9 justify-center">
                {
                  currentIndex === index
                    ? 
                      <div className="flex flex-row justify-center items-end pb-1 gap-5">
                        <CheckOutlined className="text-main text-xl" 
                                       onClick={() => saveEdit(index)}/>
                        <CloseOutlined className="text-danger text-xl"
                                       onClick={() => cancelEdit(index)}/>
                      </div>
                    : 
                      <div className="flex flex-row justify-center items-end pb-1 gap-5">
                        <EditOutlined className="text-main text-xl"
                                      onClick={() => editItem(index)} />
                        <DeleteOutlined className="text-danger text-xl"
                                        onClick={() => deleteItem(index)}/>
                      </div>
                }
              </div>
          </div>
        })
      }
    </div>

    <Button className="w-full mt-3 h-8 min-h-8"
      type="primary"
      onClick={ () => addItem() }>
      Add Item
    </Button>
  </>
}

