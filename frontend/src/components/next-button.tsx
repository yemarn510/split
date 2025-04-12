'use client';

import { Result } from "@/models/results.models";
import { ExportOutlined, ArrowRightOutlined, CopyOutlined } from "@ant-design/icons";
import { message, Modal, Button } from "antd";
import { useState } from "react";

export interface NextButtonProps {
  currentStep: number,
  results: Result[],
  steps: { title: string}[],
  goNextButtonDisabled: Function,
  goNext: Function
}

export default function GetButton(params: { params: NextButtonProps }): JSX.Element {

  const [openSharePopup, setOpenSharePopup] = useState<boolean>(false);
  const [messageApi, contextHolder] = message.useMessage();

  function toggleSharePopup(): void {
    setOpenSharePopup(!openSharePopup);
  }

  function copyToClipboard(): void {
    const text = params.params.results
      .filter( person => person.total > 0 )
      .map((eachResult: Result, resultIndex: number) => {
        const items = Object.keys(eachResult.totalToPayFor || {}).map((paidByName, paidByNameIndex) => {
          return `${paidByName} - ${eachResult.totalToPayFor ? eachResult.totalToPayFor[paidByName].toFixed(2) : 0}`;
        }).join('\n');
        return `${eachResult.person.name} has to pay\n${items}\n-------------------------`;
      }).join('\n');
    navigator.clipboard.writeText(text);
    messageApi.info('Copied !', 2);
  }

  function whichButton(): JSX.Element {
    if (params.params.currentStep === 3) {
      return <div className={`${params.params.currentStep !== 3 && 'hidden' } flex flex-row gap-1 md:gap-3 items-center cursor-pointer md:hover:opacity-50 `}
            onClick={ () => toggleSharePopup() }>
        <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
          <ExportOutlined className="text-main" />
        </div>
        <p className="mb-0 w-auto text-main">Share</p>
      </div>
    }
  
    return <div className={`flex flex-row gap-1 md:gap-3 items-center cursor-pointer md:hover:opacity-50 
                            ${ params.params.currentStep === (params.params.steps.length - 1) && 'cursor-not-allowed opacity-50'}
                            ${ params.params.goNextButtonDisabled() && '!cursor-not-allowed opacity-50'}`} 
        onClick={ () => params.params.goNext() }>
      <div className="w-10 h-10 flex justify-center items-center rounded-full border border-main">
        <ArrowRightOutlined className="text-main" />
      </div>
      <p className="mb-0 w-auto text-main">Go Next</p>
    </div>
  }

  return <>
  { contextHolder }
  { whichButton() }
  
  <Modal title="Share with your friends"
         footer={null}
         centered
         width={400}
         onCancel={ () => toggleSharePopup() }
         open={openSharePopup} >
      <div className='h-[320px] rounded bg-[#faf1e6] overflow-auto p-5'>
        {
          params.params.results
            .filter( person => person.total > 0 )
            .map((eachResult: Result, resultIndex: number) =>
            <div key={`result-index-${resultIndex}`}
                className='flex flex-col justify-between mb-1'>
                  <div className='w-full'>
                    <span className="font-bold">{ eachResult.person.name }</span>
                    <span className="pl-1">has to pay</span>
                  </div>
                  {
                    Object.keys(eachResult.totalToPayFor || {}).map((paidByName, paidByNameIndex) => {
                      return <li key={`result-item-${paidByNameIndex}`}
                                className="flex flex-row">
                      <span className='pr-2'>{ paidByName }</span> -
                      <b className='font-bold pl-2'>{ (eachResult.totalToPayFor ? eachResult.totalToPayFor[paidByName] : 0).toFixed(2)}</b>
                    </li>
                    })
                  }
                  ---------------------------------------------
                </div>
            )
        }
      </div>
      <div className='text-center mt-5'>
        <Button
          onClick={ () => copyToClipboard() }
          icon={<CopyOutlined />}>
          Copy To Clipboard
        </Button>
      </div>
    </Modal>
  </>
}