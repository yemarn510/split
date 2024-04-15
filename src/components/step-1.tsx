'use client';

import { Item } from "@/models/item.models";
import { useEffect, useState } from "react";

export interface StepOneParams {
  items: Item[];
  setItems: Function;
}

export default function StepOne(params: { params: StepOneParams }): JSX.Element {

  const [showItems, setShowItems] = useState(false);

  useEffect(() => {
    params.params.items.length === 0 && addItem();
  }, []);

  useEffect(() => {
    setShowItems(false);
    setTimeout( () => {
      setShowItems(true);
    }, 10);
  }, [params.params.items]);

  function addItem(): void {
    params.params.items.push(new Item({}));
    params.params.setItems(params.params.items);
  }

  return <>
    <div className="w-full">
      {
        showItems
        ?
          params.params?.items?.map((eachItem, index) => {
            return <div className="flex flex-row w-full gap-5"
                        key={index + 1}>
            <div className="w-2/3 flex flex-col">
              <label htmlFor="item-name"
                    className="pb-2 text-fourth">
                Item Name
              </label>
              <input id="item-name"
                    type="text"
                    onChange={(e) => {
                      eachItem.name = e.target.value;
                      params.params.items[index] = eachItem;
                      params.params.setItems(params.params.items);
                    }}
                    placeholder="Kentucky Fried Chicken"
                    className="input input-bordered w-full"
              />
            </div>
            <div className="w-1/3 flex flex-col">
              <label htmlFor="item-price"
                    className="pb-2 text-fourth">
                Price
              </label>
              <input id="item-price"
                    type="number"
                    placeholder="0.00"
                    onChange={(e) => {
                      eachItem.price = +e.target.value || 0;
                      params.params.items[index] = eachItem;
                      params.params.setItems(params.params.items);
                    }}
                    className="input input-bordered w-full"
              />
            </div>
          </div>
          })
        : 
          <div className="w-full flex justify-center">
            <span className="loading loading-bars loading-md"></span>
          </div>
      }
    </div>

    <div className="flex flex-row justify-end pt-10">
      <button className="ml-auto btn"
        onClick={ () => addItem() }>
        Add Item
      </button>
    </div>
  </>
}