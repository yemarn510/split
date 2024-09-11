import { Item } from "@/models/item.models";
import { CheckOutlined, ScissorOutlined, UndoOutlined } from "@ant-design/icons";
import { Button, Modal } from "antd";
import { useState } from "react";



export interface SplitItemParams {
  item: Item;
  index: number;
  items: Item[];
  setItems: Function;
}

export default function SplitItem(params: SplitItemParams): JSX.Element {
  const [showPopup, setShowPopup] = useState(false);
  const [splittedItems, setSplittedItems] = useState<Item[]>([]);

  function toggleSharePopup(): void {
    const isOpen = showPopup === true;
    !isOpen && undo();
    setShowPopup(!showPopup);
  }

  function save(): void {
    const allItems = structuredClone(params.items);
    const itemsBefore = allItems.slice(0, params.index);
    const itemsAfter = allItems.slice(params.index + 1);
    let items = [...itemsBefore, ...splittedItems, ...itemsAfter];
    items = items.map( each => new Item(each));
    params.setItems(items);
    setShowPopup(false);
  }

  function splitItem(index: number): void {
    const cloned = [...splittedItems];
    const initialItem = cloned[index];
    const initialQuantity = initialItem.quantity;
    const newQuantity = initialQuantity - 1;

    const newItem = new Item({...initialItem, quantity: 1, price: initialItem.price * (1 / initialQuantity)});

    initialItem.quantity = newQuantity;
    initialItem.price = initialItem.price * (newQuantity / initialQuantity);
    cloned[index] = initialItem;
    cloned.push(newItem);
    setSplittedItems(cloned);
  }

  function undo(): void {
    const items = structuredClone(params.item)
    setSplittedItems([items]);
  }


  return <>
    <ScissorOutlined onClick={() => toggleSharePopup() } />

    <Modal title="Split Items by Quantity"
         footer={null}
         centered
         width={600}
         onCancel={ () => toggleSharePopup() }
         open={showPopup} >
      <div className="w-full flex flex-row mb-3 text-main font-bold text-center">
        <div className="w-1/3">
          Item Name
        </div>
        <div className="w-1/3">
          Quantity
        </div>
        <div className="w-1/3">
          Price
        </div>
        <div className="w-[40px]"></div>
      </div>
      {
        splittedItems.map((item, index) => {
          return <div key={`item-${index}`} 
                      className="w-full flex items-center flex-row border-b py-2">
            <div className="w-1/3">
              {item.name}
            </div>
            <div className="w-1/3 text-center">
              {item.quantity}
            </div>
            <div className="w-1/3 text-center">
              {item.price}
            </div>
            <div className="w-[40px] cursor-pointer"
              onClick={ () => splitItem(index) }>
              <ScissorOutlined />
            </div>
          </div>
        })
      }

      <div className="flex flex-row gap-3 mt-5">
        <Button
          className="w-1/2"
          type="default"
          onClick={ () => undo() }
          icon={<UndoOutlined />}>
          Undo
        </Button>

        <Button
          className="w-1/2"
          type="primary"
          onClick={ () => save() }
          icon={<CheckOutlined />}>
          Save
        </Button>
      </div>


    </Modal>
  </>
}