'use client';

import { Item } from "@/models/item.models";
import { useEffect } from "react";

export interface StepOneParams {
  items: Item[];
  setItems: Function;
}

export default function StepOne(params: { params: StepOneParams }): JSX.Element {

  useEffect(() => {
    params.params.items.length === 0 && addItem();
  }, []);

  function addItem(): void {
    params.params.items.push(new Item({}));
    params.params.setItems([...params.params.items]);
  }

  return <>
    <div className="w-full">
      {
        params.params?.items?.map((eachItem, index) => {
          return <div className="flex flex-row w-full gap-5 mb-3"
                      key={index + 1}>
            <div className={`${ params.params.items.length > 1 ? 'w-2/4' : 'w-2/3'} flex flex-col`}>
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
            <div className={`${ params.params.items.length > 1 ? 'w-1/4' : 'w-1/3' } flex flex-col`}>
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

            {
              params.params.items.length > 1 &&
              <div className="w-1/4"></div>
            }
          </div>
        })
      }
    </div>

    <button className="btn w-full mt-3 h-8 min-h-8"
      onClick={ () => addItem() }>
      Add Item
    </button>
  </>
}