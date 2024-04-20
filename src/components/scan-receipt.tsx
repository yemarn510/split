import { Person } from "@/models/person.models";
import { ScanResponse, Scanner } from "@/models/scanner.models";
import { InboxOutlined } from "@ant-design/icons";
import { Modal, Popover, Button, UploadProps, message } from "antd";

import Dragger from "antd/es/upload/Dragger";
import { RoundedAvatar } from "./step-2";
import { useState } from "react";

export interface ScanReceiptParams {
  people: Person[];
  scanner: Scanner;
  setScanner: Function;
  openScanPopup: boolean;
  toggleScan: Function;
}

export default function ScanReceipt(params: ScanReceiptParams): JSX.Element {
  
  const [open, setOpen]= useState<boolean>(false);

  const [messageApi, contextHolder] = message.useMessage();
  

  const props: UploadProps = {
    name: 'image',
    multiple: false,
    maxCount: 1,
    className: 'w-full',
    listType: "picture",
    action: 'https://xw3pr7ak-7dqrsyftta-de.a.run.app/extract_data?output_language=English',
    onChange(info) {
      switch (info.file.status) {
        case 'uploading':
          message.loading('Uploading file...');
          break;
        case 'done':
          params.scanner.response =  info.file.response as ScanResponse;
          params.setScanner(params.scanner);
          break;
        case 'error':
          message.error(`${info.file.name} file upload failed.`);
          break;
      }
    },
  };

  function setScannedItems(): void {

  }

  return <>
    { contextHolder }
    <Modal title="Upload your receipt"
             footer={null}
             centered
             onCancel={ () => params.toggleScan() }
             open={ params.openScanPopup } >
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
          </div>
        </div>
        
        <Button type="primary"
          className="w-full max-h-8"
          onClick={() => setScannedItems() }>
          Set
        </Button>
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