'use client';

import { useEffect, useMemo, useState } from 'react';
import { useParams } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import ItemResults from '@/components/item-results';
import { Item } from '@/models/item.models';
import { Person } from '@/models/person.models';
import { HistoryResult } from '@/models/split.models';
import { RollbackOutlined, ShareAltOutlined } from '@ant-design/icons';
import { Button, message } from 'antd';
import Link from 'next/link';

type HistoryGroup = {
  needToBePaidByUUID: string;
  needToBePaidByName: string;
  rows: HistoryResult[];
};

type History = {
  memo: string | null;
  creatorName: string | null;
};

export default function HistoryPage(): JSX.Element {
  const params = useParams<{ historyId: string }>();
  const historyId =
    typeof params?.historyId === 'string' ? (params.historyId as string) : undefined;

  const supabase = useMemo(() => createClient(), []);
  const [messageApi, contextHolder] = message.useMessage();
  const [rows, setRows] = useState<HistoryResult[] | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [history, setHistory] = useState<History | null>(null);

  useEffect(() => {
    if (!historyId) return;
    let isMounted = true;

    (async () => {
      setErrorMessage(null);
      setRows(null);
      setHistory(null);

      const { data: historyData, error: historyError } = await supabase
        .from('history')
        .select('memo, creator_name')
        .eq('id', historyId)
        .maybeSingle();

      if (historyError) {
        if (!isMounted) return;
        setErrorMessage(historyError.message);
        return;
      }

      if (!isMounted) return;
      setHistory({
        memo: (historyData?.memo as string | null) ?? null,
        creatorName: (historyData?.creator_name as string | null) ?? null,
      });

      const { data, error } = await supabase
        .from('history_results')
        .select('*')
        .eq('history_id', historyId)
        .order('result_index', { ascending: true })
        .order('item_index', { ascending: true });

      if (error) {
        if (!isMounted) return;
        setErrorMessage(error.message);
        return;
      }

      if (!isMounted) return;
      setRows((data as HistoryResult[]) || []);
    })();

    return () => {
      isMounted = false;
    };
  }, [historyId, supabase]);

  const groups: HistoryGroup[] = useMemo(() => {
    if (!rows) return [];

    const map = new Map<string, HistoryGroup>();
    const orderedKeys: string[] = [];

    for (const row of rows) {
      const key = row.need_to_be_paid_by_uuid;
      if (!map.has(key)) {
        map.set(key, {
          needToBePaidByUUID: row.need_to_be_paid_by_uuid,
          needToBePaidByName: row.need_to_be_paid_by_name,
          rows: [],
        });
        orderedKeys.push(key);
      }
      map.get(key)!.rows.push(row);
    }

    return orderedKeys.map((k) => map.get(k)!);
  }, [rows]);

  function copyToClipboard(): void {
    navigator.clipboard.writeText(window.location.href);
    messageApi.info('Copied to clipboard!', 2);
  }

  if (!historyId) return <div>Missing history id.</div>;
  if (errorMessage) return <div>Failed to load history: {errorMessage}</div>;
  if (!rows) return <div>Loading...</div>;
  if (rows.length === 0) return <div>No history results found.</div>;

  return (
    <div className="max-w-[500px] m-auto px-3 w-full">
      { contextHolder }
      <h1 className="text-center text-main text-4xl md:text-5xl">
        Let&rsquo;s Split the Bills
      </h1>
      {history?.memo ? (
        <p className="text-center text-main mt-4 mb-0">
          <span className="font-bold">Memo:</span> {history.memo}
        </p>
      ) : null}
      {history?.creatorName ? (
        <p className="text-center text-main mb-0">
          <span className="font-bold">Shared by:</span> {history.creatorName}
        </p>
      ) : null}
      <div className="history-content rounded bg-[#faf1e6] overflow-auto p-5 my-5">
        {groups.map((group) => {
          const items: Item[] = group.rows.map((row) => {
            const isPercentage = row.is_percentage;
            const sharedNumber = Number(row.number_of_shared_person);
            const amount = Number(row.amount);
            const finalPrice = Number(row.final_price);

            // ItemResults only needs `paidBy.name` for display.
            const paidBy = new Person({
              name: row.paid_by_name,
              profile: '',
            });

            return new Item({
              name: row.item_name,
              price: isPercentage ? finalPrice : amount,
              sharedNumber: sharedNumber || 1,
              paidBy: paidBy,
              isPercentage: isPercentage,
              percent: isPercentage ? amount : 0,
            });
          });

          const totalsByPaidByName = group.rows.reduce<Record<string, number>>(
            (acc, row) => {
              const key = row.paid_by_name;
              acc[key] = (acc[key] || 0) + Number(row.final_price);
              return acc;
            },
            {}
          );

          return (
            <div key={group.needToBePaidByUUID} className="flex flex-col justify-between mb-1 w-full">
              <h4 className="w-full mb-3 text-center">
                <span className="font-bold text-main">{group.needToBePaidByName}</span>
                <span className="pl-1">has to pay</span>
              </h4>

              <ItemResults items={items} />

              <hr className="my-2 border-dashed border-gray-400" />

              {Object.keys(totalsByPaidByName)
                .filter((paidByName) => paidByName !== group.needToBePaidByName)
                .map((paidByName, paidByNameIndex) => (
                  <li
                    key={`history-total-${paidByNameIndex}`}
                    className="flex flex-row w-full justify-between my-1"
                  >
                    <span className="pr-2 font-bold">{paidByName} total</span>
                    <b className="font-bold pl-2">
                      {totalsByPaidByName[paidByName].toFixed(2)}
                    </b>
                  </li>
                ))}
              
              <hr className='border-gray-900 w-full my-3'/>
            </div>
          );
        })}
      </div>

      <div className="w-full flex flex-row gap-3">
        <div className='w-1/2 text-center'>
          <Link href="/" passHref legacyBehavior>
            <Button
              type="default"
              className='w-full'
              icon={<RollbackOutlined />}>
              Go to Home
            </Button>
          </Link>
        </div>

        <Button
          type="primary"
          className='w-1/2'
          onClick={ () => copyToClipboard() }
          icon={<ShareAltOutlined />}>
          Share
        </Button>
      </div>
        
    </div>
  );
}

