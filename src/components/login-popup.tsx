import { useEffect, useState } from "react";
import UnknownPerson from "./unknown-person";
import { UndoOutlined } from "@ant-design/icons";
import { Modal, Button } from "antd";
import { createClient } from "@/utils/supabase/client";
import { User } from "@supabase/auth-js";
import Image from 'next/image';
import { Person } from "@/models/person.models";


export default function LoginPopup(params: { setPeople: Function }): JSX.Element {

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
    checkFriends();
  }

  async function checkFriends(): Promise<void> {
    const { data, error } = await supabase.from('friend').select('*')
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
        redirectTo: `${window.location.origin}/auth/callback`,
      }
    });
  }


  return <>
    <div className=""
         onClick={ () => togglePopup()}>
      {
        user
        ?
          <div className="flex flex-col">
            <div className={`bg-third cursor-pointer p-1
                           rounded-full text-center m-auto md:hover:opacity-50 flex
                           items-center justify-center`}> 
              <Image src={user?.identities?.at(0)?.identity_data?.avatar_url }
                    width={30}
                    height={30}
                    className="rounded-full"
                    alt={user?.identities?.at(0)?.identity_data?.full_name || 'full name' }  />
            </div>
          </div>
        : <UnknownPerson /> 
      }
    </div>

    <Modal title="Login"
             footer={null}
             centered
             onCancel={ () => togglePopup() }
             open={openPopup} >
        <div className='grid grid-cols-3 md:grid-cols-4 gap-4 h-[320px] overflow-auto p-5'>
          {/* {
            avatarNumbers.map((eachNumber, index) => {
              return <div className='bg-third cursor-pointer p-1 w-fit h-fit rounded-full m-auto hover:opacity-50'
                          key={index}
                          onClick={() => changeAvatar(index) }>
                <Avatar src={`${AVATAR_URL}${eachNumber}`} className='w-12 h-12 ' />
              </div>
            })
          } */}
        </div>
        <div className='text-center mt-5'>
          <Button
            onClick={ () => user ? logoutUser() : handleSignInWithGoogle()}
            icon={<UndoOutlined />}>
            {
              user ? 'Logout' : 'Login with Google'
            }
          </Button>
        </div>
      </Modal>
  </>
}