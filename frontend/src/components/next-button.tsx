'use client';

import { Result } from "@/models/results.models";
import { ExportOutlined, ArrowRightOutlined, CopyOutlined, HistoryOutlined } from "@ant-design/icons";
import { message, Modal, Button } from "antd";
import { useEffect, useMemo, useState } from "react";
import ItemResults from "./item-results";
import { useRouter } from "next/navigation";
import { createClient } from "@/utils/supabase/client";
import { HistoryResult } from "@/models/split.models";

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
  const [isSharing, setIsSharing] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const router = useRouter();
  const supabase = useMemo(() => createClient(), []);

  const results = params.params.results.filter( person => person.total > 0 );

  useEffect(() => {
    let isMounted = true;
    (async () => {
      const { data, error } = await supabase.auth.getUser();
      if (!isMounted) return;
      setIsLoggedIn(!!data?.user && !error);
    })();
    return () => {
      isMounted = false;
    };
  }, [supabase]);

  function toggleSharePopup(): void {
    setOpenSharePopup(!openSharePopup);
  }

  function copyToClipboard(): void {
    const text = results
      .map((eachResult: Result) => {
        const items = eachResult?.items
          .filter(eachItem => eachItem.paidBy?.name !== eachResult.person.name)
          .map((eachItem) => {
          if (eachItem.isPercentage) {
            return `${eachItem.paidBy?.name} - ${eachItem.name} ${eachItem.percent} % - ${eachItem.price.toFixed(2)}`;
          }
          return `${eachItem.paidBy?.name} - ${eachItem.name} ${eachItem.price} / ${eachItem.sharedNumber} - ${(eachItem.price/eachItem.sharedNumber).toFixed(2)}`;
        }).join('\n');
        
        // Totals per person who was paid to (same as UI)
        const totals = Object.keys(eachResult.totalToPayFor || {})
        .filter(eachPersonName => eachPersonName !== eachResult.person.name)
        .map((paidByName) => {
          return `${paidByName} total ${(eachResult.totalToPayFor ? eachResult.totalToPayFor[paidByName] : 0).toFixed(2)}`;
        }).join('\n');
        
        return `${eachResult.person.name} has to pay\n${items}\n${totals}\n---------------------------------------------`;
      }).join('\n');
    navigator.clipboard.writeText(text);
    messageApi.info('Copied !', 2);
  }

  async function shareHistory(): Promise<void> {
    if (isSharing) return;
    setIsSharing(true);
    try {
      const { data: userData, error: userError } = await supabase.auth.getUser();
      const user = userData?.user;
      if (userError || !user) {
        messageApi.error('Please login with Google before sharing history.');
        return;
      }

      const { data: historyRow, error: historyInsertError } = await supabase
        .from('history')
        .insert({ creator_user_id: user.id })
        .select('id')
        .single();

      if (historyInsertError) throw historyInsertError;
      if (!historyRow?.id) throw new Error('Missing history id after insert.');

      const historyId: string = historyRow.id;

      const historyResultsRows: Array<HistoryResult> = [];

      results.forEach((eachResult: Result, resultIndex: number) => {
        const debtorName = eachResult.person.name;
        const debtorUuid = eachResult.person.uuid;

        const modalItems = (eachResult.items || []).filter(
          (eachItem) => eachItem.paidBy?.name !== debtorName
        );

        modalItems.forEach((eachItem, itemIndex) => {
          if (!eachItem.paidBy) return; // schema requires non-null paid_by_*

          historyResultsRows.push({
            history_id: historyId,
            result_index: resultIndex,
            item_index: itemIndex,
            need_to_be_paid_by_uuid: debtorUuid,
            need_to_be_paid_by_name: debtorName,
            paid_by_uuid: eachItem.paidBy.uuid,
            paid_by_name: eachItem.paidBy.name,
            item_name: eachItem.name,
            number_of_shared_person: eachItem.sharedNumber,
            amount: eachItem.isPercentage ? eachItem.percent : eachItem.price,
            final_price: eachItem.isPercentage
              ? eachItem.price
              : eachItem.price / eachItem.sharedNumber,
            is_percentage: eachItem.isPercentage,
          });
        });
      });

      if (historyResultsRows.length) {
        const { error: historyResultsInsertError } = await supabase
          .from('history_results')
          .insert(historyResultsRows);
        if (historyResultsInsertError) throw historyResultsInsertError;
      }

      setOpenSharePopup(false);
      router.push(`/history/${historyId}`);
      messageApi.success('History saved. Shareable link created.');
    } catch (err: any) {
      console.error(err);
      messageApi.error(err?.message || 'Failed to share history.');
    } finally {
      setIsSharing(false);
    }
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
          results.map((eachResult: Result, resultIndex: number) =>
            <div key={`result-index-${resultIndex}`}
                className='flex flex-col justify-between mb-1'>
              <div className='w-full mb-3'>
                <span className="font-bold">{ eachResult.person.name }</span>
                <span className="pl-1">has to pay</span>
              </div>
              <ItemResults items={eachResult?.items.filter(eachItem => eachItem.paidBy?.name !== eachResult.person.name) || []} />

              <hr className="my-2" />

              {
                Object.keys(eachResult.totalToPayFor || {})
                .filter(eachPersonName => eachPersonName !== eachResult.person.name)
                .map((paidByName, paidByNameIndex) => {
                  return <li key={`result-item-${paidByNameIndex}`}
                        className="flex flex-row w-full justify-between ">
                    <span className='pr-2 font-bold'>{ paidByName } total</span>
                    <b className='font-bold pl-2'>{ (eachResult.totalToPayFor ? eachResult.totalToPayFor[paidByName] : 0).toFixed(2)}</b>
                  </li>
                })
              }
              <hr className='border-dashed border-gray-900 w-full mt-3'/>
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

      
        {isLoggedIn ? (
          <div className='text-center mt-3'>
            <Button
              type="primary"
              className="px-8"
              loading={isSharing}
              onClick={ () => shareHistory() }
              icon={<HistoryOutlined />}>
              Share History
            </Button>
          </div>
        ) : null}
    </Modal>
  </>
}