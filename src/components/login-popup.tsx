import { useEffect, useState } from "react";
import UnknownPerson from "./unknown-person";
import { GoogleOutlined, HistoryOutlined } from "@ant-design/icons";
import { Modal, Button } from "antd";
import { createClient } from "@/utils/supabase/client";
import { User } from "@supabase/auth-js";
import Image from 'next/image';
import { Person } from "@/models/person.models";

export interface LoginPopupProps { 
  setPeople: Function, 
  isPremiumUser: boolean,
  setIsPremiumUser: Function
}

export default function LoginPopup(params: LoginPopupProps ): JSX.Element {

  const [user, setUser] = useState<User | null>(null);

  const supabase = createClient();

  const [openPopup, setOpenPopup] = useState(false);

  useEffect(() => {
    checkUser();
  }, []);

  function togglePopup(): void {
    setOpenPopup(!openPopup);
  }

  async function checkUser(): Promise<void> {
    const { data, error} = await supabase.auth.getUser();
    if (error) {
      console.error('Error getting user:', error.message);
      logoutUser();
      return;
    }
    const user = data.user;
    setUser(user);
    checkPremiumUser();
    checkFriends();
  }

  async function checkPremiumUser(): Promise<void> {
    const { data, error } = await supabase.from('premium').select('is_premium');
    if (error) {
      console.error('Error getting user:', error.message);
      return;
    }
    params.setIsPremiumUser(data?.at(0)?.is_premium || false);
  }

  async function checkFriends(): Promise<void> {
    const { data, error } = await supabase.from('friend').select('*');
    if (error) {
      console.error('Error getting friends:', error.message);
      return;
    }
    const peopleList = (data as Person[]).map( (eachPerson) => {
      return new Person({
        id: eachPerson.id,
        name: eachPerson.name,
        profile: eachPerson.profile,
      })
    });
    peopleList.length === 0 && peopleList.push(new Person({}));
    params.setPeople(peopleList);
  }

  function logoutUser(): void {
    supabase.auth.signOut();
    setUser(null);
  }

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

              <Button
                className="min-w-[300px]"
                disabled
                onClick={ () => user ? logoutUser() : handleSignInWithGoogle()}
                icon={<HistoryOutlined />}>
                History (Coming Soon)
              </Button>

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