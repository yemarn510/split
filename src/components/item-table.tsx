import { Item } from "@/models/item.models";
import { CheckOutlined, CloseOutlined, EditOutlined, DeleteOutlined } from "@ant-design/icons";
import { Tooltip, Popconfirm, Input } from "antd";
import { PaidBy } from "./step-2";
import { useEffect, useState } from "react";

export interface ItemTableParams {
  items: Item[];
  setItems: Function;
  setCurrentIndex: Function;
  currentIndex: number | null;
  checkValidOrNot: Function;
  togglePaidBy: Function;
}

export default function ItemTable(params: ItemTableParams): JSX.Element {

  const [originalItem, setOriginalItem] = useState<Item | null>(null);

  useEffect(() => {
    if (params.items.length === 1) {
      params.setCurrentIndex(0);
    }
  }, []);

  useEffect(() => {
    scrollToId();
  }, [params.currentIndex]);

  function saveEdit(): void {
    if (!params.checkValidOrNot(params.currentIndex!)) {
      return;
    }
    params.setItems([...params.items]);
    setOriginalItem(null);
    params.setCurrentIndex(null);
  }

  function cancelEdit(index: number): void {
    const editingItem = params.items[index];
    if (editingItem.name === '' && editingItem.price === 0) {
      deleteItem(index);
      return;
    }
    params.items[index] = originalItem || new Item({});
    const allItems = structuredClone(params.items);
    params.setItems([]);
    setTimeout(() => {
      params.setItems(allItems.map(each => new Item({...each})));
      setOriginalItem(null);
      params.setCurrentIndex(null);
    }, 1);
  }

  function editItem(index: number): void {
    if (params.currentIndex && !params.checkValidOrNot(params.currentIndex!)) {
      return;
    }
    const cloned = structuredClone(params.items[index]);
    setOriginalItem(cloned);
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

  return <table className="w-full">
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
      params?.items?.map((eachItem, itemIndex) => {
        return <tr key={`item-${itemIndex}`}>
          <td className="text-center">{ itemIndex + 1}</td>
          <td className="text-center">
            <Tooltip title={eachItem.error.paidBy || '' }
                     open={!!eachItem.error.paidBy}
                     color={'#ff4d4f'}
                     zIndex={10} >
              <PaidBy person={eachItem.paidBy}
                      toggle={() => params.togglePaidBy(itemIndex)} />
            </Tooltip>
          </td>
          <td className="px-1 md:px-3">
            <Tooltip title={eachItem.error.name || '' }
                     open={!!eachItem.error.name}
                     color={'#ff4d4f'}
                     zIndex={10} >
              <Input id="item-name"
                  type="text"
                  disabled={ params.currentIndex !== itemIndex }
                  defaultValue={eachItem.name}
                  onChange={(e) => {
                    e.preventDefault();
                    eachItem.name = e.target.value;
                    params.items[itemIndex] = eachItem;
                    params.setItems(params.items);
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
                      disabled={ params.currentIndex !== itemIndex }
                      placeholder="0.00"
                      defaultValue={eachItem.price}
                      onChange={(e) => {
                        e.preventDefault();
                        eachItem.price = +e.target.value || 0;
                        params.items[itemIndex] = eachItem;
                        params.setItems(params.items);
                        delete eachItem.error.price;
                      }}
                      className="w-full"
                />
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
  </tbody>
</table>
}