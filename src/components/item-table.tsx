import { Item } from "@/models/item.models";
import { CheckOutlined, CloseOutlined, EditOutlined, DeleteOutlined, LoadingOutlined } from "@ant-design/icons";
import { Tooltip, Popconfirm, Input } from "antd";
import { useEffect, useState } from "react";
import RoundedAvatar from "./custom-avatar";
import UnknownPerson from "./unknown-person";
import checkValidOrNot from "@/common/service";
import SplitItem from "./split-item";

export interface ItemTableParams {
  items: Item[];
  originalItem: Item | null;
  setItems: Function;
  setCurrentIndex: Function;
  currentIndex: number | null;
  setPaidByIndex: Function;
  setOriginalItem: Function;
  showTotal: boolean;
}

export default function ItemTable(params: ItemTableParams): JSX.Element {
  const [rendering, setRendering] = useState<boolean>(false);

  useEffect(() => {
    if (params.items.length === 1) {
      params.setCurrentIndex(0);
    }
  }, []);

  useEffect(() => {
    scrollToId();
  }, [params.currentIndex]);

  useEffect(() => {
    setRendering(true);

    setTimeout(() => {
      setRendering(false);
    }, 500);
  }, [params.items.length])

  function saveEdit(): void {
    if (!checkValidOrNot(params.currentIndex!, params.items, params.setItems)) {
      return;
    }
    params.setItems([...params.items]);
    params.setOriginalItem(null);
    params.setCurrentIndex(null);
  }

  function cancelEdit(index: number): void {
    const editingItem = params.items[index];
    if (editingItem.name === '' && editingItem.price === 0) {
      deleteItem(index);
      return;
    }
    params.items[index] = params.originalItem || new Item({});
    const allItems = structuredClone(params.items);
    params.setItems([]);
    setTimeout(() => {
      params.setItems(allItems.map(each => new Item({...each})));
      params.setOriginalItem(null);
      params.setCurrentIndex(null);
    }, 1);
  }

  function editItem(index: number): void {
    if (params.currentIndex && !checkValidOrNot(params.currentIndex!, params.items, params.setItems)) {
      return;
    }
    const cloned = structuredClone(params.items[index]);
    params.setOriginalItem(cloned);
    params.setCurrentIndex(index);
  }

  function deleteItem(index: number): void {
    params.items.splice(index, 1);
    params.setItems([...params.items]);
    params.currentIndex === index && params.setCurrentIndex(null);
  }

  function scrollToId(): void {
    const id = document.getElementById(`item-${params.currentIndex}`);
    if (id) {
      id.scrollIntoView();
    }
  }

  return <>
  {
    rendering 
      ? <div className="flex flex-row justify-center">
          <span className="mr-2">Loading</span>
          <LoadingOutlined />
        </div>
      : <table className="w-full">
        <thead>
          <tr>
            <th className="w-[20px]">No.</th>
            <th className="w-2/12">Paid By</th>
            <th className="w-4/12">Item Name</th>
            <th className="w-2/12">Quantity</th>
            <th className="w-2/12">Total Price</th>
            <th className="w-1/12"></th>
          </tr>
        </thead>
        <tbody>
          {
            params?.items?.map((eachItem, itemIndex) => {
              return <tr key={`item-${itemIndex}-${eachItem.name}`}>
                <td className="text-center">{ itemIndex + 1}</td>
                <td className="text-center">
                  <Tooltip title={eachItem.error.paidBy || '' }
                            open={!!eachItem.error.paidBy}
                            color={'#ff4d4f'}
                            zIndex={10} >

                    <div onClick={() => params.setPaidByIndex(itemIndex)}>
                      {
                        eachItem.paidBy
                        ? <RoundedAvatar person={eachItem.paidBy} />
                        : <UnknownPerson />
                      }
                    </div>
                  </Tooltip>
                </td>
                <td className="px-1 md:px-3"
                    id={`${itemIndex}-${eachItem.name}`}>
                  <Tooltip title={eachItem.error.name || '' }
                            open={!!eachItem.error.name}
                            color={'#ff4d4f'}
                            zIndex={10} fresh>
                    <div>
                      <Input id={`item-name-${itemIndex}-${eachItem.name}`}
                          type="text"
                          disabled={ params.currentIndex !== itemIndex }
                          defaultValue={eachItem.name}
                          onChange={(e) => {
                            e.preventDefault();
                            eachItem.name = e.target.value;
                            delete eachItem.error.name;
                            params.items[itemIndex] = eachItem;
                            params.setItems(params.items);
                          }}
                          placeholder="KFC, McDonalds, etc."
                          className="w-full"
                      />
                    </div>
                  </Tooltip>
                </td>
                <td className="px-1 md:px-3">
                  <Tooltip title={eachItem.error.quantity || '' }
                            open={!!eachItem.error.quantity}
                            color={'#ff4d4f'}
                            zIndex={10} >
                    <div className="flex flex-row items-center">
                      {
                        eachItem.quantity > 1 && params.currentIndex !== itemIndex &&
                        <div className="min-w-[30px] p-1">
                          <SplitItem item={eachItem} items={params.items} index={itemIndex} setItems={params.setItems} />
                        </div>
                      }
                      <div className="grow-0">
                        <Input id="item-price"
                              type="number"
                              inputMode="decimal"
                              disabled={ params.currentIndex !== itemIndex }
                              placeholder="1"
                              defaultValue={eachItem.quantity}
                              onChange={(e) => {
                                e.preventDefault();
                                eachItem.quantity = +e.target.value || 0;
                                delete eachItem.error.quantity;
                                params.items[itemIndex] = eachItem;
                                params.setItems(params.items);
                              }}
                              className="w-full"
                        />
                      </div>
                    </div>
                  </Tooltip>
                </td>
                <td className="px-1 md:px-3">
                  <Tooltip title={eachItem.error.price || '' }
                            open={!!eachItem.error.price}
                            color={'#ff4d4f'}
                            zIndex={10} >
                    <div>
                      <Input id="item-price"
                            type="number"
                            inputMode="decimal"
                            disabled={ params.currentIndex !== itemIndex }
                            placeholder="0.00"
                            defaultValue={eachItem.price}
                            onChange={(e) => {
                              e.preventDefault();
                              eachItem.price = +e.target.value || 0;
                              delete eachItem.error.price;
                              params.items[itemIndex] = eachItem;
                              params.setItems(params.items);
                            }}
                            className="w-full"
                      />
                    </div>
                  </Tooltip>
                </td>
                <td>
                  {
                    params.currentIndex === itemIndex
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
          {
            params.showTotal &&
            <tr className="border-t-2 border-main">
              <td colSpan={4}
                  className="text-right text-xl pr-3 font-bold py-4">
                Total
              </td>
              <td colSpan={2}
                  className="font-bold pl-3 text-xl py-4">
                { params.items.reduce((acc, each) => acc + each.price, 0).toFixed(2) }
              </td>
            </tr>
          }
        </tbody>
      </table>
  }
  </>
}