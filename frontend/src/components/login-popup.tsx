'use client';

import { useCallback, useEffect, useMemo, useState } from "react";
import UnknownPerson from "./unknown-person";
import { GoogleOutlined, HistoryOutlined } from "@ant-design/icons";
import { Modal, Button, Spin } from "antd";
import { createClient } from "@/utils/supabase/client";
import { User } from "@supabase/supabase-js";
import Image from 'next/image';
import { Person } from "@/models/person.models";
import { useRouter } from "next/navigation";

export interface LoginPopupProps { 
  setPeople: Function, 
  isPremiumUser: boolean,
  setIsPremiumUser: Function
}

export default function LoginPopup(params: LoginPopupProps ): JSX.Element {

  const [user, setUser] = useState<User | null>(null);

  const supabase = useMemo(() => createClient(), []);
  const router = useRouter();
  const { setPeople, setIsPremiumUser } = params;

  const [openPopup, setOpenPopup] = useState(false);
  const [histories, setHistories] = useState<Array<{ id: string; memo: string | null }> | null>(null);
  const [historiesLoading, setHistoriesLoading] = useState(false);
  const [historiesError, setHistoriesError] = useState<string | null>(null);

  function togglePopup(): void {
    setOpenPopup(!openPopup);
  }

  const fetchUserHistories = useCallback(
    async (userId: string): Promise<void> => {
      setHistoriesLoading(true);
      setHistoriesError(null);
      try {
        const { data, error } = await supabase
          .from('history')
          .select('id, memo')
          .eq('creator_user_id', userId)
          .order('created_at', { ascending: false })
          .limit(50);

        if (error) throw error;
        setHistories((data || []) as Array<{ id: string; memo: string | null }>);
      } catch (err: any) {
        setHistories([]);
        setHistoriesError(err?.message || 'Failed to load history.');
      } finally {
        setHistoriesLoading(false);
      }
    },
    [supabase]
  );

  const checkFriends = useCallback(async (): Promise<void> => {
    const { data, error } = await supabase.from('friend').select('*');
    if (error) {
      console.error('Error getting friends:', error.message);
      return;
    }
    const peopleList = (data as Person[]).map((eachPerson) => {
      return new Person({
        id: eachPerson.id,
        name: eachPerson.name,
        profile: eachPerson.profile,
      });
    });
    peopleList.length === 0 && peopleList.push(new Person({}));
    setPeople(peopleList);
  }, [setPeople, supabase]);

  const logoutUser = useCallback((): void => {
    supabase.auth.signOut();
    setUser(null);
    setHistories(null);
    setHistoriesError(null);
  }, [supabase]);

  const checkUser = useCallback(async (): Promise<void> => {
    const { data, error } = await supabase.auth.getUser();
    if (error) {
      console.error('Error getting user:', error.message);
      logoutUser();
      return;
    }

    const user = data.user;
    setUser(user);
    checkFriends();

    if (user?.id) {
      await fetchUserHistories(user.id);
    }
  }, [
    fetchUserHistories,
    checkFriends,
    logoutUser,
    supabase,
  ]);

  useEffect(() => {
    void checkUser();
  }, [checkUser]);

  async function handleSignInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${process.env.NEXT_PUBLIC_DOMAIN}/auth/callback`,
      }
    });
  }


  return <>
    <div className="self-end"
         onClick={ () => togglePopup()}>
      {
        user
        ?
          <div className="flex flex-row ">
            <div className={`bg-third cursor-pointer p-1 md:pr-3
                            gap-1 md:gap-3
                           rounded-full text-center m-auto md:hover:opacity-50 flex
                           items-center justify-center`}> 
              <Image src={user?.identities?.at(0)?.identity_data?.avatar_url }
                    width={35}
                    height={35}
                    className="rounded-full"
                    alt={user?.identities?.at(0)?.identity_data?.full_name || 'full name' }  />
              <span className="max-w-[100px] truncate">{ user?.identities?.at(0)?.identity_data?.full_name || '' }</span>
            </div>
          </div>
        : <div className="flex flex-row items-center gap-1 md:gap-3 md:hover:cursor-pointer md:hover:opacity-50">
          <UnknownPerson /> 
          <span>Login</span>
        </div>
      }
    </div>

    <Modal title={ user ? 'User Information' : 'Login'}
             footer={null}
             centered
             onCancel={ () => togglePopup() }
             open={openPopup} >
        <div className='text-center mt-5 min-h-[180px] flex flex-col justify-center items-center'>
          {
            user && <div className="flex flex-col items-center mb-7">
              <div className="flex flex-col md:flex-row gap-3 md:gap-5 items-center mb-7">
                <Image src={user?.identities?.at(0)?.identity_data?.avatar_url }
                      width={60}
                      height={60}
                      className="rounded-full"
                      alt={user?.identities?.at(0)?.identity_data?.full_name || 'full name' }  />
                <div className="text-left">
                  <h6 className="text-left">{ user?.identities?.at(0)?.identity_data?.full_name || '' }</h6>
                  <h6 className="text-left">{ user?.identities?.at(0)?.identity_data?.email || '' }</h6>
                  <small className={`text-left ${ params.isPremiumUser ? 'text-[#FFD700]' : 'text-fourth'}`}>
                    { params.isPremiumUser ? 'Premium User' : 'Regular User' }
                  </small>
                </div>
              </div>

              <div
                className="min-w-[300px] flex flex-row gap-2 justify-center">
                <HistoryOutlined />
                <span>History{histories ? ` (${histories.length})` : ''}</span>
              </div>

              <div className="w-full mt-3">
                {historiesLoading ? (
                  <div className="flex justify-center py-3">
                    <Spin />
                  </div>
                ) : historiesError ? (
                  <div className="text-fourth text-center py-2">
                    {historiesError}
                  </div>
                ) : histories && histories.length > 0 ? (
                  <ul className="flex flex-col gap-2 max-h-[240px] overflow-auto pr-1">
                    {histories.map((h) => (
                      <li key={h.id} className="rounded border border-main/20 px-3 py-2 hover:bg-main/5">
                        <button
                          type="button"
                          className="w-full text-left"
                          onClick={ () => router.push(`/history/${h.id}`)}
                        >
                          <div className="flex flex-row items-center justify-between gap-2">
                            <span className="truncate font-semibold text-main">
                              {h.memo?.trim() ? h.memo : 'Untitled history'}
                            </span>
                            <span className="text-fourth text-sm flex-shrink-0">Open</span>
                          </div>
                        </button>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <div className="text-fourth text-center py-3">No history yet.</div>
                )}
              </div>
            </div>
          }
          <Button
            className="min-w-[300px]"
            type="primary"
            onClick={ () => user ? logoutUser() : handleSignInWithGoogle()}
            icon={<GoogleOutlined />}>
            {
              user ? 'Logout' : 'Login with Google'
            }
          </Button>
        </div>
      </Modal>
  </>
}