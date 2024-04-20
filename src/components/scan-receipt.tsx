import { Person } from "@/models/person.models";
import { ScanResponse, Scanner } from "@/models/scanner.models";
import { InboxOutlined } from "@ant-design/icons";
import { Modal, Popover, Button, UploadProps, message, Upload } from "antd";

import Dragger from "antd/es/upload/Dragger";
import { useEffect, useState } from "react";
import RoundedAvatar from "./custom-avatar";
import { Item } from "@/models/item.models";
import ItemTable, { ItemTableParams } from "./item-table";

export interface ScanReceiptParams {
  people: Person[];
  scanner: Scanner;
  setScanner: Function;
  openScanPopup: boolean;
  toggleScan: Function;
  mergeItems: Function;
}

export default function ScanReceipt(params: ScanReceiptParams): JSX.Element {
  
  const [open, setOpen]= useState<boolean>(false);

  const [messageApi, contextHolder] = message.useMessage();

  const [scannedItems, setScannedItems] = useState<Item[]>();
  const [paidByIndex, setPaidByIndex] = useState<number | null>(null);
  const [currentIndex, setCurrentIndex] = useState<number | null>(null);

  useEffect(() => {
    setScannedItems([]);
  }, [params.openScanPopup]);


  const props: UploadProps = {
    name: 'image',
    multiple: false,
    defaultFileList: [],
    maxCount: 1,
    className: 'w-full',
    listType: "picture",
    action: 'https://xw3pr7ak-7dqrsyftta-de.a.run.app/extract_data?output_language=English',
    onChange(info) {
      switch (info.file.status) {
        case 'uploading':
          messageApi.loading('Uploading file...');
          break;
        case 'done':
          params.scanner.response =  info.file.response as ScanResponse;
          params.setScanner(params.scanner);
          break;
        case 'error':
          messageApi.error(`${info.file.name} file upload failed.`);
          break;
      }
    },
  };

  function scanImage(): void {
    if (!params.scanner.response) {
      messageApi.error('Please upload a file first');
      return;
    }
    const scannedItems = params.scanner.response.items.map(each => new Item({
      name: each.translated_name,
      price: each.price,
      paidBy: params.scanner.paidBy,
    }));
    setScannedItems(scannedItems);
  }

  const itemParams: ItemTableParams = {
    items: scannedItems || [],
    setItems: setScannedItems,
    setCurrentIndex: setCurrentIndex,
    currentIndex: currentIndex,
    setPaidByIndex: setPaidByIndex,
  }

  function getContent(): JSX.Element {
    if (scannedItems?.length) {
      return <div className="max-h-[400px] overflow-y-auto">
        <ItemTable {...itemParams} />
        <Button type="primary"
          className="w-full max-h-8 sticky bottom-0"
          onClick={() => params.mergeItems(scannedItems) }>
          Done
        </Button>
      </div>
    }

    return <>
      <div className="h-fit max-h-[350px] my-3 overflow-auto">
        <div className="flex flex-col">
          <Popover content={() => 
                    (PersonList({ 
                      profiles: params.people,
                      scanner: params.scanner,
                      setScanner: params.setScanner,
                      setOpen: setOpen,
                    }))
                  }
                  open={open}
                  title="Choose Who Paid">
            {
              params.scanner.paidBy?.profile
              ? <div className="flex flex-row gap-5 justify-center items-center"
                      onClick={ () => setOpen(!open)}>
                <h5 className="w-auto">Paid By</h5>
                <div className="w-auto">
                  <RoundedAvatar person={params.scanner.paidBy}/>
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
            <Upload {...props}>
              <Button icon={<InboxOutlined />}>Click to upload</Button>
            </Upload>
          </div>
        </div>
      </div>
      
      <Button type="primary"
        className="w-full max-h-8"
        onClick={() => scanImage() }>
        Scan the Receipt
      </Button>
    </>
  }


  return <>
    { contextHolder }
    <Modal title="Upload your receipt"
             footer={null}
             centered
             onCancel={ () => params.toggleScan() }
             open={ params.openScanPopup } >
      { getContent() }
    </Modal>
  </>
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