import { Person } from "@/models/person.models";
import { OrderItem, ScanResponse, Scanner } from "@/models/scanner.models";
import { InboxOutlined, UserOutlined, LoadingOutlined } from "@ant-design/icons";
import { Modal, Popover, Button, UploadProps, message, Upload, Tooltip, UploadFile } from "antd";

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
  const [loading, setLoading]= useState<boolean>(false);

  const [messageApi, contextHolder] = message.useMessage();

  const [scannedItems, setScannedItems] = useState<Item[]>();
  const [originalItem, setOriginalItem] = useState<Item | null>(null);
  const [paidByIndex, setPaidByIndex] = useState<number | null>(null);
  const [currentIndex, setCurrentIndex] = useState<number | null>(null);

  const [error, setError] = useState<{[key: string]: string}>({});

  useEffect(() => {
    setScannedItems([]);
    setError({});
  }, [params.openScanPopup]);


  const props: UploadProps = {
    name: 'image',
    multiple: false,
    defaultFileList: [],
    maxCount: 1,
    className: 'w-full',
    listType: "picture",
    onRemove: () => {
      params.scanner.image = null;
      params.setScanner(params.scanner);
    },
    beforeUpload: (file) => {
      deleteError('image');
      params.scanner.image = file;
      params.setScanner(params.scanner);
      return false;
    },
  };

  async function scanImage(): Promise<void> {
    if (!scanIsValid()) {
      return;
    }
    setLoading(true);
    const formData = new FormData();
    formData.append('image', params.scanner.image as Blob);
    const response = await fetch('/scan', {
      method: 'POST',
      body: formData,
    });
    params.scanner.response =  await response.json() as ScanResponse;
    params.setScanner(params.scanner);
    seeTheResult();
    setLoading(false);
  }

  function seeTheResult(): void {
    if (!params.scanner.response) {
      messageApi.error('Please upload a file first');
      return;
    }
    const scannedItems = params.scanner.response.items.map(each => new Item({
      name: each.translated_name,
      price: each.price * each.quantity,
      paidBy: params.scanner.paidBy,
      quantity: each.quantity,
      isPercentage: each.isPercentage
    }));
    setScannedItems(scannedItems);
  }

  function scanIsValid(): boolean {
    const newError: { [key: string]: string } = {};
    if (!params.scanner.paidBy) {
      newError.paidBy = 'Please choose who paid';
    }
    if (!params.scanner.image) {
      newError.image = 'Please upload an image';
    }
    setError(newError);
    return Object.keys(newError).length === 0;
  }

  function deleteError(key: string): void {
    delete error[key];
    setError(error);
  }

  const itemParams: ItemTableParams = {
    items: scannedItems || [],
    setItems: setScannedItems,
    setCurrentIndex: setCurrentIndex,
    currentIndex: currentIndex,
    setPaidByIndex: setPaidByIndex,
    setOriginalItem,
    originalItem,
    showTotal: true,
  }

  function getContent(): JSX.Element {
    if (scannedItems?.length) {
      return <div className="max-h-[400px] overflow-y-auto">
        <ItemTable {...itemParams} />
        <Button type="primary"
          className="w-full max-h-8 sticky bottom-0"
          onClick={() => params.mergeItems(scannedItems) }>
          Save Items
        </Button>
      </div>
    }

    return <>
      <div className="h-fit max-h-[350px] my-3 overflow-auto ">
        <div className="flex flex-col">
          <Popover content={() => 
                    (PersonList({ 
                      profiles: params.people,
                      scanner: params.scanner,
                      setScanner: params.setScanner,
                      setOpen: setOpen,
                      deleteError: deleteError,
                    }))
                  }
                  open={open}
                  title="Choose Who Paid">
            {
              params.scanner.paidBy?.profile
              ? <div className="flex flex-row gap-5 justify-center items-center"
                      onClick={ () => {
                        setOpen(!open);
                      }}>
                <h5 className="w-auto">Paid By</h5>
                <div className="w-auto">
                  <RoundedAvatar person={params.scanner.paidBy}/>
                </div> 
              </div>
              : <Button className="w-full h-8 min-h-8"
                        icon={<UserOutlined />}
                        onClick={ () => setOpen(!open)}>
                Choose Paid By
              </Button>
            }
            <small className="text-danger w-full mx-auto">{ error.paidBy  || ''}</small>
          </Popover>

          <hr className="w-full my-3" />
          
          <div className="w-auto h-auto">
            <Upload { ...props }>
              {
                !loading && !params.scanner.response &&
                <Button icon={<InboxOutlined />}
                        className="w-full">
                  Click to upload
                </Button>
              }
            </Upload>
            <small className="text-danger w-full mx-auto">{ error.image || ''}</small>
          </div>
        </div>
      </div>
      
      <Button type="primary"
              className="w-full max-h-8"
              id="scan-image-button"
              disabled={loading}
              icon={ loading ? <LoadingOutlined /> : <></>}
              onClick={() => scanImage() }>
        Scan Image
      </Button>
    </>
  }


  return <>
    { contextHolder }
    <Modal title="Upload your receipt"
           footer={null}
           centered
           onCancel={ () => {
             setOpen(false)
             setTimeout( () => {
               params.toggleScan();
             }, 1);
           }
          }
          open={ params.openScanPopup } >
      { getContent() }
    </Modal>
  </>
}

export function PersonList(params: { 
  profiles: Person[], 
  scanner: Scanner, 
  setScanner: Function, 
  setOpen: Function
  deleteError: Function
}): JSX.Element {
  return <div className="max-w-[200px] h-fit flex flex-row gap-5 justify-evenly overflow-x-auto">
    {
      params.profiles.map((person, index) => {
        return <div key={`person-${index}`}
                    onClick={() => {
                        params.setScanner({
                          ...params.scanner,
                          paidBy: person,
                        });
                        params.setOpen(false);
                        params.deleteError('paidBy');
                      }
                    }>
          <RoundedAvatar person={person} />
        </div>
      })
    }
  </div>
}